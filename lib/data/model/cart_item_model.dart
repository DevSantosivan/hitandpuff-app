import 'product_model.dart';

class CartItemModel {
  final ProductModel product;
  int qty;

  CartItemModel({required this.product, this.qty = 1});

  double get totalPrice => (product.price * qty).toDouble();
}
