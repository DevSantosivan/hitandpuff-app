import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hit_and_puff/presentation/cubit/login/login_cubit.dart';
import 'package:hit_and_puff/presentation/cubit/login/login_state.dart';
import 'package:hit_and_puff/presentation/screen/login/loginScreen.dart';
import 'package:hit_and_puff/presentation/screen/pos/pos_screen.dart';
import 'package:hit_and_puff/presentation/widgets/SplashScreen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    context.read<LoginCubit>().checkSession(); // 🔥 IMPORTANT
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
        if (state is LoginInitial || state is LoginLoading) {
          return const SplashScreen();
        }

        if (state is LoginSuccess) {
          return PosMobileScreen(branch: state.branch);
        }

        // LoginFailure / Logged out
        return const LoginScreen();
      },
    );
  }
}
