class ShoppingItem {
  final String id;
  final String title;
  final String quantity;
  final String category;
  final bool isBought;

  ShoppingItem({
    required this.id,
    required this.title,
    this.quantity = '',
    this.category = 'عام',
    this.isBought = false,
  });

  ShoppingItem copyWith({
    String? id,
    String? title,
    String? quantity,
    String? category,
    bool? isBought,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      title: title ?? this.title,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      isBought: isBought ?? this.isBought,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'quantity': quantity,
        'category': category,
        'isBought': isBought,
      };

  factory ShoppingItem.fromJson(Map<String, dynamic> json) => ShoppingItem(
        id: json['id'] as String,
        title: json['title'] as String,
        quantity: json['quantity'] as String? ?? '',
        category: json['category'] as String? ?? 'عام',
        isBought: json['isBought'] as bool? ?? false,
      );
}
