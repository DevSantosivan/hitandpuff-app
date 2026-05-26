import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hit_and_puff/presentation/cubit/product/product_cubit.dart';
import 'package:hit_and_puff/presentation/cubit/login/login_cubit.dart';
import 'package:hit_and_puff/presentation/cubit/transaction/transacntion_cubit.dart';
import 'package:hit_and_puff/presentation/screen/login/authGate.dart';
import 'package:hit_and_puff/data/model/branch_model.dart';
import 'package:hit_and_puff/core/service/login/api_login_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constant/colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://qvckzoitzelzypcvtexo.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF2Y2t6b2l0emVsenlwY3Z0ZXhvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk2OTYyNzYsImV4cCI6MjA4NTI3MjI3Nn0.Mw0J2iEMab1sZsVWz26QYcChFu6xW_pfDyRtl7YsPPU',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ProductCubit()),
        BlocProvider(
          create: (_) {
            final cubit = LoginCubit(
              repository: LoginRepository(supabase: Supabase.instance.client),
            );
            cubit.checkSession();
            return cubit;
          },
        ),

        BlocProvider(create: (_) => TransactionCubit()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Hit & Puff POS',
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AppColors.backgroundDark,
          primaryColor: AppColors.primary,
          colorScheme: ColorScheme.dark(
            primary: AppColors.primary,
            secondary: AppColors.accent,
            surface: AppColors.card,
            background: AppColors.backgroundDark,
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: AppColors.accent,
          ),
          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: Colors.white),
            bodyLarge: TextStyle(color: Colors.white),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey[900],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            hintStyle: const TextStyle(color: Colors.grey),
          ),
        ),
        home: const AuthGate(),
      ),
    );
  }
}
