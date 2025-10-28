
import 'package:cua_hang_thoi_trang/domain/models/order_model.dart';
import 'package:cua_hang_thoi_trang/presentation/orders/order_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cua_hang_thoi_trang/presentation/orders/bloc/orders_bloc.dart';
import 'package:intl/intl.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // No AppBar needed here as it's part of a TabView
      body: BlocBuilder<OrdersBloc, OrdersState>(
        builder: (context, state) {
          if (state is OrdersLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is OrdersLoaded) {
            if (state.orders.isEmpty) {
              return const Center(
                child: Text(
                  'Bạn chưa có đơn hàng nào.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: state.orders.length,
              itemBuilder: (context, index) {
                final order = state.orders[index];
                return _buildOrderCard(context, order);
              },
            );
          }
          if (state is OrdersError) {
            return Center(child: Text('Lỗi: ${state.message}'));
          }
          return const Center(child: Text('Đã xảy ra lỗi không mong muốn.'));
        },
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final dateFormatter = DateFormat('dd/MM/yyyy HH:mm');

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Đơn hàng #${order.id?.substring(0, 8) ?? 'N/A'}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  order.status,
                  style: TextStyle(
                    color: _getStatusColor(order.status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow('Ngày đặt', dateFormatter.format(order.orderDate.toDate())),
            const SizedBox(height: 8),
            _buildInfoRow('Tổng tiền', currencyFormatter.format(order.totalAmount)),
            if (order.discount != null && order.discount!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoRow('Mã giảm giá', order.discount!),
            ],
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderDetailPage(order: order),
                    ),
                  );
                },
                child: const Text('Xem Chi Tiết'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'đã hủy':
        return Colors.red;
      case 'đang giao':
        return Colors.blue;
      case 'hoàn thành':
        return Colors.green;
      default: // 'chờ xác nhận'
        return Colors.orange;
    }
  }
}
