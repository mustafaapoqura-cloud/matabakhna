import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _costController = TextEditingController(text: '120');
  final _servingsController = TextEditingController(text: '4');
  final _prepTimeController = TextEditingController(text: '20');
  final _cookTimeController = TextEditingController(text: '30');
  final _imageUrlController = TextEditingController(
    text: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=800&q=80',
  );

  RecipeCategory _category = RecipeCategory.egyptian;
  CostTier _costTier = CostTier.medium;

  final List<TextEditingController> _ingredientNameControllers = [TextEditingController()];
  final List<TextEditingController> _ingredientAmountControllers = [TextEditingController()];
  final List<TextEditingController> _stepControllers = [TextEditingController()];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _costController.dispose();
    _servingsController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    _imageUrlController.dispose();
    for (var c in _ingredientNameControllers) {
      c.dispose();
    }
    for (var c in _ingredientAmountControllers) {
      c.dispose();
    }
    for (var c in _stepControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addIngredientField() {
    setState(() {
      _ingredientNameControllers.add(TextEditingController());
      _ingredientAmountControllers.add(TextEditingController());
    });
  }

  void _removeIngredientField(int index) {
    if (_ingredientNameControllers.length > 1) {
      setState(() {
        _ingredientNameControllers.removeAt(index);
        _ingredientAmountControllers.removeAt(index);
      });
    }
  }

  void _addStepField() {
    setState(() {
      _stepControllers.add(TextEditingController());
    });
  }

  void _removeStepField(int index) {
    if (_stepControllers.length > 1) {
      setState(() {
        _stepControllers.removeAt(index);
      });
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final ingredients = <RecipeIngredient>[];
    for (int i = 0; i < _ingredientNameControllers.length; i++) {
      final name = _ingredientNameControllers[i].text.trim();
      final amount = _ingredientAmountControllers[i].text.trim();
      if (name.isNotEmpty) {
        ingredients.add(RecipeIngredient(name: name, amount: amount.isEmpty ? 'حسب الرغبة' : amount));
      }
    }

    final steps = _stepControllers
        .map((c) => c.text.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    if (ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إضافة مكون واحد على الأقل')),
      );
      return;
    }

    if (steps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إضافة خطوة واحدة على الأقل في طريقة التحضير')),
      );
      return;
    }

    final newRecipe = Recipe(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      category: _category,
      imageUrl: _imageUrlController.text.trim(),
      description: _descController.text.trim(),
      prepTimeMinutes: int.tryParse(_prepTimeController.text) ?? 20,
      cookTimeMinutes: int.tryParse(_cookTimeController.text) ?? 30,
      servings: int.tryParse(_servingsController.text) ?? 4,
      estimatedCost: double.tryParse(_costController.text) ?? 100.0,
      costTier: _costTier,
      ingredients: ingredients,
      steps: steps,
      isUserAdded: true,
    );

    await StorageService.saveCustomRecipe(newRecipe);

    if (!mounted) return;
    Navigator.pop(context, true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('تمت إضافة وصفتك الخاصة بنجاح! 👩‍🍳'),
          ],
        ),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة وصفة جديدة'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Info
              _buildSectionTitle('المعلومات الأساسية للطبق'),
              const SizedBox(height: 10),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم الأكلة أو الطبق *',
                  hintText: 'مثال: صينية كفتة بالبطاطس في الفرن',
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'يرجى كتابة اسم الطبق' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'وصف قصير للطبق',
                  hintText: 'وصف شهي ومميزات الأكلة...',
                ),
              ),
              const SizedBox(height: 12),

              // Category and Tier
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<RecipeCategory>(
                      initialValue: _category,
                      decoration: const InputDecoration(labelText: 'القسم'),
                      items: RecipeCategory.values.map((c) {
                        return DropdownMenuItem(
                          value: c,
                          child: Text('${c.emoji} ${c.label}', style: const TextStyle(fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _category = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<CostTier>(
                      initialValue: _costTier,
                      decoration: const InputDecoration(labelText: 'مستوى التكلفة'),
                      items: CostTier.values.map((t) {
                        return DropdownMenuItem(
                          value: t,
                          child: Text('${t.icon} ${t.label.split(' ').first}', style: const TextStyle(fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _costTier = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Numbers: Cost, Servings, Times
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _costController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'التكلفة بالجنيه',
                        suffixText: 'ج',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _servingsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'تكفي كم فرد',
                        suffixText: 'أفراد',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _prepTimeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'التحضير',
                        suffixText: 'دقيقة',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _cookTimeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'الطبخ',
                        suffixText: 'دقيقة',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Ingredients
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionTitle('المقادير والمكونات'),
                  TextButton.icon(
                    onPressed: _addIngredientField,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('مكون جديد'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...List.generate(_ingredientNameControllers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _ingredientNameControllers[index],
                          decoration: InputDecoration(
                            hintText: 'اسم المكون (مثال: طماطم)',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _ingredientAmountControllers[index],
                          decoration: InputDecoration(
                            hintText: 'الكمية (مثال: نصف كيلو)',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                      if (_ingredientNameControllers.length > 1)
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                          onPressed: () => _removeIngredientField(index),
                        ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 24),

              // Preparation Steps
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionTitle('طريقة التحضير بالخطوات'),
                  TextButton.icon(
                    onPressed: _addStepField,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('خطوة جديدة'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...List.generate(_stepControllers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: AppTheme.primary,
                        child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _stepControllers[index],
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText: 'اكتبي تفاصيل الخطوة رقم ${index + 1}...',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                      if (_stepControllers.length > 1)
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                          onPressed: () => _removeStepField(index),
                        ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 32),

              ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.check_circle_rounded),
                label: const Text('حفظ الوصفة في طبختنا', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppTheme.textPrimary,
      ),
    );
  }
}
