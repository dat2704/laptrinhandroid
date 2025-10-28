
import 'package:cua_hang_thoi_trang/domain/models/user_model.dart';
import 'package:cua_hang_thoi_trang/presentation/admin/bloc/user_management_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ManageUsersPage extends StatelessWidget {
  const ManageUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Người dùng'),
      ),
      body: BlocBuilder<UserManagementBloc, UserManagementState>(
        builder: (context, state) {
          if (state is UserManagementLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is UserManagementLoaded) {
            if (state.users.isEmpty) {
              return const Center(child: Text('Chưa có người dùng nào.'));
            }
            return _buildUsersList(context, state.users);
          }
          if (state is UserManagementError) {
            return Center(child: Text('Lỗi: ${state.message}'));
          }
          return const Center(child: Text('Đã có lỗi xảy ra.'));
        },
      ),
    );
  }

  Widget _buildUsersList(BuildContext context, List<UserModel> users) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(user.email.substring(0, 1).toUpperCase()),
            ),
            title: Text(user.email),
            subtitle: Text('Ngày tạo: ${DateFormat('dd/MM/yyyy').format(user.createdAt.toDate())}'),
            trailing: DropdownButton<String>(
              value: user.role,
              items: const [
                DropdownMenuItem(value: 'user', child: Text('User')),
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
              ],
              onChanged: (newRole) {
                if (newRole != null && newRole != user.role) {
                  // Gửi sự kiện cập nhật vai trò
                  context.read<UserManagementBloc>().add(UpdateUserRole(user.id, newRole));
                }
              },
            ),
          ),
        );
      },
    );
  }
}
