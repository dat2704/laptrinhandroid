
import 'package:bloc/bloc.dart';
import 'package:cua_hang_thoi_trang/data/repositories/order_repository.dart';
import 'package:cua_hang_thoi_trang/domain/models/order_model.dart';
import 'package:cua_hang_thoi_trang/presentation/auth/bloc/auth_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

part 'orders_event.dart';
part 'orders_state.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final OrderRepository _orderRepository;
  final AuthBloc _authBloc;

  OrdersBloc({required OrderRepository orderRepository, required AuthBloc authBloc})
      : _orderRepository = orderRepository,
        _authBloc = authBloc,
        super(OrdersLoading()) {
    on<LoadOrders>(_onLoadOrders);
  }

  void _onLoadOrders(LoadOrders event, Emitter<OrdersState> emit) async {
    emit(OrdersLoading());
    try {
      final authState = _authBloc.state;
      if (authState is Authenticated) {
        final orders = await _orderRepository.getOrdersForUser(authState.userModel.id);
        emit(OrdersLoaded(orders));
      } else {
        emit(const OrdersError('Bạn cần đăng nhập để xem đơn hàng.'));
      }
    } catch (e) {
      debugPrint('Error loading orders: $e');
      emit(OrdersError('Không thể tải danh sách đơn hàng. Lỗi: $e'));
    }
  }
}
