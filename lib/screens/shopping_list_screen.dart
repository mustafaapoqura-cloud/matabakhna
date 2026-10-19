import 'package:flutter/material.dart';
import '../models/shopping_item.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  List<ShoppingItem> _items = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() {
    setState(() {
      _items = StorageService.getShoppingList();
    });
  }

  void _toggleBought(int index) async {
    final item = _items[index];
    _items[index] = item.copyWith(isBought: !item.isBought);
    await StorageService.saveShoppingList(_items);
    setState(() {});
  }

  void _deleteItem(int index) async {
    _items.removeAt(index);
    await StorageService.saveShoppingList(_items);
    setState(() {});
  }

  void _clearBought() async {
    _items.removeWhere((i) => i.isBought);
    await StorageService.saveShoppingList(_items);
    setState(() {});
  }

  void _showAddItemDialog() {
    final titleController = TextEditingController();
    final qtyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة طلب للسوبرماركت'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'اسم الغرض (مثلاً: سكر، زيت، لبن)',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: qtyController,
              decoration: const InputDecoration(
                labelText: 'الكمية (اختياري، مثلاً: 2 كيلو)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text.trim();
              if (title.isNotEmpty) {
                final newItem = ShoppingItem(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: title,
                  quantity: qtyController.text.trim(),
                  category: 'مشتريات يدوية',
                  isBought: false,
                );
                _items.insert(0, newItem);
                await StorageService.saveShoppingList(_items);
                setState(() {});
                if (!context.mounted) return;
                Navigator.pop(context);
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final boughtCount = _items.where((i) => i.isBought).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('قائمة مشتريات السوق'),
        actions: [
          if (boughtCount > 0)
            IconButton(
              icon: const Icon(Icons.cleaning_services_rounded, color: Colors.red),
              tooltip: 'مسح الأغراض المشتراة',
              onPressed: _clearBought,
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddItemDialog,
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'إضافة طلب',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: _items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart_outlined, size: 70, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'قائمة المشتريات فارغة!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'يمكنكِ إضافة مقادير أي أكلة مباشرة من صفحة الوصفة\nأو إضافة طلباتك يدوياً بالزر في الأسفل',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Summary Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  color: AppTheme.primary.withAlpha(15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'إجمالي الأغراض: ${_items.length}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        'تم شراؤه: $boughtCount من ${_items.length}',
                        style: const TextStyle(
                          color: AppTheme.success,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                // Items List
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                    itemCount: _items.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: item.isBought ? Colors.grey.shade100 : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: item.isBought ? Colors.grey.shade300 : AppTheme.borderLight,
                          ),
                        ),
                        child: ListTile(
                          leading: Checkbox(
                            value: item.isBought,
                            activeColor: AppTheme.success,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            onChanged: (val) => _toggleBought(index),
                          ),
                          title: Text(
                            item.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              decoration: item.isBought ? TextDecoration.lineThrough : null,
                              color: item.isBought ? Colors.grey : AppTheme.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            item.category,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (item.quantity.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withAlpha(20),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    item.quantity,
                                    style: const TextStyle(
                                      color: AppTheme.primaryDark,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                                onPressed: () => _deleteItem(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
