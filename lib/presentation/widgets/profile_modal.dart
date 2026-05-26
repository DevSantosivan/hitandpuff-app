// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:hit_and_puff/presentation/cubit/login/login_cubit.dart';
// import 'package:hit_and_puff/core/constant/colors.dart';
// import 'package:hit_and_puff/presentation/cubit/login/login_state.dart';
// import 'package:hit_and_puff/presentation/screen/login/loginScreen.dart';

// class ProfileModal extends StatelessWidget {
//   const ProfileModal({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final loginCubit = context.read<LoginCubit>();

//     // You can fetch branch info dynamically if you store it in LoginCubit
//     final state = loginCubit.state;
//     String branchName = "Hit & Puff";
//     String branchEmail = "branch@example.com";
//     String branchLocation = "San Jose";
//     if (state is LoginSuccess) {
//       branchName = state.branch.name;
//       branchEmail = state.branch.email;
//       branchLocation = state.branch.location ?? "No location";
//     }

//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: const BoxDecoration(
//         color: Colors.black87,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Center(
//             child: Text(
//               "Profile",
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//           const SizedBox(height: 20),

//           Text(
//             "Branch Name: $branchName",
//             style: const TextStyle(color: Colors.white70),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             "Email: $branchEmail",
//             style: const TextStyle(color: Colors.white70),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             "Location: $branchLocation",
//             style: const TextStyle(color: Colors.white70),
//           ),
//           const SizedBox(height: 20),

//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton.icon(
//               onPressed: () {
//                 loginCubit.logout();
//                 Navigator.pushAndRemoveUntil(
//                   context,
//                   MaterialPageRoute(builder: (_) => const LoginScreen()),
//                   (route) => false,
//                 );
//               },
//               icon: const Icon(Icons.logout),
//               label: const Text("Logout"),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.redAccent,
//               ),
//             ),
//           ),

//           const SizedBox(height: 16),
//         ],
//       ),
//     );
//   }
// }
