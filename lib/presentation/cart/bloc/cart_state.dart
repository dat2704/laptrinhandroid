part of 'cart_bloc.dart';

@immutable
abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartLoadInProgress extends CartState {}

class CartLoadSuccess extends CartState {
  final List<CartItem> items;
  final Discount? appliedDiscount;
  final String? discountMessage; // For success or error messages

  const CartLoadSuccess({
    this.items = const [],
    this.appliedDiscount,
    this.discountMessage,
  });

  double get subtotal =>
      items.fold(0, (sum, item) => sum + (item.product.price * item.quantity));

  double get total {
    if (appliedDiscount != null) {
      return subtotal * (1 - appliedDiscount!.percentage / 100);
    }
    return subtotal;
  }

  @override
  List<Object?> get props => [items, appliedDiscount, total, discountMessage];

  CartLoadSuccess copyWith({
    List<CartItem>? items,
    ValueGetter<Discount?>? appliedDiscount,
    ValueGetter<String?>? discountMessage,
  }) {
    return CartLoadSuccess(
      items: items ?? this.items,
      appliedDiscount:
          appliedDiscount != null ? appliedDiscount() : this.appliedDiscount,
      discountMessage:
          discountMessage != null ? discountMessage() : this.discountMessage,
    );
  }
}

class CartLoadFailure extends CartState {}
