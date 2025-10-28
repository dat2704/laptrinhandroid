
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

part 'product_detail_event.dart';
part 'product_detail_state.dart';

class ProductDetailBloc extends Bloc<ProductDetailEvent, ProductDetailState> {
  ProductDetailBloc() : super(const ProductDetailState()) {
    on<SizeSelected>(_onSizeSelected);
    on<ColorSelected>(_onColorSelected);
    on<ImageSelected>(_onImageSelected);
    on<QuantityChanged>(_onQuantityChanged);
  }

  void _onSizeSelected(SizeSelected event, Emitter<ProductDetailState> emit) {
    emit(state.copyWith(
      selectedSize: () => state.selectedSize == event.size ? null : event.size,
    ));
  }

  void _onColorSelected(ColorSelected event, Emitter<ProductDetailState> emit) {
    emit(state.copyWith(
      selectedColor: () => state.selectedColor == event.color ? null : event.color,
    ));
  }

  void _onImageSelected(ImageSelected event, Emitter<ProductDetailState> emit) {
    emit(state.copyWith(selectedImage: () => event.imageUrl));
  }

  void _onQuantityChanged(QuantityChanged event, Emitter<ProductDetailState> emit) {
    if (event.quantity >= 1) {
      emit(state.copyWith(quantity: event.quantity));
    }
  }
}
