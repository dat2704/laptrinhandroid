import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cua_hang_thoi_trang/data/repositories/discount_repository.dart';
import 'package:cua_hang_thoi_trang/domain/models/discount_model.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'discount_event.dart';
part 'discount_state.dart';

class DiscountBloc extends Bloc<DiscountEvent, DiscountState> {
  final DiscountRepository _discountRepository;
  StreamSubscription? _discountSubscription;

  DiscountBloc({required DiscountRepository discountRepository})
      : _discountRepository = discountRepository,
        super(DiscountInitial()) {
    on<LoadDiscounts>(_onLoadDiscounts);
    on<_DiscountsUpdated>(_onDiscountsUpdated);
    on<AddDiscount>(_onAddDiscount);
    on<UpdateDiscount>(_onUpdateDiscount);
    on<DeleteDiscount>(_onDeleteDiscount);
  }

  void _onLoadDiscounts(LoadDiscounts event, Emitter<DiscountState> emit) {
    emit(DiscountLoading());
    _discountSubscription?.cancel();
    _discountSubscription = _discountRepository.getDiscounts().listen(
          (discounts) => add(_DiscountsUpdated(discounts)),
          onError: (error) => emit(DiscountError(error.toString())),
        );
  }

  void _onDiscountsUpdated(_DiscountsUpdated event, Emitter<DiscountState> emit) {
    emit(DiscountLoaded(event.discounts));
  }

  void _onAddDiscount(AddDiscount event, Emitter<DiscountState> emit) async {
    try {
      await _discountRepository.addDiscount(event.discount);
    } catch (e) {
      emit(DiscountError(e.toString()));
    }
  }

  void _onUpdateDiscount(UpdateDiscount event, Emitter<DiscountState> emit) async {
    try {
      await _discountRepository.updateDiscount(event.discount);
    } catch (e) {
      emit(DiscountError(e.toString()));
    }
  }

  void _onDeleteDiscount(DeleteDiscount event, Emitter<DiscountState> emit) async {
    try {
      await _discountRepository.deleteDiscount(event.id);
    } catch (e) {
      emit(DiscountError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _discountSubscription?.cancel();
    return super.close();
  }
}
