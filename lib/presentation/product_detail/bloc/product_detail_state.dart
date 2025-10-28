
part of 'product_detail_bloc.dart';

class ProductDetailState extends Equatable {
  final String? selectedSize;
  final String? selectedColor;
  final String? selectedImage;
  final int quantity;

  const ProductDetailState({
    this.selectedSize,
    this.selectedColor,
    this.selectedImage,
    this.quantity = 1,
  });

  ProductDetailState copyWith({
    // Use ValueGetter to differentiate between null and not provided
    ValueGetter<String?>? selectedSize,
    ValueGetter<String?>? selectedColor,
    ValueGetter<String?>? selectedImage,
    int? quantity,
  }) {
    return ProductDetailState(
      selectedSize: selectedSize != null ? selectedSize() : this.selectedSize,
      selectedColor: selectedColor != null ? selectedColor() : this.selectedColor,
      selectedImage: selectedImage != null ? selectedImage() : this.selectedImage,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [selectedSize, selectedColor, selectedImage, quantity];
}
