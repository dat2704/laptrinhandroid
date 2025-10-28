
import 'package:cua_hang_thoi_trang/data/repositories/discount_repository.dart';
import 'package:cua_hang_thoi_trang/data/repositories/order_repository.dart';
import 'package:cua_hang_thoi_trang/presentation/auth/bloc/auth_bloc.dart';
import 'package:cua_hang_thoi_trang/presentation/auth/login_page.dart';
import 'package:cua_hang_thoi_trang/presentation/discount/bloc/discount_bloc.dart';
import 'package:cua_hang_thoi_trang/presentation/discount/discount_page.dart';
import 'package:cua_hang_thoi_trang/presentation/orders/bloc/orders_bloc.dart';
import 'package:cua_hang_thoi_trang/presentation/orders/orders_page.dart';
import 'package:cua_hang_thoi_trang/presentation/profile/change_password_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
        }
      },
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Tài khoản của tôi'),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 1,
            bottom: const TabBar(
              labelColor: Colors.black,
              indicatorColor: Colors.black,
              tabs: [
                Tab(text: 'HỒ SƠ'),
                Tab(text: 'ĐƠN HÀNG'),
                Tab(text: 'CÀI ĐẶT'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              const ProfileInfoTab(),
              // Provide the OrdersBloc to the OrdersPage
              BlocProvider(
                create: (context) => OrdersBloc(
                  orderRepository: context.read<OrderRepository>(),
                  authBloc: context.read<AuthBloc>(),
                )..add(LoadOrders()),
                child: const OrdersPage(),
              ),
              const SettingsTab(),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileInfoTab extends StatefulWidget {
  const ProfileInfoTab({super.key});

  @override
  State<ProfileInfoTab> createState() => _ProfileInfoTabState();
}

class _ProfileInfoTabState extends State<ProfileInfoTab> {
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    String? initialName;
    String? initialAddress;

    if (authState is Authenticated) {
      initialName = authState.userModel.displayName;
      initialAddress = authState.userModel.address;
    }

    _nameController = TextEditingController(text: initialName ?? '');
    _addressController = TextEditingController(text: initialAddress ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _saveProfile(String userId) {
    context.read<AuthBloc>().add(ProfileUpdateRequested(
          userId: userId,
          displayName: _nameController.text,
          address: _addressController.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          if (_nameController.text != (state.userModel.displayName ?? '')) {
            _nameController.text = state.userModel.displayName ?? '';
          }
          if (_addressController.text != (state.userModel.address ?? '')) {
            _addressController.text = state.userModel.address ?? '';
          }
        }
        if (state is AuthError) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text("Lỗi: ${state.message}")),
            );
        }
      },
      builder: (context, state) {
        if (state is Authenticated) {
          final userModel = state.userModel;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Họ và tên', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Nhập họ và tên của bạn',
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Địa chỉ', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Nhập địa chỉ của bạn',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                const Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(userModel.email, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: () => _saveProfile(userModel.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    ),
                    child: state is AuthLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('LƯU THAY ĐỔI'),
                  ),
                ),
              ],
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(8.0),
      children: [
        ListTile(
          leading: const Icon(Icons.discount_outlined),
          title: const Text('Mã giảm giá'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => DiscountBloc(
                    discountRepository: DiscountRepository(),
                  )..add(LoadDiscounts()),
                  child: const DiscountPage(),
                ),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.lock_outline),
          title: const Text('Đổi mật khẩu'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
            );
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
          onTap: () {
            context.read<AuthBloc>().add(SignOutRequested());
          },
        ),
      ],
    );
  }
}
