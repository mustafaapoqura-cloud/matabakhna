import React, { useState, useEffect, useRef } from 'react';
import {
  UtensilsCrossed,
  LayoutDashboard,
  ChefHat,
  Tags,
  CalendarDays,
  Wallet,
  ShoppingCart,
  Settings,
  Plus,
  Search,
  Filter,
  Edit2,
  Trash2,
  Eye,
  CheckCircle2,
  AlertCircle,
  Clock,
  Flame,
  Users,
  Coins,
  RefreshCw,
  X,
  ExternalLink,
  Sparkles,
  ArrowUpDown,
  UploadCloud,
  Image as ImageIcon
} from 'lucide-react';
import { api } from './api';

export default function App() {
  const [activeTab, setActiveTab] = useState('overview');
  const [serverOnline, setServerOnline] = useState(true);
  const [loading, setLoading] = useState(false);
  const [toast, setToast] = useState(null);

  // File Upload
  const fileInputRef = useRef(null);
  const [uploadingImage, setUploadingImage] = useState(false);

  // Data states
  const [stats, setStats] = useState(null);
  const [recipes, setRecipes] = useState([]);
  const [categories, setCategories] = useState([]);
  const [settings, setSettings] = useState({});

  // Filter & Search states
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCategory, setSelectedCategory] = useState('all');
  const [selectedCostTier, setSelectedCostTier] = useState('all');
  const [sortBy, setSortBy] = useState('newest');

  // Modals
  const [recipeModalOpen, setRecipeModalOpen] = useState(false);
  const [editingRecipe, setEditingRecipe] = useState(null);
  const [viewRecipeModal, setViewRecipeModal] = useState(null);
  const [deleteConfirmId, setDeleteConfirmId] = useState(null);

  // Category Modal State
  const [categoryModalOpen, setCategoryModalOpen] = useState(false);
  const [categoryFormData, setCategoryFormData] = useState({
    id: '',
    name: '',
    emoji: '🍲',
    description: '',
    idManual: false
  });

  // Form State for Recipe Add/Edit
  const [formData, setFormData] = useState(getInitialRecipeForm());

  function showToast(message, type = 'success') {
    setToast({ message, type });
    setTimeout(() => setToast(null), 3500);
  }

  function getInitialRecipeForm() {
    return {
      id: '',
      name: '',
      category: 'egyptian',
      imageUrl: '',
      description: '',
      prepTimeMinutes: 20,
      cookTimeMinutes: 30,
      servings: 4,
      estimatedCost: 120,
      costTier: 'medium',
      calories: 450,
      ingredients: [{ name: '', amount: '', notes: '' }],
      steps: [''],
      tips: ['']
    };
  }

  // Handle direct file upload
  const handleImageUpload = async (e) => {
    const file = e.target.files?.[0];
    if (!file) return;

    if (!file.type.startsWith('image/')) {
      showToast('يرجى اختيار ملف صورة صالح (JPG, PNG, WEBP)', 'error');
      return;
    }

    setUploadingImage(true);
    try {
      const res = await api.uploadImage(file);
      if (res.success && res.url) {
        setFormData(prev => ({ ...prev, imageUrl: res.url }));
        showToast('تم رفع صورة الأكلة بنجاح 📸');
      } else {
        showToast(res.message || 'حدث خطأ أثناء رفع الصورة', 'error');
      }
    } catch (err) {
      showToast('تعذر رفع الصورة، تأكد من اتصال السيرفر', 'error');
    } finally {
      setUploadingImage(false);
    }
  };

  // Load Initial Data
  const loadAllData = async () => {
    setLoading(true);
    try {
      const [statsRes, recipesRes, catsRes, setRes] = await Promise.all([
        api.getStats().catch(() => ({ success: false })),
        api.getRecipes().catch(() => ({ success: false, data: [] })),
        api.getCategories().catch(() => ({ success: false, data: [] })),
        api.getSettings().catch(() => ({ success: false, data: {} }))
      ]);

      if (statsRes.success) setStats(statsRes.data);
      if (recipesRes.success) setRecipes(recipesRes.data || []);
      if (catsRes.success) setCategories(catsRes.data || []);
      if (setRes.success) setSettings(setRes.data || {});
      setServerOnline(true);
    } catch (err) {
      console.error(err);
      setServerOnline(false);
      showToast('تعذر الاتصال بالخادم، تأكد من تشغيل الباك إند', 'error');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadAllData();
  }, []);

  // Filtered & Sorted Recipes
  const filteredRecipes = recipes.filter(r => {
    const matchesSearch = !searchQuery || 
      r.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      r.description.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesCat = selectedCategory === 'all' || r.category === selectedCategory;
    const matchesTier = selectedCostTier === 'all' || r.costTier === selectedCostTier;
    return matchesSearch && matchesCat && matchesTier;
  }).sort((a, b) => {
    if (sortBy === 'costAsc') return a.estimatedCost - b.estimatedCost;
    if (sortBy === 'costDesc') return b.estimatedCost - a.estimatedCost;
    if (sortBy === 'calories') return b.calories - a.calories;
    if (sortBy === 'time') return (a.prepTimeMinutes + a.cookTimeMinutes) - (b.prepTimeMinutes + b.cookTimeMinutes);
    return 0; // newest
  });

  // Open modal for Create
  const handleOpenCreateModal = () => {
    setEditingRecipe(null);
    setFormData(getInitialRecipeForm());
    setRecipeModalOpen(true);
  };

  // Open modal for Edit
  const handleOpenEditModal = (recipe) => {
    setEditingRecipe(recipe);
    setFormData({
      id: recipe.id,
      name: recipe.name,
      category: recipe.category,
      imageUrl: recipe.imageUrl,
      description: recipe.description,
      prepTimeMinutes: recipe.prepTimeMinutes,
      cookTimeMinutes: recipe.cookTimeMinutes,
      servings: recipe.servings,
      estimatedCost: recipe.estimatedCost,
      costTier: recipe.costTier,
      calories: recipe.calories,
      ingredients: recipe.ingredients && recipe.ingredients.length > 0 ? recipe.ingredients : [{ name: '', amount: '', notes: '' }],
      steps: recipe.steps && recipe.steps.length > 0 ? recipe.steps : [''],
      tips: recipe.tips && recipe.tips.length > 0 ? recipe.tips : ['']
    });
    setRecipeModalOpen(true);
  };

  // Save Recipe (Create or Update)
  const handleSaveRecipe = async (e) => {
    e.preventDefault();
    if (!formData.name.trim()) {
      showToast('يرجى إدخال اسم الوصفة', 'error');
      return;
    }

    try {
      if (editingRecipe) {
        await api.updateRecipe(editingRecipe.id, formData);
        showToast('تم تحديث بيانات الوصفة بنجاح ✨');
      } else {
        await api.createRecipe(formData);
        showToast('تمت إضافة الوصفة الجديدة بنجاح للمطبخ 👩‍🍳');
      }
      setRecipeModalOpen(false);
      loadAllData();
    } catch (err) {
      showToast('حدث خطأ أثناء حفظ الوصفة', 'error');
    }
  };

  // Delete Recipe
  const handleDeleteRecipe = async (id) => {
    try {
      await api.deleteRecipe(id);
      showToast('تم حذف الوصفة بنجاح');
      setDeleteConfirmId(null);
      loadAllData();
    } catch (err) {
      showToast('تعذر حذف الوصفة', 'error');
    }
  };

  // Category Handlers
  const handleOpenCreateCategoryModal = () => {
    setCategoryFormData({
      id: '',
      name: '',
      emoji: '🍲',
      description: '',
      idManual: false
    });
    setCategoryModalOpen(true);
  };

  const handleSaveCategory = async (e) => {
    e.preventDefault();
    if (!categoryFormData.name.trim()) {
      showToast('يرجى كتابة اسم القسم', 'error');
      return;
    }

    let catId = categoryFormData.id.trim();
    if (!catId) {
      catId = 'cat_' + Date.now().toString().slice(-6);
    } else {
      catId = catId.toLowerCase().replace(/[^a-z0-9_]/g, '_');
    }

    try {
      await api.saveCategory({
        id: catId,
        name: categoryFormData.name.trim(),
        emoji: categoryFormData.emoji.trim() || '🍲',
        description: categoryFormData.description.trim()
      });
      showToast('تمت إضافة القسم بنجاح للمطبخ 🎉');
      setCategoryModalOpen(false);
      const catsRes = await api.getCategories();
      if (catsRes && catsRes.data) {
        setCategories(catsRes.data);
      }
    } catch (err) {
      showToast('حدث خطأ أثناء حفظ القسم', 'error');
    }
  };

  const handleDeleteCategory = async (catId) => {
    if (!window.confirm('هل أنت متأكد من حذف هذا القسم؟')) return;
    try {
      await api.deleteCategory(catId);
      showToast('تم حذف القسم بنجاح');
      const catsRes = await api.getCategories();
      if (catsRes && catsRes.data) {
        setCategories(catsRes.data);
      }
    } catch (err) {
      showToast('فشل حذف القسم', 'error');
    }
  };

  // Save Settings
  const handleSaveSettings = async (e) => {
    e.preventDefault();
    try {
      await api.saveSettings(settings);
      showToast('تم حفظ إعدادات التطبيق بنجاح');
    } catch (err) {
      showToast('حدث خطأ أثناء حفظ الإعدادات', 'error');
    }
  };

  return (
    <div className="app-container">
      {/* Toast Notification */}
      {toast && (
        <div style={{
          position: 'fixed',
          top: 24,
          left: '50%',
          transform: 'translateX(-50%)',
          zIndex: 9999,
          background: toast.type === 'error' ? 'var(--danger)' : 'var(--primary)',
          color: 'white',
          padding: '12px 24px',
          borderRadius: 'var(--radius-md)',
          boxShadow: '0 8px 24px rgba(0,0,0,0.18)',
          display: 'flex',
          alignItems: 'center',
          gap: 10,
          fontWeight: 700,
          fontSize: 14
        }}>
          {toast.type === 'error' ? <AlertCircle size={20} /> : <CheckCircle2 size={20} />}
          {toast.message}
        </div>
      )}

      {/* Sidebar Navigation */}
      <aside className="sidebar">
        <div className="brand">
          <div className="brand-icon">
            <Flame size={26} />
          </div>
          <div className="brand-text">
            <h1>طبختنا</h1>
            <p>لوحة التحكم والإدارة الذكية</p>
          </div>
        </div>

        <nav className="nav-menu">
          <button 
            className={`nav-item ${activeTab === 'overview' ? 'active' : ''}`}
            onClick={() => setActiveTab('overview')}
          >
            <LayoutDashboard size={19} />
            <span>نظرة عامة والتحليلات</span>
          </button>

          <button 
            className={`nav-item ${activeTab === 'recipes' ? 'active' : ''}`}
            onClick={() => setActiveTab('recipes')}
          >
            <ChefHat size={19} />
            <span>إدارة الوصفات</span>
            <span className="nav-badge">{recipes.length}</span>
          </button>

          <button 
            className={`nav-item ${activeTab === 'categories' ? 'active' : ''}`}
            onClick={() => setActiveTab('categories')}
          >
            <Tags size={19} />
            <span>التصنيفات والأقسام</span>
            <span className="nav-badge">{categories.length}</span>
          </button>

          <button 
            className={`nav-item ${activeTab === 'settings' ? 'active' : ''}`}
            onClick={() => setActiveTab('settings')}
          >
            <Settings size={19} />
            <span>إعدادات التطبيق</span>
          </button>
        </nav>

        <div className="sidebar-footer">
          <div className="server-status">
            <span className="status-dot" style={{ background: serverOnline ? 'var(--success)' : 'var(--danger)' }}></span>
            <span>الباك إند: {serverOnline ? 'PHP 8.2 شغال 🟢' : 'غير متصل 🔴'}</span>
          </div>
          <button onClick={loadAllData} className="btn btn-secondary btn-sm" style={{ width: '100%', justifyContent: 'center' }}>
            <RefreshCw size={14} className={loading ? 'spin' : ''} />
            <span>تحديث البيانات</span>
          </button>
        </div>
      </aside>

      {/* Main Content Area */}
      <div className="main-wrapper">
        {/* Top Header */}
        <header className="topbar">
          <div className="topbar-title">
            <h2>
              {activeTab === 'overview' && 'لوحة التحكم والتحليلات العامة'}
              {activeTab === 'recipes' && 'إدارة مكتبة الوصفات والأكلات'}
              {activeTab === 'categories' && 'إدارة أقسام وتصنيفات الطعام'}
              {activeTab === 'settings' && 'إعدادات المنظومة وبانرات الإشعارات'}
            </h2>
          </div>

          <div className="topbar-actions" style={{ display: 'flex', gap: 10 }}>
            {activeTab === 'categories' ? (
              <button className="btn btn-primary" onClick={handleOpenCreateCategoryModal}>
                <Plus size={18} />
                <span>أضف قسماً جديداً</span>
              </button>
            ) : (
              <button className="btn btn-primary" onClick={handleOpenCreateModal}>
                <Plus size={18} />
                <span>أضف أكلة جديدة</span>
              </button>
            )}
          </div>
        </header>

        {/* Tab 1: Overview */}
        {activeTab === 'overview' && (
          <div className="content-area">
            {/* Metric Cards */}
            <div className="metrics-grid">
              <div className="metric-card">
                <div className="metric-icon" style={{ background: 'var(--primary-alpha10)', color: 'var(--primary)' }}>
                  <UtensilsCrossed size={26} />
                </div>
                <div className="metric-info">
                  <h3>{stats?.totalRecipes || recipes.length}</h3>
                  <p>إجمالي الوصفات المتاحة</p>
                </div>
              </div>

              <div className="metric-card">
                <div className="metric-icon" style={{ background: 'var(--success-bg)', color: 'var(--success)' }}>
                  <Coins size={26} />
                </div>
                <div className="metric-info">
                  <h3>{stats?.costTiers?.budget || 0}</h3>
                  <p>أكلات اقتصادية (على قد الإيد)</p>
                </div>
              </div>

              <div className="metric-card">
                <div className="metric-icon" style={{ background: 'var(--secondary-alpha15)', color: 'var(--secondary)' }}>
                  <Wallet size={26} />
                </div>
                <div className="metric-info">
                  <h3>{stats?.averageCost || 0} ج.م</h3>
                  <p>متوسط تكلفة الوجبة للأسرة</p>
                </div>
              </div>

              <div className="metric-card">
                <div className="metric-icon" style={{ background: 'rgba(232, 89, 12, 0.1)', color: 'var(--primary)' }}>
                  <Flame size={26} />
                </div>
                <div className="metric-info">
                  <h3>{stats?.averageCalories || 450}</h3>
                  <p>متوسط السعرات الحرارية</p>
                </div>
              </div>
            </div>

            {/* Quick Banner Alert */}
            <div style={{
              background: 'linear-gradient(135deg, rgba(232, 89, 12, 0.08), rgba(245, 159, 0, 0.08))',
              border: '1px solid #ffd8a8',
              borderRadius: 'var(--radius-lg)',
              padding: '20px 24px',
              marginBottom: '28px',
              display: 'flex',
              alignItems: 'center',
              gap: 16
            }}>
              <div style={{
                background: 'var(--primary)',
                color: 'white',
                padding: '12px',
                borderRadius: 'var(--radius-md)'
              }}>
                <Sparkles size={24} />
              </div>
              <div style={{ flex: 1 }}>
                <h4 style={{ fontSize: 16, fontWeight: 800, color: 'var(--primary-dark)', marginBottom: 4 }}>
                  نصيحة اليوم المعروضة لمستخدمي التطبيق:
                </h4>
                <p style={{ fontSize: 14, color: 'var(--text-primary)' }}>
                  {settings.tipOfTheDay || 'رشة نعناع ناشف مفروك مع خلطة المحشي سر نكهة المحشي الأصيل.'}
                </p>
              </div>
              <button 
                className="btn btn-secondary btn-sm"
                onClick={() => setActiveTab('settings')}
              >
                تعديل النصيحة
              </button>
            </div>

            {/* Panels Layout */}
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(360px, 1fr))', gap: 24 }}>
              {/* Category Breakdown */}
              <div className="panel">
                <div className="panel-header">
                  <h3><Tags size={18} color="var(--primary)" /> توزيع الوصفات حسب الأقسام</h3>
                  <button className="btn btn-secondary btn-sm" onClick={() => setActiveTab('categories')}>عرض الكل</button>
                </div>
                <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
                  {categories.map(cat => {
                    const count = recipes.filter(r => r.category === cat.id).length;
                    const percent = recipes.length ? Math.round((count / recipes.length) * 100) : 0;
                    return (
                      <div key={cat.id} style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
                        <span style={{ fontSize: 20 }}>{cat.emoji}</span>
                        <div style={{ flex: 1 }}>
                          <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: 13.5, fontWeight: 700 }}>
                            <span>{cat.name}</span>
                            <span>{count} وصفة ({percent}%)</span>
                          </div>
                          <div style={{ height: 6, background: 'var(--bg)', borderRadius: 10, marginTop: 4, overflow: 'hidden' }}>
                            <div style={{ width: `${percent}%`, height: '100%', background: 'linear-gradient(to left, var(--primary), var(--secondary))' }} />
                          </div>
                        </div>
                      </div>
                    );
                  })}
                </div>
              </div>

              {/* Recent Recipes */}
              <div className="panel">
                <div className="panel-header">
                  <h3><Clock size={18} color="var(--primary)" /> أحدث الوصفات المضافة</h3>
                  <button className="btn btn-secondary btn-sm" onClick={() => setActiveTab('recipes')}>عرض الكل</button>
                </div>
                <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
                  {recipes.slice(0, 4).map(recipe => (
                    <div 
                      key={recipe.id}
                      style={{
                        display: 'flex',
                        alignItems: 'center',
                        gap: 12,
                        padding: '8px 12px',
                        borderRadius: 'var(--radius-md)',
                        background: 'var(--bg)',
                        border: '1px solid var(--border)'
                      }}
                    >
                      <img 
                        src={recipe.imageUrl} 
                        alt={recipe.name}
                        style={{ width: 50, height: 50, borderRadius: 'var(--radius-sm)', objectFit: 'cover' }}
                      />
                      <div style={{ flex: 1, minWidth: 0 }}>
                        <h5 style={{ fontSize: 14, fontWeight: 700, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
                          {recipe.name}
                        </h5>
                        <p style={{ fontSize: 12, color: 'var(--text-secondary)' }}>
                          {recipe.estimatedCost} ج.م • {recipe.servings} أفراد • {recipe.prepTimeMinutes + recipe.cookTimeMinutes} دقيقة
                        </p>
                      </div>
                      <button 
                        className="btn btn-secondary btn-sm"
                        onClick={() => handleOpenEditModal(recipe)}
                      >
                        <Edit2 size={14} />
                      </button>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Tab 2: Recipes Management */}
        {activeTab === 'recipes' && (
          <div className="content-area">
            {/* Filter Bar */}
            <div className="filter-bar">
              <div className="search-input-wrap">
                <input 
                  type="text" 
                  placeholder="ابحث بالاسم أو المكونات أو الطريقة..." 
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                />
                <Search size={18} className="search-icon" />
              </div>

              <select 
                className="select-filter"
                value={selectedCategory}
                onChange={(e) => setSelectedCategory(e.target.value)}
              >
                <option value="all">كل الأقسام والتصنيفات</option>
                {categories.map(c => (
                  <option key={c.id} value={c.id}>{c.emoji} {c.name}</option>
                ))}
              </select>

              <select 
                className="select-filter"
                value={selectedCostTier}
                onChange={(e) => setSelectedCostTier(e.target.value)}
              >
                <option value="all">كل مستويات التكلفة</option>
                <option value="budget">🟢 اقتصادي (على قد الإيد)</option>
                <option value="medium">🟡 متوسط (معقول)</option>
                <option value="deluxe">🟣 مميز (عزومات وتدليع)</option>
              </select>

              <select 
                className="select-filter"
                value={sortBy}
                onChange={(e) => setSortBy(e.target.value)}
              >
                <option value="newest">الأحدث إضافة</option>
                <option value="costAsc">الأقل تكلفة أولاً</option>
                <option value="costDesc">الأعلى تكلفة أولاً</option>
                <option value="calories">الأعلى سعرات</option>
                <option value="time">الأسرع تحضيراً</option>
              </select>
            </div>

            {/* Results Header */}
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 16 }}>
              <span style={{ fontSize: 14, color: 'var(--text-secondary)', fontWeight: 600 }}>
                تم العثور على <strong style={{ color: 'var(--primary)' }}>{filteredRecipes.length}</strong> وصفة
              </span>
            </div>

            {filteredRecipes.length === 0 ? (
              <div style={{
                background: 'var(--surface)',
                border: '2px dashed #ffd8a8',
                borderRadius: 'var(--radius-xl)',
                padding: '60px 24px',
                textAlign: 'center',
                display: 'flex',
                flexDirection: 'column',
                alignItems: 'center',
                gap: 16,
                boxShadow: 'var(--shadow-sm)'
              }}>
                <div style={{
                  width: 72,
                  height: 72,
                  borderRadius: '50%',
                  background: 'var(--primary-alpha10)',
                  color: 'var(--primary)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center'
                }}>
                  <ChefHat size={38} />
                </div>
                <h4 style={{ fontSize: 20, fontWeight: 800 }}>مطبخك جاهز وخالٍ من أي أكلات مسبقة!</h4>
                <p style={{ fontSize: 14.5, color: 'var(--text-secondary)', maxWidth: 460, lineHeight: 1.7 }}>
                  قاعدة البيانات فارغة تماماً بناءً على طلبك. يمكنك الآن البدء بإضافة أول أكلة وصفتها ورفع صورتها بنفسك لتظهر فوراً في تطبيق الموبايل.
                </p>
                <button className="btn btn-primary" onClick={handleOpenCreateModal} style={{ marginTop: 8 }}>
                  <Plus size={18} />
                  <span>أضف أول وصفة وارفع صورتك الآن</span>
                </button>
              </div>
            ) : (
              <div className="recipes-grid">
                {filteredRecipes.map(recipe => (
                <div key={recipe.id} className="recipe-card-admin">
                  <div className="recipe-img-box">
                    <img src={recipe.imageUrl} alt={recipe.name} />
                    <div className="badge-overlay">
                      {recipe.costTier === 'budget' && '🟢 اقتصادي'}
                      {recipe.costTier === 'medium' && '🟡 متوسط'}
                      {recipe.costTier === 'deluxe' && '🟣 مميز'}
                    </div>
                    <div className="cost-overlay">
                      {recipe.estimatedCost} ج.م
                    </div>
                  </div>

                  <div className="recipe-card-body">
                    <h4>{recipe.name}</h4>
                    <p className="recipe-desc-clamp">{recipe.description}</p>

                    <div className="recipe-meta-row">
                      <div className="recipe-meta-item">
                        <Clock size={14} color="var(--primary)" />
                        <span>{recipe.prepTimeMinutes + recipe.cookTimeMinutes} دقيقة</span>
                      </div>
                      <div className="recipe-meta-item">
                        <Users size={14} color="var(--primary)" />
                        <span>{recipe.servings} أفراد</span>
                      </div>
                      <div className="recipe-meta-item">
                        <Flame size={14} color="var(--primary)" />
                        <span>{recipe.calories} سعرة</span>
                      </div>
                    </div>

                    <div className="recipe-card-actions">
                      <button 
                        className="btn btn-secondary btn-sm"
                        onClick={() => setViewRecipeModal(recipe)}
                      >
                        <Eye size={14} /> معاينة
                      </button>
                      <button 
                        className="btn btn-secondary btn-sm"
                        onClick={() => handleOpenEditModal(recipe)}
                      >
                        <Edit2 size={14} /> تعديل
                      </button>
                      <button 
                        className="btn btn-danger btn-sm"
                        onClick={() => setDeleteConfirmId(recipe.id)}
                      >
                        <Trash2 size={14} />
                      </button>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
          </div>
        )}

        {/* Tab 3: Categories */}
        {activeTab === 'categories' && (
          <div className="content-area">
            <div className="panel">
              <div className="panel-header" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: 12 }}>
                <div>
                  <h3><Tags size={20} color="var(--primary)" /> تصنيفات وأقسام المطبخ ({categories.length})</h3>
                  <p style={{ fontSize: 13, color: 'var(--text-secondary)', marginTop: 4 }}>
                    يمكنك إضافة وتخصيص أقسام الطعام المعروضة في التطبيق لتسهيل بحث واختيار الوصفات.
                  </p>
                </div>
                <button className="btn btn-primary" onClick={handleOpenCreateCategoryModal}>
                  <Plus size={16} /> إضافة قسم جديد
                </button>
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(290px, 1fr))', gap: 20 }}>
                {categories.map(cat => {
                  const count = recipes.filter(r => r.category === cat.id).length;
                  return (
                    <div 
                      key={cat.id} 
                      style={{
                        background: 'var(--surface)',
                        border: '1px solid var(--border)',
                        borderRadius: 'var(--radius-lg)',
                        padding: 22,
                        display: 'flex',
                        flexDirection: 'column',
                        gap: 14,
                        boxShadow: 'var(--shadow-sm)',
                        transition: 'transform 0.2s, box-shadow 0.2s'
                      }}
                    >
                      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                        <div style={{
                          width: 52,
                          height: 52,
                          borderRadius: 'var(--radius-md)',
                          background: 'var(--bg)',
                          display: 'flex',
                          alignItems: 'center',
                          justifyContent: 'center',
                          fontSize: 28,
                          border: '1px solid var(--border)'
                        }}>
                          {cat.emoji}
                        </div>
                        <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                          <span style={{
                            background: 'var(--primary-alpha10)',
                            color: 'var(--primary)',
                            fontWeight: 700,
                            fontSize: 12.5,
                            padding: '4px 10px',
                            borderRadius: 20
                          }}>
                            {count} وصفة
                          </span>
                          <button
                            title="حذف هذا القسم"
                            className="btn btn-sm"
                            style={{ color: 'var(--danger)', background: 'rgba(250, 82, 82, 0.08)', borderRadius: 'var(--radius-sm)', padding: '6px 8px' }}
                            onClick={() => handleDeleteCategory(cat.id)}
                          >
                            <Trash2 size={15} />
                          </button>
                        </div>
                      </div>

                      <div>
                        <h4 style={{ fontSize: 18, fontWeight: 800, marginBottom: 6, color: 'var(--text-primary)' }}>
                          {cat.name}
                        </h4>
                        <p style={{ fontSize: 13, color: 'var(--text-secondary)', lineHeight: 1.5, minHeight: 40 }}>
                          {cat.description || 'أشهى الأطباق والوصفات المختارة لهذا القسم'}
                        </p>
                      </div>

                      <div style={{
                        display: 'flex',
                        justifyContent: 'space-between',
                        alignItems: 'center',
                        fontSize: 12,
                        color: 'var(--text-secondary)',
                        borderTop: '1px dashed var(--border)',
                        paddingTop: 10,
                        marginTop: 'auto'
                      }}>
                        <span>معرّف القسم:</span>
                        <code style={{ background: 'var(--bg)', padding: '2px 8px', borderRadius: 4, fontWeight: 600, color: 'var(--primary)' }}>
                          {cat.id}
                        </code>
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>
          </div>
        )}

        {/* Tab 7: Settings */}
        {activeTab === 'settings' && (
          <div className="content-area">
            <div className="panel" style={{ maxWidth: 700 }}>
              <div className="panel-header">
                <h3><Settings size={20} color="var(--primary)" /> إعدادات المنظومة والبانرات</h3>
              </div>

              <form onSubmit={handleSaveSettings} style={{ display: 'flex', flexDirection: 'column', gap: 18 }}>
                <div className="form-group">
                  <label className="form-label">اسم التطبيق</label>
                  <input 
                    type="text"
                    className="form-input"
                    value={settings.appName || 'طبختنا'}
                    onChange={(e) => setSettings({ ...settings, appName: e.target.value })}
                  />
                </div>

                <div className="form-group">
                  <label className="form-label">شعار التطبيق (Motto)</label>
                  <input 
                    type="text"
                    className="form-input"
                    value={settings.appMotto || 'ميزانية ووصفات أكل لكل بيت'}
                    onChange={(e) => setSettings({ ...settings, appMotto: e.target.value })}
                  />
                </div>

                <div className="form-group">
                  <label className="form-label">نصيحة اليوم المعروضة في الشاشة الرئيسية</label>
                  <textarea 
                    rows="3"
                    className="form-textarea"
                    value={settings.tipOfTheDay || ''}
                    onChange={(e) => setSettings({ ...settings, tipOfTheDay: e.target.value })}
                  />
                </div>

                <div className="form-group">
                  <label className="form-label">رسالة البانر الإعلاني أو التنبيه</label>
                  <textarea 
                    rows="2"
                    className="form-textarea"
                    value={settings.announcement || ''}
                    onChange={(e) => setSettings({ ...settings, announcement: e.target.value })}
                  />
                </div>

                <div className="form-group">
                  <label className="form-label">رمز العملة الافتراضية</label>
                  <input 
                    type="text"
                    className="form-input"
                    value={settings.currency || 'ج.م'}
                    onChange={(e) => setSettings({ ...settings, currency: e.target.value })}
                  />
                </div>

                <button type="submit" className="btn btn-primary" style={{ alignSelf: 'flex-start' }}>
                  حفظ كافة الإعدادات
                </button>
              </form>
            </div>
          </div>
        )}
      </div>

      {/* Modal: Add / Edit Recipe */}
      {recipeModalOpen && (
        <div className="modal-overlay" onClick={() => setRecipeModalOpen(false)}>
          <div className="modal-dialog" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h3>
                <ChefHat size={22} color="var(--primary)" />
                <span>{editingRecipe ? 'تعديل بيانات الوصفة' : 'إضافة وصفة جديدة للمطبخ'}</span>
              </h3>
              <button className="modal-close-btn" onClick={() => setRecipeModalOpen(false)}>
                <X size={20} />
              </button>
            </div>

            <form onSubmit={handleSaveRecipe} style={{ display: 'flex', flexDirection: 'column', flex: 1, overflow: 'hidden' }}>
              <div className="modal-body">
                <div className="form-grid">
                  <div className="form-group form-full">
                    <label className="form-label">اسم الأكلة أو الوصفة *</label>
                    <input 
                      type="text" 
                      required
                      className="form-input" 
                      placeholder="مثال: طاجن مكرونة باللحمة المفرومة"
                      value={formData.name}
                      onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                    />
                  </div>

                  <div className="form-group">
                    <label className="form-label">القسم أو التصنيف</label>
                    <select 
                      className="form-select"
                      value={formData.category}
                      onChange={(e) => setFormData({ ...formData, category: e.target.value })}
                    >
                      {categories.map(c => (
                        <option key={c.id} value={c.id}>{c.emoji} {c.name}</option>
                      ))}
                    </select>
                  </div>

                  <div className="form-group">
                    <label className="form-label">مستوى التكلفة</label>
                    <select 
                      className="form-select"
                      value={formData.costTier}
                      onChange={(e) => setFormData({ ...formData, costTier: e.target.value })}
                    >
                      <option value="budget">🟢 اقتصادي (على قد الإيد)</option>
                      <option value="medium">🟡 متوسط (معقول)</option>
                      <option value="deluxe">🟣 مميز (عزومات وتدليع)</option>
                    </select>
                  </div>

                  <div className="form-group">
                    <label className="form-label">التكلفة التقديرية (بالجنيه المصري)</label>
                    <input 
                      type="number" 
                      className="form-input" 
                      value={formData.estimatedCost}
                      onChange={(e) => setFormData({ ...formData, estimatedCost: parseFloat(e.target.value) || 0 })}
                    />
                  </div>

                  <div className="form-group">
                    <label className="form-label">عدد الأفراد (الحصص)</label>
                    <input 
                      type="number" 
                      className="form-input" 
                      value={formData.servings}
                      onChange={(e) => setFormData({ ...formData, servings: parseInt(e.target.value) || 1 })}
                    />
                  </div>

                  <div className="form-group">
                    <label className="form-label">وقت التجهيز (بالدقائق)</label>
                    <input 
                      type="number" 
                      className="form-input" 
                      value={formData.prepTimeMinutes}
                      onChange={(e) => setFormData({ ...formData, prepTimeMinutes: parseInt(e.target.value) || 0 })}
                    />
                  </div>

                  <div className="form-group">
                    <label className="form-label">وقت الطبخ على النار (بالدقائق)</label>
                    <input 
                      type="number" 
                      className="form-input" 
                      value={formData.cookTimeMinutes}
                      onChange={(e) => setFormData({ ...formData, cookTimeMinutes: parseInt(e.target.value) || 0 })}
                    />
                  </div>

                  <div className="form-group">
                    <label className="form-label">السعرات الحرارية التقديرية</label>
                    <input 
                      type="number" 
                      className="form-input" 
                      value={formData.calories}
                      onChange={(e) => setFormData({ ...formData, calories: parseInt(e.target.value) || 0 })}
                    />
                  </div>

                  <div className="form-group form-full">
                    <label className="form-label">وصف مختصر يفتح النفس</label>
                    <textarea 
                      rows="2"
                      className="form-textarea"
                      placeholder="وصف مميز للطبق ولماذا يحبه الجميع..."
                      value={formData.description}
                      onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                    />
                  </div>

                  {/* Image Upload Section */}
                  <div className="form-group form-full">
                    <label className="form-label">صورة الأكلة أو الطبق *</label>
                    <input 
                      type="file" 
                      ref={fileInputRef} 
                      accept="image/*" 
                      style={{ display: 'none' }} 
                      onChange={handleImageUpload} 
                    />

                    <div 
                      onClick={() => !uploadingImage && fileInputRef.current?.click()}
                      style={{
                        border: '2px dashed #ffc078',
                        borderRadius: 'var(--radius-md)',
                        padding: '24px 16px',
                        textAlign: 'center',
                        background: 'rgba(232, 89, 12, 0.03)',
                        cursor: 'pointer',
                        transition: 'all 0.2s ease',
                        display: 'flex',
                        flexDirection: 'column',
                        alignItems: 'center',
                        justifyContent: 'center',
                        gap: 10
                      }}
                    >
                      {uploadingImage ? (
                        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 10, padding: 16 }}>
                          <RefreshCw size={32} className="spin" color="var(--primary)" />
                          <span style={{ fontSize: 14, fontWeight: 700, color: 'var(--primary)' }}>جاري رفع الصورة إلى السيرفر...</span>
                        </div>
                      ) : formData.imageUrl ? (
                        <div style={{ width: '100%', position: 'relative' }}>
                          <img 
                            src={formData.imageUrl} 
                            alt="Preview" 
                            style={{ width: '100%', maxHeight: 240, objectFit: 'cover', borderRadius: 'var(--radius-sm)' }} 
                          />
                          <div style={{ marginTop: 10, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 12 }}>
                            <span style={{ fontSize: 13, color: 'var(--success)', fontWeight: 700 }}>✅ تم رفع صورتك بنجاح</span>
                            <button 
                              type="button" 
                              className="btn btn-secondary btn-sm"
                              onClick={(e) => {
                                e.stopPropagation();
                                fileInputRef.current?.click();
                              }}
                            >
                              <UploadCloud size={14} /> تغيير الصورة
                            </button>
                          </div>
                        </div>
                      ) : (
                        <>
                          <div style={{
                            width: 58,
                            height: 58,
                            borderRadius: '50%',
                            background: 'white',
                            display: 'flex',
                            alignItems: 'center',
                            justifyContent: 'center',
                            color: 'var(--primary)',
                            boxShadow: '0 4px 14px rgba(232, 89, 12, 0.15)'
                          }}>
                            <UploadCloud size={30} />
                          </div>
                          <div>
                            <h5 style={{ fontSize: 16, fontWeight: 800, color: 'var(--primary)', marginBottom: 4 }}>
                              انقر هنا لرفع صورة وصفتك الخاصة من جهازك
                            </h5>
                            <p style={{ fontSize: 12.5, color: 'var(--text-secondary)' }}>
                              يدعم صيغ JPG، PNG، WebP، أو GIF (حتى 15 ميجابايت)
                            </p>
                          </div>
                        </>
                      )}
                    </div>

                    <div style={{ marginTop: 10, display: 'flex', alignItems: 'center', gap: 8 }}>
                      <span style={{ fontSize: 12, color: 'var(--text-secondary)' }}>أو أدخل رابط إنترنت خارجي:</span>
                      <input 
                        type="text" 
                        placeholder="https://example.com/image.jpg"
                        className="form-input" 
                        style={{ flex: 1, padding: '6px 12px', fontSize: 12.5 }}
                        value={formData.imageUrl}
                        onChange={(e) => setFormData({ ...formData, imageUrl: e.target.value })}
                      />
                    </div>
                  </div>

                  {/* Ingredients Section */}
                  <div className="form-group form-full" style={{ marginTop: 12 }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 8 }}>
                      <label className="form-label">المقادير والمكونات</label>
                      <button 
                        type="button" 
                        className="btn btn-secondary btn-sm"
                        onClick={() => setFormData({
                          ...formData,
                          ingredients: [...formData.ingredients, { name: '', amount: '', notes: '' }]
                        })}
                      >
                        <Plus size={14} /> أضف مكوّن
                      </button>
                    </div>

                    {formData.ingredients.map((ing, idx) => (
                      <div key={idx} className="dynamic-row">
                        <input 
                          type="text"
                          placeholder="اسم المكون (مثال: أرز مصري)"
                          className="form-input"
                          value={ing.name}
                          onChange={(e) => {
                            const newIngs = [...formData.ingredients];
                            newIngs[idx].name = e.target.value;
                            setFormData({ ...formData, ingredients: newIngs });
                          }}
                        />
                        <input 
                          type="text"
                          placeholder="الكمية (مثال: 2 كوب)"
                          className="form-input"
                          style={{ maxWidth: 160 }}
                          value={ing.amount}
                          onChange={(e) => {
                            const newIngs = [...formData.ingredients];
                            newIngs[idx].amount = e.target.value;
                            setFormData({ ...formData, ingredients: newIngs });
                          }}
                        />
                        {formData.ingredients.length > 1 && (
                          <button 
                            type="button"
                            className="btn btn-danger btn-sm"
                            onClick={() => {
                              const newIngs = formData.ingredients.filter((_, i) => i !== idx);
                              setFormData({ ...formData, ingredients: newIngs });
                            }}
                          >
                            <Trash2 size={14} />
                          </button>
                        )}
                      </div>
                    ))}
                  </div>

                  {/* Steps Section */}
                  <div className="form-group form-full" style={{ marginTop: 12 }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 8 }}>
                      <label className="form-label">خطوات التحضير</label>
                      <button 
                        type="button" 
                        className="btn btn-secondary btn-sm"
                        onClick={() => setFormData({
                          ...formData,
                          steps: [...formData.steps, '']
                        })}
                      >
                        <Plus size={14} /> أضف خطوة
                      </button>
                    </div>

                    {formData.steps.map((step, idx) => (
                      <div key={idx} className="dynamic-row">
                        <span style={{ fontWeight: 700, width: 24, textAlign: 'center', color: 'var(--primary)' }}>{idx + 1}.</span>
                        <input 
                          type="text"
                          placeholder={`الخطوة ${idx + 1}...`}
                          className="form-input"
                          value={step}
                          onChange={(e) => {
                            const newSteps = [...formData.steps];
                            newSteps[idx] = e.target.value;
                            setFormData({ ...formData, steps: newSteps });
                          }}
                        />
                        {formData.steps.length > 1 && (
                          <button 
                            type="button"
                            className="btn btn-danger btn-sm"
                            onClick={() => {
                              const newSteps = formData.steps.filter((_, i) => i !== idx);
                              setFormData({ ...formData, steps: newSteps });
                            }}
                          >
                            <Trash2 size={14} />
                          </button>
                        )}
                      </div>
                    ))}
                  </div>
                </div>
              </div>

              <div className="modal-footer">
                <button type="button" className="btn btn-secondary" onClick={() => setRecipeModalOpen(false)}>
                  إلغاء
                </button>
                <button type="submit" className="btn btn-primary">
                  {editingRecipe ? 'حفظ التعديلات' : 'إضافة الوصفة الآن'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Modal: View Details */}
      {viewRecipeModal && (
        <div className="modal-overlay" onClick={() => setViewRecipeModal(null)}>
          <div className="modal-dialog" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h3>{viewRecipeModal.name}</h3>
              <button className="modal-close-btn" onClick={() => setViewRecipeModal(null)}>
                <X size={20} />
              </button>
            </div>
            <div className="modal-body">
              <img 
                src={viewRecipeModal.imageUrl} 
                alt={viewRecipeModal.name}
                style={{ width: '100%', height: 260, objectFit: 'cover', borderRadius: 'var(--radius-md)', marginBottom: 16 }}
              />
              <p style={{ fontSize: 15, color: 'var(--text-secondary)', marginBottom: 20 }}>{viewRecipeModal.description}</p>
              
              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 12, marginBottom: 24, textAlign: 'center' }}>
                <div style={{ background: 'var(--bg)', padding: 12, borderRadius: 'var(--radius-sm)' }}>
                  <div style={{ fontWeight: 800, color: 'var(--primary)', fontSize: 18 }}>{viewRecipeModal.estimatedCost} ج.م</div>
                  <div style={{ fontSize: 12, color: 'var(--text-secondary)' }}>التكلفة التقديرية</div>
                </div>
                <div style={{ background: 'var(--bg)', padding: 12, borderRadius: 'var(--radius-sm)' }}>
                  <div style={{ fontWeight: 800, color: 'var(--primary)', fontSize: 18 }}>{viewRecipeModal.prepTimeMinutes + viewRecipeModal.cookTimeMinutes} دقيقة</div>
                  <div style={{ fontSize: 12, color: 'var(--text-secondary)' }}>إجمالي الوقت</div>
                </div>
                <div style={{ background: 'var(--bg)', padding: 12, borderRadius: 'var(--radius-sm)' }}>
                  <div style={{ fontWeight: 800, color: 'var(--primary)', fontSize: 18 }}>{viewRecipeModal.calories}</div>
                  <div style={{ fontSize: 12, color: 'var(--text-secondary)' }}>سعرة حرارية</div>
                </div>
              </div>

              <h4 style={{ fontSize: 16, fontWeight: 800, marginBottom: 10, color: 'var(--primary)' }}>المكونات ({viewRecipeModal.ingredients?.length || 0}):</h4>
              <ul style={{ paddingRight: 20, marginBottom: 20 }}>
                {viewRecipeModal.ingredients?.map((ing, i) => (
                  <li key={i} style={{ marginBottom: 4, fontSize: 14 }}>
                    <strong>{ing.name}</strong>: {ing.amount}
                  </li>
                ))}
              </ul>

              <h4 style={{ fontSize: 16, fontWeight: 800, marginBottom: 10, color: 'var(--primary)' }}>طريقة التحضير:</h4>
              <ol style={{ paddingRight: 20 }}>
                {viewRecipeModal.steps?.map((step, i) => (
                  <li key={i} style={{ marginBottom: 8, fontSize: 14, lineHeight: 1.6 }}>
                    {step}
                  </li>
                ))}
              </ol>
            </div>
          </div>
        </div>
      )}

      {/* Modal: Add Category */}
      {categoryModalOpen && (
        <div className="modal-overlay" onClick={() => setCategoryModalOpen(false)}>
          <div className="modal-dialog" style={{ maxWidth: 520 }} onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h3>
                <Tags size={22} color="var(--primary)" />
                <span>إضافة قسم جديد للمطبخ</span>
              </h3>
              <button className="modal-close-btn" onClick={() => setCategoryModalOpen(false)}>
                <X size={20} />
              </button>
            </div>

            <form onSubmit={handleSaveCategory}>
              <div className="modal-body">
                <div className="form-group" style={{ marginBottom: 16 }}>
                  <label className="form-label">اسم القسم أو التصنيف *</label>
                  <input 
                    type="text"
                    required
                    placeholder="مثال: أكلات بحرية، مشويات، مقبلات، شوربات..."
                    className="form-input"
                    value={categoryFormData.name}
                    onChange={(e) => {
                      const name = e.target.value;
                      setCategoryFormData(prev => ({
                        ...prev,
                        name: name,
                        id: prev.idManual ? prev.id : name.trim().toLowerCase().replace(/\s+/g, '_').replace(/[^a-z0-9_]/g, '') || prev.id
                      }));
                    }}
                  />
                </div>

                <div className="form-group" style={{ marginBottom: 16 }}>
                  <label className="form-label">أيقونة القسم (رمز تعبيري Emoji) *</label>
                  <div style={{ display: 'flex', gap: 10, alignItems: 'center' }}>
                    <input 
                      type="text"
                      className="form-input"
                      style={{ width: 80, fontSize: 24, textAlign: 'center' }}
                      value={categoryFormData.emoji}
                      onChange={(e) => setCategoryFormData({ ...categoryFormData, emoji: e.target.value })}
                    />
                    <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap' }}>
                      {['🍲', '🥩', '🐟', '🍗', '🍕', '🍔', '🥗', '🍰', '🥐', '🥙', '🍜', '🌮', '🥣', '🥘'].map(em => (
                        <button
                          key={em}
                          type="button"
                          className="btn btn-secondary btn-sm"
                          style={{ fontSize: 18, padding: '4px 8px' }}
                          onClick={() => setCategoryFormData({ ...categoryFormData, emoji: em })}
                        >
                          {em}
                        </button>
                      ))}
                    </div>
                  </div>
                </div>

                <div className="form-group" style={{ marginBottom: 16 }}>
                  <label className="form-label">معرّف القسم بالإنجليزي (ID) - اختياري</label>
                  <input 
                    type="text"
                    placeholder="مثال: seafood, grills, soups (يتم توليده تلقائياً إذا ترك فارغاً)"
                    className="form-input"
                    value={categoryFormData.id}
                    onChange={(e) => setCategoryFormData({ ...categoryFormData, id: e.target.value, idManual: true })}
                  />
                  <small style={{ color: 'var(--text-secondary)', fontSize: 11, marginTop: 4, display: 'block' }}>
                    يستخدم لربط الأكلات بالتصنيف برمجياً
                  </small>
                </div>

                <div className="form-group">
                  <label className="form-label">وصف مختصر للقسم</label>
                  <textarea 
                    rows="3"
                    placeholder="مثال: أشهى أطباق الأسماك والجمبري والمأكولات البحرية الطازجة..."
                    className="form-textarea"
                    value={categoryFormData.description}
                    onChange={(e) => setCategoryFormData({ ...categoryFormData, description: e.target.value })}
                  />
                </div>
              </div>

              <div className="modal-footer">
                <button type="button" className="btn btn-secondary" onClick={() => setCategoryModalOpen(false)}>
                  إلغاء
                </button>
                <button type="submit" className="btn btn-primary">
                  حفظ وإضافة القسم
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Modal: Delete Confirmation */}
      {deleteConfirmId && (
        <div className="modal-overlay" onClick={() => setDeleteConfirmId(null)}>
          <div className="modal-dialog" style={{ maxWidth: 440 }} onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h3 style={{ color: 'var(--danger)' }}><AlertCircle size={20} /> تأكيد الحذف</h3>
              <button className="modal-close-btn" onClick={() => setDeleteConfirmId(null)}>
                <X size={20} />
              </button>
            </div>
            <div className="modal-body">
              <p style={{ fontSize: 15 }}>هل أنت متأكد من رغبتك في حذف هذه الوصفة من التطبيق والباك إند نهائياً؟</p>
            </div>
            <div className="modal-footer">
              <button className="btn btn-secondary" onClick={() => setDeleteConfirmId(null)}>إلغاء</button>
              <button className="btn btn-danger" onClick={() => handleDeleteRecipe(deleteConfirmId)}>نعم، احذف الوصفة</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
