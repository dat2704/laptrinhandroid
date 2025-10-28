
part of 'admin_order_bloc.dart';

abstract class AdminOrderState extends Equatable {
  const AdminOrderState();

  @override
  List<Object> get props => [];
}

class AdminOrdersLoading extends AdminOrderState {}

class AdminOrdersLoaded extends AdminOrderState {
  final List<OrderModel> orders;

  const AdminOrdersLoaded(this.orders);

  @override
  List<Object> get props => [orders];
}

class AdminOrdersError extends AdminOrderState {
  final String message;

  const AdminOrdersError(this.message);

  @override
  List<Object> get props => [message];
}
