import 'cart_item_model.dart';

class TransactionModel {
  final List<CartItemModel> items;
  final double total;
  final DateTime date;

  TransactionModel({
    required this.items,
    required this.total,
    required this.date,
  });
}
