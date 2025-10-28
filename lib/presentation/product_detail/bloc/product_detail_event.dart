
part of 'product_detail_bloc.dart';

abstract class ProductDetailEvent extends Equatable {
  const ProductDetailEvent();

  @override
  List<Object?> get props => [];
}

class SizeSelected extends ProductDetailEvent {
  final String? size;
  const SizeSelected(this.size);
  @override
  List<Object?> get props => [size];
}

class ColorSelected extends ProductDetailEvent {
  final String? color;
  const ColorSelected(this.color);
  @override
  List<Object?> get props => [color];
}

class ImageSelected extends ProductDetailEvent {
  final String? imageUrl;
  const ImageSelected(this.imageUrl);
  @override
  List<Object?> get props => [imageUrl];
}

class QuantityChanged extends ProductDetailEvent {
  final int quantity;
  const QuantityChanged(this.quantity);
  @override
  List<Object?> get props => [quantity];
}
