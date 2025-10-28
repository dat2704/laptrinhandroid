
part of 'admin_order_bloc.dart';

abstract class AdminOrderEvent extends Equatable {
  const AdminOrderEvent();

  @override
  List<Object> get props => [];
}

class LoadAllOrders extends AdminOrderEvent {}

class UpdateStatus extends AdminOrderEvent {
  final String orderId;
  final String newStatus;

  const UpdateStatus(this.orderId, this.newStatus);

  @override
  List<Object> get props => [orderId, newStatus];
}
