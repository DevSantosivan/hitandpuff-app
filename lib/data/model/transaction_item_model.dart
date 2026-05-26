class TransactionItemModel {
  final int productId;
  final String productName;
  final String category;
  final double price;
  final int qty;
  final double subtotal;
  final bool isReturned; // ✅ ADDED THIS

  TransactionItemModel({
    required this.isReturned, // ✅ ADDED THIS
    required this.productId,
    required this.productName,
    required this.category,
    required this.price,
    required this.qty,
    required this.subtotal,
  });

  factory TransactionItemModel.fromJson(Map<String, dynamic> json) {
    return TransactionItemModel(
      productId: json['product_id'] as int,
      productName: json['product_name'] as String,
      category: json['category'] as String,
      price: (json['price'] as num).toDouble(),
      qty: json['qty'] as int,
      subtotal: (json['subtotal'] as num).toDouble(),
      isReturned: json['is_returned'] ?? false, // ✅ ADDED THIS
    );
  }
}
