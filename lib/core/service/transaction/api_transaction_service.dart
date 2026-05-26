import 'package:hit_and_puff/data/model/branch_model.dart';
import 'package:hit_and_puff/data/model/product_model.dart';
import 'package:hit_and_puff/data/model/transaction_fetch_model.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionService {
  static final supabase = Supabase.instance.client;

  /// GET USER NAME FROM PROFILES
  static Future<String> getCurrentUserName() async {
    final user = supabase.auth.currentUser;

    if (user == null) return "Unknown";

    final res = await supabase
        .from('profiles')
        .select('name')
        .eq('auth_id', user.id)
        .maybeSingle(); // 👈 IMPORTANT FIX

    return res?['name'] ?? "Unknown";
  }

  /// SUBMIT SALE
  static Future<void> submitSale({
    required BranchModel branch,
    required List<Map<String, dynamic>> cartItems,
  }) async {
    try {
      final user = supabase.auth.currentUser;

      // 👇 GET CASHIER NAME
      final cashierName = await getCurrentUserName();

      // TOTAL SALES
      final total = cartItems.fold<double>(0, (sum, item) {
        final product = item['product'] as ProductModel;
        final qty = item['qty'] as int;
        return sum + (product.price * qty);
      });

      // TOTAL COST
      final totalCost = cartItems.fold<double>(0, (sum, item) {
        final product = item['product'] as ProductModel;
        final qty = item['qty'] as int;
        return sum + (product.cost * qty);
      });

      // INSERT TRANSACTION HEADER
      final txRes = await supabase
          .from('transactions')
          .insert({
            'branch_id': branch.id,
            'branch_name': branch.name,

            // 👇 USER INFO ADDED
            'user_id': user?.id,
            'cashier_name': cashierName,

            'total_amount': total,
            'total_cost': totalCost,
          })
          .select('id')
          .single();

      final txId = txRes['id'].toString();

      // TRANSACTION ITEMS
      final items = cartItems.map((item) {
        final p = item['product'] as ProductModel;
        final qty = item['qty'] as int;

        return {
          'transaction_id': txId,
          'product_id': p.id,
          'product_name': p.name,
          'category': p.category,
          'price': p.price,
          'cost': p.cost,
          'qty': qty,
          'subtotal': p.price * qty,
          'total_cost': p.cost * qty,
        };
      }).toList();

      await supabase.from('transaction_items').insert(items);

      print("✅ Transaction Success");
      print("TX ID: $txId");
      print("Cashier: $cashierName");
    } catch (e) {
      print("❌ Submit Sale Error: $e");
      rethrow;
    }
  }

  /// FETCH NORMAL TRANSACTIONS
  static Future<List<TransactionFetchModel>> fetchTransactionsByBranch(
    String branchId,
  ) async {
    try {
      final res = await supabase
          .from('transactions')
          .select('''
          id,
          branch_id,
          branch_name,
          user_id,
          cashier_name,
          total_amount,
          total_cost,
          created_at,
          is_returned,
          transaction_items (
            product_id,
            product_name,
            category,
            price,
            qty,
            subtotal,
            total_cost
          )
        ''')
          .eq('branch_id', branchId)
          .eq('is_returned', false)
          .order('created_at', ascending: false);

      return (res as List)
          .map((e) => TransactionFetchModel.fromJson(e))
          .toList();
    } catch (e) {
      print("❌ Fetch Transactions Error: $e");
      return [];
    }
  }

  /// FETCH TRANSACTIONS
  // static Future<List<TransactionFetchModel>> fetchTransactionsByBranch(
  //   String branchId, {
  //   DateTime? date,
  // }) async {
  //   final String? day = date != null
  //       ? DateFormat('yyyy-MM-dd').format(date)
  //       : null;

  //   final query = supabase
  //       .from('transactions')
  //       .select('''
  //         id,
  //         branch_id,
  //         branch_name,
  //         user_id,
  //         cashier_name,
  //         total_amount,
  //         total_cost,
  //         created_at,
  //         transaction_items (
  //           product_id,
  //           product_name,
  //           category,
  //           price,
  //           qty,
  //           subtotal,
  //           total_cost
  //         )
  //       ''')
  //       .match({'branch_id': branchId});

  //   if (day != null) {
  //     query.filter('created_at', 'eq', day);
  //   }

  //   final res = await query.order('created_at', ascending: false);

  //   return (res as List).map((e) => TransactionFetchModel.fromJson(e)).toList();
  // }

  /// FETCH RETURNED TRANSACTIONS
  static Future<List<TransactionFetchModel>> fetchReturnedTransactionsByBranch(
    String branchId,
  ) async {
    try {
      final res = await supabase
          .from('transactions')
          .select('''
          id,
          branch_id,
          branch_name,
          user_id,
          cashier_name,
          total_amount,
          total_cost,
          created_at,
          is_returned,
          transaction_items (
            product_id,
            product_name,
            category,
            price,
            qty,
            subtotal,
            total_cost
          )
        ''')
          .eq('branch_id', branchId)
          .eq('is_returned', true)
          .order('created_at', ascending: false);

      return (res as List)
          .map((e) => TransactionFetchModel.fromJson(e))
          .toList();
    } catch (e) {
      print("❌ Fetch Returned Error: $e");
      return [];
    }
  }

  /// UPDATE RETURN STATUS
  static Future<void> updateReturnedStatus({
    required String transactionId,
    required bool isReturned,
  }) async {
    try {
      await supabase
          .from('transactions')
          .update({'is_returned': isReturned})
          .eq('id', transactionId);

      print("✅ Return status updated");
    } catch (e) {
      print("❌ Update Return Error: $e");
      throw Exception(e.toString());
    }
  }
}
