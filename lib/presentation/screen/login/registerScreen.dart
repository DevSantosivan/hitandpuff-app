// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:hit_and_puff/presentation/cubit/login/login_cubit.dart';

// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});

//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   final _formKey = GlobalKey<FormState>();

//   final _nameCtrl = TextEditingController();
//   final _emailCtrl = TextEditingController();
//   final _passwordCtrl = TextEditingController();
//   final _locationCtrl = TextEditingController();

//   @override
//   void dispose() {
//     _nameCtrl.dispose();
//     _emailCtrl.dispose();
//     _passwordCtrl.dispose();
//     _locationCtrl.dispose();
//     super.dispose();
//   }

//   void _submit() {
//     if (_formKey.currentState!.validate()) {
//       context.read<LoginCubit>().register(
//         name: _nameCtrl.text.trim(),
//         email: _emailCtrl.text.trim(),
//         password: _passwordCtrl.text.trim(),
//         location: _locationCtrl.text.trim().isEmpty
//             ? null
//             : _locationCtrl.text.trim(),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Create Branch Account")),
//       body: BlocConsumer<LoginCubit, LoginState>(
//         listener: (context, state) {
//           if (state is LoginFailure) {
//             ScaffoldMessenger.of(
//               context,
//             ).showSnackBar(SnackBar(content: Text(state.message)));
//           }

//           if (state is LoginSuccess) {
//             ScaffoldMessenger.of(
//               context,
//             ).showSnackBar(const SnackBar(content: Text("Account created!")));

//             Navigator.pop(context); // balik login or home
//           }
//         },
//         builder: (context, state) {
//           final loading = state is LoginLoading;

//           return Padding(
//             padding: const EdgeInsets.all(16),
//             child: Form(
//               key: _formKey,
//               child: ListView(
//                 children: [
//                   const SizedBox(height: 20),

//                   TextFormField(
//                     controller: _nameCtrl,
//                     decoration: const InputDecoration(
//                       labelText: "Branch Name",
//                       border: OutlineInputBorder(),
//                     ),
//                     validator: (v) =>
//                         v == null || v.isEmpty ? "Required" : null,
//                   ),

//                   const SizedBox(height: 12),

//                   TextFormField(
//                     controller: _emailCtrl,
//                     decoration: const InputDecoration(
//                       labelText: "Email",
//                       border: OutlineInputBorder(),
//                     ),
//                     validator: (v) =>
//                         v == null || v.isEmpty ? "Required" : null,
//                   ),

//                   const SizedBox(height: 12),

//                   TextFormField(
//                     controller: _passwordCtrl,
//                     obscureText: true,
//                     decoration: const InputDecoration(
//                       labelText: "Password",
//                       border: OutlineInputBorder(),
//                     ),
//                     validator: (v) =>
//                         v != null && v.length < 6 ? "Min 6 characters" : null,
//                   ),

//                   const SizedBox(height: 12),

//                   TextFormField(
//                     controller: _locationCtrl,
//                     decoration: const InputDecoration(
//                       labelText: "Location (optional)",
//                       border: OutlineInputBorder(),
//                     ),
//                   ),

//                   const SizedBox(height: 24),

//                   SizedBox(
//                     height: 50,
//                     child: ElevatedButton(
//                       onPressed: loading ? null : _submit,
//                       child: loading
//                           ? const CircularProgressIndicator()
//                           : const Text("Create Account"),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
