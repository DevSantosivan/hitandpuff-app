import 'package:hit_and_puff/data/model/transaction_item_model.dart';

class TransactionFetchModel {
  final String id;
  final String branchId;
  final String branchName;
  final double totalAmount;
  final DateTime createdAt;
  final bool isReturned; // ✅ BOOLEAN NA
  final List<TransactionItemModel> items;

  TransactionFetchModel({
    required this.isReturned,
    required this.id,
    required this.branchId,
    required this.branchName,
    required this.totalAmount,
    required this.createdAt,
    required this.items,
  });

  factory TransactionFetchModel.fromJson(Map<String, dynamic> json) {
    return TransactionFetchModel(
      id: json['id'].toString(),

      isReturned:
          json['is_returned'] == true ||
          json['is_returned'] == 'true' ||
          json['is_returned'] == 1,

      branchId: json['branch_id'].toString(),
      branchName: json['branch_name'] as String,
      totalAmount: double.tryParse(json['total_amount'].toString()) ?? 0.0,
      createdAt: DateTime.parse(json['created_at'] as String),

      items: (json['transaction_items'] as List<dynamic>)
          .map((e) => TransactionItemModel.fromJson(e))
          .toList(),
    );
  }
}
