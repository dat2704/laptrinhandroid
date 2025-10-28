import 'package:bloc/bloc.dart';
import 'package:cua_hang_thoi_trang/data/repositories/discount_repository.dart';
import 'package:cua_hang_thoi_trang/domain/models/cart_item_model.dart';
import 'package:cua_hang_thoi_trang/domain/models/discount_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final DiscountRepository _discountRepository;

  CartBloc({required DiscountRepository discountRepository})
      : _discountRepository = discountRepository,
        super(const CartLoadSuccess()) {
    on<CartStarted>(_onCartStarted);
    on<CartItemAdded>(_onItemAdded);
    on<CartItemRemoved>(_onItemRemoved);
    on<CartItemQuantityUpdated>(_onItemQuantityUpdated);
    on<CartCleared>(_onCartCleared);
    on<CartDiscountApplied>(_onDiscountApplied);
  }

  void _onCartStarted(CartStarted event, Emitter<CartState> emit) {
    emit(const CartLoadSuccess());
  }

  void _onCartCleared(CartCleared event, Emitter<CartState> emit) {
    emit(const CartLoadSuccess());
  }

  void _onItemAdded(CartItemAdded event, Emitter<CartState> emit) {
    final state = this.state;
    if (state is CartLoadSuccess) {
      final List<CartItem> updatedItems = List.from(state.items);
      final existingItemIndex = updatedItems.indexWhere(
        (item) => item.product.id == event.item.product.id && item.selectedSize == event.item.selectedSize,
      );

      if (existingItemIndex != -1) {
        updatedItems[existingItemIndex].quantity += event.item.quantity;
      } else {
        updatedItems.add(event.item);
      }
      emit(state.copyWith(items: updatedItems));
    }
  }

  void _onItemRemoved(CartItemRemoved event, Emitter<CartState> emit) {
    final state = this.state;
    if (state is CartLoadSuccess) {
      final List<CartItem> updatedItems = List.from(state.items)..remove(event.item);
      emit(state.copyWith(items: updatedItems));
    }
  }

  void _onItemQuantityUpdated(CartItemQuantityUpdated event, Emitter<CartState> emit) {
    final state = this.state;
    if (state is CartLoadSuccess) {
      final List<CartItem> updatedItems = List.from(state.items);
      final itemIndex = updatedItems.indexOf(event.item);
      if (itemIndex != -1) {
        if (event.quantity > 0) {
          updatedItems[itemIndex].quantity = event.quantity;
        } else {
          updatedItems.removeAt(itemIndex);
        }
      }
      emit(state.copyWith(items: updatedItems));
    }
  }

  void _onDiscountApplied(CartDiscountApplied event, Emitter<CartState> emit) async {
    final state = this.state;
    if (state is CartLoadSuccess) {
      try {
        final discounts = await _discountRepository.getDiscounts().first;
        final discount = discounts.firstWhere((d) => d.code == event.code);
        emit(state.copyWith(
          appliedDiscount: () => discount,
          discountMessage: () => 'Áp dụng mã giảm giá thành công!',
        ));
      } catch (e) {
        emit(state.copyWith(
          appliedDiscount: () => null,
          discountMessage: () => 'Mã giảm giá không hợp lệ.',
        ));
      }
    }
  }
}
