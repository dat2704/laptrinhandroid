
import 'package:cua_hang_thoi_trang/domain/models/cart_item_model.dart';
import 'package:cua_hang_thoi_trang/presentation/cart/bloc/cart_bloc.dart';
import 'package:cua_hang_thoi_trang/presentation/checkout/checkout_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

void showCartSidePanel(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black45,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (BuildContext buildContext, Animation<double> animation, Animation<double> secondaryAnimation) {
      return Align(
        alignment: Alignment.centerRight,
        child: Material(
          child: Container(
            width: 400, // Adjust width as needed
            height: double.infinity,
            color: Colors.white,
            child: const CartSidePanel(),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      );
    },
  );
}

class CartSidePanel extends StatelessWidget {
  const CartSidePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CartBloc, CartState>(
      listener: (context, state) {
        // Listener logic can be added here if needed
      },
      builder: (context, state) {
        if (state is CartLoadInProgress) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is CartLoadSuccess) {
          return Column(
            children: [
              _buildHeader(context),
              if (state.items.isEmpty)
                Expanded(child: _buildEmptyCart())
              else
                Expanded(
                  child: Column(
                  children: [
                    Expanded(child: _buildCartContent(context, state.items)),
                    _buildCheckoutSection(context, state),
                  ],
                 ), 
                ),
            ],
          );
        }
        return const Center(child: Text('Đã có lỗi xảy ra!'));
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Giỏ Hàng', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text('Giỏ hàng của bạn đang trống', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildCartContent(BuildContext context, List<CartItem> items) {
     return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: items.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final item = items[index];
        final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Image.network(
                item.product.imageUrl,
                width: 60, 
                height: 80, 
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 60,
                    height: 80,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported, color: Colors.grey),
                  );
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    if (item.selectedSize != null) Text('Size: ${item.selectedSize}'),
                    if (item.selectedColor != null) Text('Màu: ${item.selectedColor}'),
                    Text(currencyFormatter.format(item.product.price)),
                  ],
                ),
              ),
              _buildQuantityControls(context, item),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuantityControls(BuildContext context, CartItem item) {
    return Row(
      children: [
        _buildSmallIconButton(context, Icons.remove, () {
          // If quantity is 1, ask for removal, otherwise decrease.
          if (item.quantity == 1) {
            _showRemoveConfirmationDialog(context, item);
          } else {
            context.read<CartBloc>().add(CartItemQuantityUpdated(item, item.quantity - 1));
          }
        }),
        Text('${item.quantity}', style: const TextStyle(fontSize: 16)),
        _buildSmallIconButton(context, Icons.add, () {
          context.read<CartBloc>().add(CartItemQuantityUpdated(item, item.quantity + 1));
        }),
        _buildSmallIconButton(context, Icons.delete, () {
          _showRemoveConfirmationDialog(context, item);
        }, color: Colors.red),
      ],
    );
  }

  Widget _buildSmallIconButton(BuildContext context, IconData icon, VoidCallback onPressed, {Color? color}) {
    return SizedBox(
      width: 32,
      height: 32,
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 18, color: color),
        onPressed: onPressed,
      ),
    );
  }

  void _showRemoveConfirmationDialog(BuildContext context, CartItem item) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: const Text('Bạn có chắc muốn xóa sản phẩm này khỏi giỏ hàng?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
              onPressed: () {
                context.read<CartBloc>().add(CartItemRemoved(item));
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCheckoutSection(BuildContext context, CartLoadSuccess state) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tổng cộng:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text(currencyFormatter.format(state.total), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red)),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.of(context).pop(); // Close panel
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutPage()));
            },
            child: const Text('Thanh Toán'),
          ),
        ],
      ),
    );
  }
}
