import 'package:cua_hang_thoi_trang/domain/models/cart_item_model.dart';
import 'package:cua_hang_thoi_trang/presentation/cart/bloc/cart_bloc.dart';
import 'package:cua_hang_thoi_trang/presentation/checkout/checkout_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ hàng của bạn'),
        centerTitle: true,
        elevation: 1,
      ),
      body: BlocConsumer<CartBloc, CartState>(
        listener: (context, state) {
          if (state is CartLoadSuccess && state.discountMessage != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.discountMessage!),
                  backgroundColor: state.appliedDiscount != null ? Colors.green : Colors.red,
                ),
              );
          }
        },
        builder: (context, state) {
          if (state is CartLoadInProgress) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CartLoadSuccess) {
            if (state.items.isEmpty) {
              return _buildEmptyCart(context);
            } else {
              return _buildCartContent(context, state.items);
            }
          }
          return const Center(child: Text('Đã có lỗi xảy ra!'));
        },
      ),
      bottomNavigationBar: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is CartLoadSuccess && state.items.isNotEmpty) {
            return _buildCheckoutSection(context, state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          const Text('Giỏ hàng của bạn đang trống', style: TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('TIẾP TỤC MUA SẮM'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(BuildContext context, List<CartItem> items) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(item.product.imageUrl, width: 80, height: 100, fit: BoxFit.cover),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      if (item.selectedSize != null) Text('Size: ${item.selectedSize}'),
                      const SizedBox(height: 4),
                      Text(currencyFormatter.format(item.product.price), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                    ],
                  ),
                ),
                _buildQuantityControls(context, item),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuantityControls(BuildContext context, CartItem item) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(icon: const Icon(Icons.add_circle_outline), iconSize: 22, onPressed: () => context.read<CartBloc>().add(CartItemQuantityUpdated(item, item.quantity + 1))),
        Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        IconButton(icon: const Icon(Icons.remove_circle_outline), iconSize: 22, onPressed: () => context.read<CartBloc>().add(CartItemQuantityUpdated(item, item.quantity - 1))),
        IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), iconSize: 22, onPressed: () => context.read<CartBloc>().add(CartItemRemoved(item))),
      ],
    );
  }

  Widget _buildCheckoutSection(BuildContext context, CartLoadSuccess state) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final discountCodeController = TextEditingController();

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 0, blurRadius: 10)],
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tạm tính:', style: TextStyle(fontSize: 16)),
              Text(currencyFormatter.format(state.subtotal), style: const TextStyle(fontSize: 16)),
            ],
          ),
          if (state.appliedDiscount != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Giảm giá (${state.appliedDiscount!.code}):', style: const TextStyle(fontSize: 16, color: Colors.green)),
                  Text('-${currencyFormatter.format(state.subtotal - state.total)}', style: const TextStyle(fontSize: 16, color: Colors.green)),
                ],
              ),
            ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tổng cộng:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(currencyFormatter.format(state.total), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: discountCodeController,
                  decoration: const InputDecoration(
                    hintText: 'Nhập mã giảm giá',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  final code = discountCodeController.text.trim();
                  if (code.isNotEmpty) {
                    context.read<CartBloc>().add(CartDiscountApplied(code));
                  }
                },
                child: const Text('Áp dụng'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutPage())),
            child: const Text('THANH TOÁN'),
          ),
        ],
      ),
    );
  }
}
