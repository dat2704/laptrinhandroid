
import 'package:cua_hang_thoi_trang/data/repositories/category_repository.dart';
import 'package:cua_hang_thoi_trang/data/repositories/discount_repository.dart';
import 'package:cua_hang_thoi_trang/data/repositories/order_repository.dart';
import 'package:cua_hang_thoi_trang/data/repositories/user_repository.dart';
import 'package:cua_hang_thoi_trang/presentation/admin/admin_dashboard_page.dart';
import 'package:cua_hang_thoi_trang/presentation/admin/bloc/admin_order_bloc.dart';
import 'package:cua_hang_thoi_trang/presentation/admin/bloc/user_management_bloc.dart';
import 'package:cua_hang_thoi_trang/presentation/admin/manage_categories/bloc/category_bloc.dart';
import 'package:cua_hang_thoi_trang/presentation/admin/manage_categories/manage_categories_page.dart';
import 'package:cua_hang_thoi_trang/presentation/admin/manage_discounts/manage_discounts_page.dart';
import 'package:cua_hang_thoi_trang/presentation/admin/manage_orders_page.dart';
import 'package:cua_hang_thoi_trang/presentation/admin/manage_users_page.dart';
import 'package:cua_hang_thoi_trang/presentation/auth/bloc/auth_bloc.dart';
import 'package:cua_hang_thoi_trang/presentation/discount/bloc/discount_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.black),
            child: Text('DStore ADMIN', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_outlined),
            title: const Text('Sản phẩm'),
            onTap: () {
              if (ModalRoute.of(context)?.settings.name == '/') {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminDashboardPage()),
                );
              }
            },
          ),
           ListTile(
            leading: const Icon(Icons.category_outlined),
            title: const Text('Quản lý Loại sản phẩm'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (_) => CategoryBloc(
                      categoryRepository: context.read<CategoryRepository>(),
                    )..add(LoadCategories()),
                    child: const ManageCategoriesPage(),
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long_outlined),
            title: const Text('Quản lý Đơn hàng'),
            onTap: () {
               Navigator.pop(context); 
               Navigator.push(
                 context,
                 MaterialPageRoute(builder: (_) => BlocProvider(
                   create: (_) => AdminOrderBloc(orderRepository: context.read<OrderRepository>())..add(LoadAllOrders()),
                   child: const ManageOrdersPage(),
                 )),
               );
            },
          ),
          ListTile(
            leading: const Icon(Icons.people_alt_outlined),
            title: const Text('Quản lý Người dùng'),
            onTap: () {
               Navigator.pop(context); 
               Navigator.push(
                 context,
                 MaterialPageRoute(builder: (_) => BlocProvider(
                   create: (_) => UserManagementBloc(userRepository: context.read<UserRepository>())..add(LoadUsers()),
                   child: const ManageUsersPage(),
                 )),
               );
            },
          ),
          ListTile(
            leading: const Icon(Icons.discount_outlined),
            title: const Text('Quản lý mã giảm giá'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (_) => DiscountBloc(
                      discountRepository: context.read<DiscountRepository>(),
                    )..add(LoadDiscounts()),
                    child: const ManageDiscountsPage(),
                  ),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Đăng xuất'),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Xác nhận đăng xuất'),
                  content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
                  actions: [
                    TextButton(
                      child: const Text('Hủy'),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                    TextButton(
                      child: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
                      onPressed: () {
                        context.read<AuthBloc>().add(SignOutRequested());
                        Navigator.of(ctx).pop();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
