import 'package:hit_and_puff/data/model/loginresult_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hit_and_puff/data/model/branch_model.dart';

class LoginRepository {
  final SupabaseClient supabase;

  LoginRepository({required this.supabase});

  /// LOGIN (ALL USERS FROM PROFILES)
  Future<LoginResult> loginBranch(String email, String password) async {
    final res = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = res.user;

    if (user == null) {
      throw Exception('Invalid email or password');
    }

    final profile = await supabase
        .from('profiles')
        .select('branch_id, status, role, block_reason')
        .eq('auth_id', user.id)
        .maybeSingle();

    if (profile == null) {
      throw Exception('Account not found');
    }

    final status = (profile['status'] ?? '').toString();

    if (status == 'blocked') {
      throw Exception(profile['block_reason'] ?? 'Blocked account');
    }

    return LoginResult(
      branchId: profile['branch_id'].toString(),
      role: profile['role'] ?? 'cashier',
    );
  }

  /// GET BRANCH INFO
  Future<BranchModel> getBranchById(String branchId) async {
    final res = await supabase
        .from('branches')
        .select()
        .eq('id', branchId)
        .maybeSingle();

    if (res == null) {
      throw Exception('Branch not found');
    }

    return BranchModel.fromJson(res);
  }

  /// GET PROFILE BY AUTH ID (for session restore)
  Future<BranchModel> getBranchByAuthId(String authId) async {
    final profile = await supabase
        .from('profiles')
        .select('branch_id')
        .eq('auth_id', authId)
        .maybeSingle();

    if (profile == null) {
      throw Exception('Profile not found');
    }

    return await getBranchById(profile['branch_id'].toString());
  }

  /// CREATE USER (AUTH ONLY)
  Future<User> createUser({
    required String email,
    required String password,
  }) async {
    final res = await supabase.auth.signUp(email: email, password: password);

    if (res.user == null) {
      throw Exception('Failed to create user');
    }

    return res.user!;
  }

  /// REGISTER BRANCH (ADMIN ONLY)
  Future<BranchModel> registerBranch({
    required String authId,
    required String name,
    required String email,
    String? location,
  }) async {
    final res = await supabase
        .from('branches')
        .insert({
          'auth_id': authId,
          'name': name,
          'email': email,
          'location': location,
          'is_blocked': false,
        })
        .select()
        .single();

    return BranchModel.fromJson(res);
  }
}
