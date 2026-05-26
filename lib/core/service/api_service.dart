import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/model/product_model.dart';

class ApiService {
  static final SupabaseClient supabase = Supabase.instance.client;

  /// GET CURRENT USER BRANCH ID
  static Future<String> getCurrentUserBranchId() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception("No logged in user");
    }

    final res = await supabase
        .from('profiles')
        .select('branch_id')
        .eq('auth_id', user.id) // ✅ FIXED: auth_id not id
        .single();

    final branchId = res['branch_id'];

    if (branchId == null) {
      throw Exception("Branch ID not found in profile");
    }

    return branchId.toString();
  }

  static Future<List<ProductModel>> fetchProductsFromProfileBranch() async {
    try {
      final branchId = await getCurrentUserBranchId();

      final response = await supabase
          .from('products')
          .select()
          .eq('branch_id', branchId); // keep string-safe

      if (response == null || (response as List).isEmpty) {
        return [];
      }

      return (response as List).map((e) => ProductModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception("Failed to fetch products: $e");
    }
  }

  static Stream<List<ProductModel>> streamProductsFromProfileBranch() async* {
    final branchId = await getCurrentUserBranchId();

    final stream = supabase
        .from('products')
        .stream(primaryKey: ['id'])
        .eq('branch_id', branchId);

    await for (final data in stream) {
      yield data.map((e) => ProductModel.fromJson(e)).toList();
    }
  }

  /// RETURN TRANSACTION (EXCLUDED FROM PROFIT CALCULATION)

  /// OPTIONAL: DEBUG PRODUCTS (pang-check lang)
  static Future<void> debugProducts() async {
    final branchId = await getCurrentUserBranchId();
    print("CURRENT BRANCH ID: $branchId");

    final res = await supabase
        .from('products')
        .select()
        .eq('branch_id', branchId);

    print("PRODUCTS RAW: $res");
  }
}
