
import 'package:bloc/bloc.dart';
import 'package:cua_hang_thoi_trang/data/repositories/order_repository.dart';
import 'package:cua_hang_thoi_trang/domain/models/order_model.dart';
import 'package:equatable/equatable.dart';

part 'admin_order_event.dart';
part 'admin_order_state.dart';

class AdminOrderBloc extends Bloc<AdminOrderEvent, AdminOrderState> {
  final OrderRepository _orderRepository;

  AdminOrderBloc({required OrderRepository orderRepository})
      : _orderRepository = orderRepository,
        super(AdminOrdersLoading()) {
    on<LoadAllOrders>(_onLoadAllOrders);
    on<UpdateStatus>(_onUpdateStatus);
  }

  void _onLoadAllOrders(LoadAllOrders event, Emitter<AdminOrderState> emit) async {
    emit(AdminOrdersLoading());
    try {
      final orders = await _orderRepository.getAllOrders();
      emit(AdminOrdersLoaded(orders));
    } catch (e) {
      emit(AdminOrdersError(e.toString()));
    }
  }

  void _onUpdateStatus(UpdateStatus event, Emitter<AdminOrderState> emit) async {
    try {
      await _orderRepository.updateOrderStatus(event.orderId, event.newStatus);
      // After updating, reload all orders to show the change
      add(LoadAllOrders());
    } catch (e) {
      emit(AdminOrdersError('Cập nhật thất bại: ${e.toString()}'));
    }
  }
}
