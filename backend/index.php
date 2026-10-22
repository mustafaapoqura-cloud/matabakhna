<?php
// backend/index.php
require_once __DIR__ . '/config/cors.php';
require_once __DIR__ . '/config/database.php';

// Test connection and auto-seed
try {
    $db = Database::getConnection();
    $recipeCount = (int)$db->query("SELECT COUNT(*) FROM recipes")->fetchColumn();
    $status = 'healthy';
} catch (Exception $e) {
    $status = 'error: ' . $e->getMessage();
    $recipeCount = 0;
}

echo json_encode([
    'app' => 'طبختنا - Matabakhna Backend API',
    'version' => '1.0.0',
    'status' => $status,
    'database' => 'SQLite (matabakhna.db)',
    'total_recipes' => $recipeCount,
    'endpoints' => [
        'GET /api/recipes.php' => 'قائمة الوصفات والفلترة بالبحث والتصنيف والميزانية',
        'GET /api/recipes.php?id={id}' => 'تفاصيل وصفة محددة',
        'POST /api/recipes.php' => 'إضافة وصفة جديدة',
        'PUT /api/recipes.php?id={id}' => 'تحديث وصفة',
        'DELETE /api/recipes.php?id={id}' => 'حذف وصفة',
        'GET /api/categories.php' => 'قائمة التصنيفات وعدد الوصفات',
        'GET /api/stats.php' => 'إحصائيات وتحليلات لوحة التحكم',
        'GET /api/weekly_plan.php' => 'جدول الأسبوع والوجبات المقترحة',
        'GET /api/budget.php' => 'بيانات ميزانية الأسرة',
        'GET /api/shopping.php' => 'قائمة مشتريات السوق',
        'GET /api/settings.php' => 'إعدادات التطبيق وبانرات التنبيه',
    ],
    'timestamp' => date('c')
], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
