
import 'package:cua_hang_thoi_trang/presentation/admin/admin_dashboard_page.dart';
import 'package:cua_hang_thoi_trang/presentation/auth/bloc/auth_bloc.dart';
import 'package:cua_hang_thoi_trang/presentation/auth/login_page.dart';
import 'package:cua_hang_thoi_trang/presentation/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // Nếu là admin, vào trang quản trị sản phẩm
        if (state is AuthenticatedAdmin) {
          // Sửa lỗi ở đây: Chỉ cần trả về trang Dashboard.
          // Trang Dashboard giờ đã tự quản lý ProductBloc của riêng nó.
          return const AdminDashboardPage();
        }
        // Nếu là user, vào trang chủ mua sắm
        if (state is AuthenticatedUser) {
          return const HomePage();
        }
        // Nếu chưa đăng nhập
        if (state is Unauthenticated) {
          return const LoginPage();
        }
        // Các trạng thái khác (loading, initial)
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
