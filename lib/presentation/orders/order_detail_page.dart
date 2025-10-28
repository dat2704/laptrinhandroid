
import 'package:cua_hang_thoi_trang/domain/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderDetailPage extends StatelessWidget {
  final OrderModel order;

  const OrderDetailPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final dateFormatter = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết đơn hàng #${order.id?.substring(0, 8)}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle('Thông tin đơn hàng'),
          _buildInfoCard([
            _buildInfoRow('Mã đơn hàng', '#${order.id?.substring(0, 8) ?? 'N/A'}'),
            _buildInfoRow('Ngày đặt', dateFormatter.format(order.orderDate.toDate())),
            _buildInfoRow('Trạng thái', order.status, statusColor: _getStatusColor(order.status)),
          ]),
          const SizedBox(height: 24),
          _buildSectionTitle('Thông tin người nhận'),
          _buildInfoCard([
            _buildInfoRow('Họ và tên', order.customerName),
            _buildInfoRow('Số điện thoại', order.customerPhone),
            _buildInfoRow('Địa chỉ', order.customerAddress, isMultiline: true),
          ]),
          const SizedBox(height: 24),
          _buildSectionTitle('Chi tiết sản phẩm'),
          _buildProductList(currencyFormatter),
          const SizedBox(height: 24),
          _buildTotalSection(currencyFormatter),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? statusColor, bool isMultiline = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(color: Colors.grey))),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w500, color: statusColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(NumberFormat currencyFormatter) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: order.items.map((item) {
          // Safely extract product details from the map
          final productName = item['product']?['name'] ?? 'Sản phẩm không xác định';
          final productPrice = (item['product']?['price'] as num?)?.toDouble() ?? 0.0;
          final imageUrl = item['product']?['imageUrl'] ?? '';
          final quantity = (item['quantity'] as num?)?.toInt() ?? 0;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                imageUrl.isNotEmpty
                    ? Image.network(imageUrl, width: 60, height: 60, fit: BoxFit.cover)
                    : Container(width: 60, height: 60, color: Colors.grey.shade200, child: const Icon(Icons.image_not_supported)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('Số lượng: $quantity'),
                    ],
                  ),
                ),
                Text(currencyFormatter.format(productPrice * quantity)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTotalSection(NumberFormat currencyFormatter) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoRow('Phương thức thanh toán', order.paymentMethod),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Thành tiền', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red)),
                Text(
                  currencyFormatter.format(order.totalAmount),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red),
                ),
              ],
            )
          ],
        ),
      ),
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
