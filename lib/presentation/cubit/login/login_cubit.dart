import 'package:bloc/bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hit_and_puff/core/service/login/api_login_service.dart';
import 'package:hit_and_puff/presentation/cubit/login/login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginRepository repository;

  LoginCubit({required this.repository}) : super(LoginInitial());

  /// CHECK SESSION
  Future<void> checkSession() async {
    emit(LoginLoading());

    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      emit(LoginFailure(message: "Not logged in"));
      return;
    }

    try {
      final branch = await repository.getBranchByAuthId(user.id);
      emit(LoginSuccess(branch: branch));
    } catch (e) {
      emit(LoginFailure(message: e.toString()));
    }
  }

  Future<void> login(String email, String password) async {
    emit(LoginLoading());

    try {
      final result = await repository.loginBranch(email, password);

      final branch = await repository.getBranchById(result.branchId);

      emit(LoginSuccess(branch: branch));
    } catch (e) {
      emit(LoginFailure(message: e.toString()));
    }
  }

  /// LOGOUT
  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
    emit(LoginFailure(message: "Logged out"));
  }
}
