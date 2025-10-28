
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cua_hang_thoi_trang/data/repositories/order_repository.dart';
import 'package:cua_hang_thoi_trang/domain/models/cart_item_model.dart';
import 'package:cua_hang_thoi_trang/domain/models/order_model.dart';
import 'package:cua_hang_thoi_trang/presentation/auth/bloc/auth_bloc.dart';
import 'package:cua_hang_thoi_trang/presentation/cart/bloc/cart_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _voucherController;
  String _paymentMethod = 'Tiền mặt';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _voucherController = TextEditingController();

    // Auto-fill user info if available
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      _nameController.text = authState.userModel.displayName ?? '';
      _addressController.text = authState.userModel.address ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _voucherController.dispose();
    super.dispose();
  }

  void _placeOrder(BuildContext context) async {
    final authState = context.read<AuthBloc>().state;
    final cartState = context.read<CartBloc>().state;

    if (authState is! Authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để đặt hàng.')),
      );
      return;
    }

    if (cartState is! CartLoadSuccess || cartState.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Giỏ hàng của bạn đang trống.')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final itemsAsMaps = cartState.items.map((item) => item.toMap()).toList();

      final newOrder = OrderModel(
        userId: authState.userModel.id,
        items: itemsAsMaps,
        totalAmount: cartState.total,
        customerName: _nameController.text.trim(),
        customerPhone: _phoneController.text.trim(),
        customerAddress: _addressController.text.trim(),
        paymentMethod: _paymentMethod,
        orderDate: Timestamp.now(),
        discount: cartState.appliedDiscount?.code,
      );

      try {
        // Use the OrderRepository from the context
        await context.read<OrderRepository>().addOrder(newOrder);
        context.read<CartBloc>().add(CartCleared());

        if (!mounted) return;

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('Đặt hàng thành công!'),
            content: const Text('Cảm ơn bạn đã mua hàng. Chúng tôi sẽ xử lý đơn hàng của bạn sớm nhất có thể.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi đặt hàng: $e')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán'),
        centerTitle: true,
      ),
      body: BlocConsumer<CartBloc, CartState>(
        listener: (context, state) {
          if (state is CartLoadSuccess && state.discountMessage != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.discountMessage!)));
          }
        },
        builder: (context, state) {
          if (state is CartLoadSuccess) {
            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildShippingInfoForm(),
                const SizedBox(height: 24),
                _buildVoucherSection(),
                const SizedBox(height: 24),
                _buildPaymentMethodSelector(),
                const SizedBox(height: 24),
                _buildOrderSummary(state),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          onPressed: _isLoading ? null : () => _placeOrder(context),
          child: _isLoading
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
              : const Text('ĐẶT HÀNG NGAY'),
        ),
      ),
    );
  }

  Widget _buildShippingInfoForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Thông tin người nhận', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildTextFormField(_nameController, 'Họ và tên'),
          const SizedBox(height: 12),
          _buildTextFormField(_phoneController, 'Số điện thoại', keyboardType: TextInputType.phone),
          const SizedBox(height: 12),
          _buildTextFormField(_addressController, 'Địa chỉ nhận hàng', maxLines: 2),
        ],
      ),
    );
  }

  TextFormField _buildTextFormField(TextEditingController controller, String label, {TextInputType? keyboardType, int? maxLines = 1}) {
    return TextFormField(
            controller: controller,
            decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator: (value) => value == null || value.trim().isEmpty ? 'Trường này không được để trống' : null,
          );
  }

  Widget _buildVoucherSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Mã giảm giá', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _voucherController,
                decoration: const InputDecoration(
                  labelText: 'Nhập mã giảm giá',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                final code = _voucherController.text.trim();
                if (code.isNotEmpty) {
                  context.read<CartBloc>().add(CartDiscountApplied(code));
                }
              },
              child: const Text('Áp dụng'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Phương thức thanh toán', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        RadioListTile<String>(
          title: const Text('Thanh toán khi nhận hàng (COD)'),
          value: 'Tiền mặt',
          groupValue: _paymentMethod,
          onChanged: (value) => setState(() => _paymentMethod = value!),
        ),
        RadioListTile<String>(
          title: const Text('Chuyển khoản ngân hàng'),
          value: 'Chuyển khoản',
          groupValue: _paymentMethod,
          onChanged: (value) => setState(() => _paymentMethod = value!),
        ),
      ],
    );
  }

  Widget _buildOrderSummary(CartLoadSuccess state) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final subtotal = state.subtotal;
    final total = state.total;
    final discount = state.appliedDiscount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tóm tắt đơn hàng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...state.items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text('${item.product.name} (x${item.quantity})')),
                    Text(currencyFormatter.format(item.product.price * item.quantity))
                  ]),
            )).toList(),
        const Divider(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [const Text('Tạm tính'), Text(currencyFormatter.format(subtotal))]),
        if (discount != null) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Giảm giá (${discount.code} - ${discount.percentage}%)'),
              Text('-${currencyFormatter.format(subtotal - total)}', style: const TextStyle(color: Colors.green)),
            ],
          ),
        ],
        const Divider(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [const Text('Phí vận chuyển'), Text('Miễn phí', style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold))]),
        const Divider(height: 24),
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Thành tiền', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red)),
              Text(currencyFormatter.format(total), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red))
            ]),
      ],
    );
  }
}
