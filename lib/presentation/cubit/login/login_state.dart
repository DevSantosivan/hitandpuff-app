import 'package:hit_and_puff/data/model/branch_model.dart';

abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final BranchModel branch;

  LoginSuccess({required this.branch});
}

class LoginFailure extends LoginState {
  final String message;

  LoginFailure({required this.message});
}
