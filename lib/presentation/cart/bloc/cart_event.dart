part of 'cart_bloc.dart';

@immutable
abstract class CartEvent {}

// Sự kiện khi khởi tạo giỏ hàng
class CartStarted extends CartEvent {}

// Sự kiện khi thêm một sản phẩm vào giỏ
class CartItemAdded extends CartEvent {
  final CartItem item;
  CartItemAdded(this.item);
}

// Sự kiện khi xóa một sản phẩm khỏi giỏ
class CartItemRemoved extends CartEvent {
  final CartItem item;
  CartItemRemoved(this.item);
}

// Sự kiện khi thay đổi số lượng sản phẩm
class CartItemQuantityUpdated extends CartEvent {
  final CartItem item;
  final int quantity;
  CartItemQuantityUpdated(this.item, this.quantity);
}

// Sự kiện để xóa sạch giỏ hàng sau khi đặt hàng
class CartCleared extends CartEvent {}

// Sự kiện khi áp dụng mã giảm giá
class CartDiscountApplied extends CartEvent {
  final String code;
  CartDiscountApplied(this.code);
}
