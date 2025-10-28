part of 'discount_bloc.dart';

@immutable
abstract class DiscountEvent extends Equatable {
  const DiscountEvent();

  @override
  List<Object> get props => [];
}

class LoadDiscounts extends DiscountEvent {}

class _DiscountsUpdated extends DiscountEvent {
  final List<Discount> discounts;

  const _DiscountsUpdated(this.discounts);

  @override
  List<Object> get props => [discounts];
}

class AddDiscount extends DiscountEvent {
  final Discount discount;

  const AddDiscount(this.discount);

  @override
  List<Object> get props => [discount];
}

class UpdateDiscount extends DiscountEvent {
  final Discount discount;

  const UpdateDiscount(this.discount);

  @override
  List<Object> get props => [discount];
}

class DeleteDiscount extends DiscountEvent {
  final String id;

  const DeleteDiscount(this.id);

  @override
  List<Object> get props => [id];
}
