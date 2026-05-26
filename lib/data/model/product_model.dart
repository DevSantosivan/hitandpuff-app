class ProductModel {
  final int id;
  final String name;
  final double price;
  final double cost; // 👈 ADD THIS
  final String category;
  final int stock;
  final String branchId;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.cost,
    required this.category,
    required this.stock,
    required this.branchId,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      cost: (json['cost'] as num).toDouble(), // 👈 ADD THIS
      category: json['category'],
      stock: json['stock'] ?? 0,
      branchId: json['branch_id'] as String,
    );
  }
}
