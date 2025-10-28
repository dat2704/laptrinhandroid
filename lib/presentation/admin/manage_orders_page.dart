
import 'package:cua_hang_thoi_trang/domain/models/order_model.dart';
import 'package:cua_hang_thoi_trang/presentation/admin/bloc/admin_order_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ManageOrdersPage extends StatelessWidget {
  const ManageOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Đơn hàng'),
      ),
      body: BlocConsumer<AdminOrderBloc, AdminOrderState>(
        listener: (context, state) {
          if (state is AdminOrdersError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi: ${state.message}'), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is AdminOrdersLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AdminOrdersLoaded) {
            if (state.orders.isEmpty) {
              return const Center(child: Text('Chưa có đơn hàng nào.'));
            }
            return _buildOrdersList(context, state.orders);
          }
          // It will still show the list on error, but with a message
          return const Center(child: Text('Đã có lỗi xảy ra.'));
        },
      ),
    );
  }

  Widget _buildOrdersList(BuildContext context, List<OrderModel> orders) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<AdminOrderBloc>().add(LoadAllOrders());
      },
      child: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text('ĐH #${order.id?.substring(0, 8)} - ${order.customerName}'),
              subtitle: Text(
                'Ngày đặt: ${DateFormat('dd/MM/yyyy HH:mm').format(order.orderDate.toDate())}\n'
                'Tổng tiền: ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(order.totalAmount)}',
              ),
              trailing: Text(
                order.status,
                style: TextStyle(color: _getStatusColor(order.status), fontWeight: FontWeight.bold),
              ),
              isThreeLine: true,
              onTap: () {
                _showUpdateStatusDialog(context, order);
              },
            ),
          );
        },
      ),
    );
  }

  void _showUpdateStatusDialog(BuildContext context, OrderModel order) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        String currentStatus = order.status;
        final List<String> statuses = ['Chờ xác nhận', 'Đang giao', 'Hoàn thành', 'Đã hủy'];

        return AlertDialog(
          title: Text('Cập nhật trạng thái đơn hàng #${order.id?.substring(0, 8)}'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return DropdownButton<String>(
                value: currentStatus,
                isExpanded: true,
                items: statuses.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    currentStatus = newValue!;
                  });
                },
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Cập nhật'),
              onPressed: () {
                // Use the new event here
                context.read<AdminOrderBloc>().add(UpdateStatus(order.id!, currentStatus));
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Đang giao':
        return Colors.blue;
      case 'Hoàn thành':
        return Colors.green;
      case 'Đã hủy':
        return Colors.red;
      default: // 'Chờ xác nhận'
        return Colors.orange;
    }
  }
}
