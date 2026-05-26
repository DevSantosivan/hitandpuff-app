import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hit_and_puff/core/constant/colors.dart';
import 'package:hit_and_puff/presentation/cubit/login/login_cubit.dart';
import 'package:hit_and_puff/presentation/cubit/login/login_state.dart';
import 'package:hit_and_puff/presentation/screen/pos/pos_screen.dart';
import 'package:hit_and_puff/core/service/login/api_login_service.dart';
import 'package:hit_and_puff/data/model/branch_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool loadingBranch = false;
  bool _obscurePassword = true;

  bool _emailError = false;
  bool _passwordError = false;

  void _login() {
    setState(() {
      _emailError = _emailCtrl.text.trim().isEmpty;
      _passwordError = _passwordCtrl.text.trim().isEmpty;
    });

    if (_emailError || _passwordError) return;

    context.read<LoginCubit>().login(
      _emailCtrl.text.trim(),
      _passwordCtrl.text.trim(),
    );
  }

  Future<BranchModel?> _getBranch(String branchId) async {
    final repo = LoginRepository(supabase: Supabase.instance.client);
    try {
      return await repo.getBranchById(branchId);
    } catch (e) {
      debugPrint("Failed to fetch branch: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),
      body: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is LoginFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }

          if (state is LoginSuccess) {
            setState(() => loadingBranch = true);

            final branch = state.branch;

            setState(() => loadingBranch = false);

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => PosMobileScreen(branch: branch),
              ),
              (_) => false,
            );
          }
        },
        builder: (context, state) {
          final loading = state is LoginLoading || loadingBranch;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// LOGO (CIRCLE)
                  ClipOval(
                    child: Image.asset(
                      'assets/logo.jpg',
                      width: 110,
                      height: 110,
                      fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Hit & Puff POS",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    "Branch Login",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),

                  const SizedBox(height: 30),

                  /// LOGIN CARD
                  Form(
                    key: _formKey,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          /// EMAIL
                          TextFormField(
                            controller: _emailCtrl,
                            style: const TextStyle(color: Colors.white),
                            onChanged: (_) {
                              if (_emailError) {
                                setState(() => _emailError = false);
                              }
                            },
                            decoration: InputDecoration(
                              hintText: "Email",
                              hintStyle: const TextStyle(color: Colors.white54),
                              prefixIcon: const Icon(
                                Icons.email,
                                color: Colors.white54,
                              ),
                              suffixIcon: _emailError
                                  ? const Icon(
                                      Icons.error,
                                      color: Colors.redAccent,
                                    )
                                  : null,
                              filled: true,
                              fillColor: const Color(0xFF2A2A2A),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          /// PASSWORD
                          TextFormField(
                            controller: _passwordCtrl,
                            obscureText: _obscurePassword,
                            style: const TextStyle(color: Colors.white),
                            onChanged: (_) {
                              if (_passwordError) {
                                setState(() => _passwordError = false);
                              }
                            },
                            decoration: InputDecoration(
                              hintText: "Password",
                              hintStyle: const TextStyle(color: Colors.white54),
                              prefixIcon: const Icon(
                                Icons.lock,
                                color: Colors.white54,
                              ),
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_passwordError)
                                    const Icon(
                                      Icons.error,
                                      color: Colors.redAccent,
                                    ),
                                  IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.white54,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              filled: true,
                              fillColor: const Color(0xFF2A2A2A),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          /// LOGIN BUTTON
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: loading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: loading
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.black,
                                      ),
                                    )
                                  : const Text(
                                      "LOGIN",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
