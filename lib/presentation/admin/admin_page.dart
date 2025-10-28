
import 'package:cua_hang_thoi_trang/data/repositories/order_repository.dart';
import 'package:cua_hang_thoi_trang/presentation/admin/bloc/admin_order_bloc.dart';
import 'package:cua_hang_thoi_trang/presentation/admin/manage_orders_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildAdminMenuItem(
            context,
            icon: Icons.receipt_long,
            title: 'Quản lý Đơn hàng',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (context) => AdminOrderBloc(
                      orderRepository: context.read<OrderRepository>(),
                    )..add(LoadAllOrders()),
                    child: const ManageOrdersPage(),
                  ),
                ),
              );
            },
          ),
          // Add other admin functionalities here in the future
        ],
      ),
    );
  }

  Widget _buildAdminMenuItem(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
