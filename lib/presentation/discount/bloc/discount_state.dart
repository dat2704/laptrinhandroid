part of 'discount_bloc.dart';

@immutable
abstract class DiscountState extends Equatable {
  const DiscountState();

  @override
  List<Object> get props => [];
}

class DiscountInitial extends DiscountState {}

class DiscountLoading extends DiscountState {}

class DiscountLoaded extends DiscountState {
  final List<Discount> discounts;

  const DiscountLoaded(this.discounts);

  @override
  List<Object> get props => [discounts];
}

class DiscountError extends DiscountState {
  final String message;

  const DiscountError(this.message);

  @override
  List<Object> get props => [message];
}
