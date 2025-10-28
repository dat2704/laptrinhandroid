
import 'package:cua_hang_thoi_trang/data/repositories/auth_repository.dart';
import 'package:cua_hang_thoi_trang/data/repositories/category_repository.dart';
import 'package:cua_hang_thoi_trang/data/repositories/discount_repository.dart';
import 'package:cua_hang_thoi_trang/data/repositories/order_repository.dart';
import 'package:cua_hang_thoi_trang/data/repositories/product_repository.dart';
import 'package:cua_hang_thoi_trang/data/repositories/user_repository.dart';
import 'package:cua_hang_thoi_trang/firebase_options.dart';
import 'package:cua_hang_thoi_trang/presentation/auth/auth_wrapper.dart';
import 'package:cua_hang_thoi_trang/presentation/auth/bloc/auth_bloc.dart';
import 'package:cua_hang_thoi_trang/presentation/cart/bloc/cart_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => AuthRepository()),
        RepositoryProvider(create: (context) => UserRepository()),
        RepositoryProvider(create: (context) => ProductRepository()),
        RepositoryProvider(create: (context) => CategoryRepository()),
        RepositoryProvider(create: (context) => DiscountRepository()),
        RepositoryProvider(create: (context) => OrderRepository()), // Add this line
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
              userRepository: context.read<UserRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => CartBloc(
              discountRepository: context.read<DiscountRepository>(),
            )..add(CartStarted()),
          ),
        ],
        child: MaterialApp(
          title: 'DStore',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: 'Poppins',
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFFFCC00),
              primary: const Color(0xFFFFCC00),
              secondary: const Color(0xFF111111),
              background: const Color(0xFFFFFFFF),
            ),
            useMaterial3: true,
          ),
          home: const AuthWrapper(),
        ),
      ),
    );
  }
}
