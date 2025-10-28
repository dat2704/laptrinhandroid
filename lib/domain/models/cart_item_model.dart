
import 'package:cua_hang_thoi_trang/domain/models/product_model.dart';

class CartItem {
  final Product product;
  final String? selectedSize;
  final String? selectedColor; // Thêm trường màu sắc
  int quantity;

  CartItem({
    required this.product,
    this.selectedSize,
    this.selectedColor, // Cập nhật constructor
    this.quantity = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': product.id,
      'selectedSize': selectedSize,
      'selectedColor': selectedColor, // Thêm vào map
      'quantity': quantity,
      'name': product.name,
      'price': product.price,
      'imageUrl': product.imageUrl,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map, Product product) {
    return CartItem(
      product: product,
      selectedSize: map['selectedSize'],
      selectedColor: map['selectedColor'], // Thêm từ map
      quantity: map['quantity'] ?? 1,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItem &&
          runtimeType == other.runtimeType &&
          product.id == other.product.id &&
          selectedSize == other.selectedSize &&
          selectedColor == other.selectedColor; // Thêm vào so sánh

  @override
  int get hashCode => product.id.hashCode ^ selectedSize.hashCode ^ selectedColor.hashCode; // Thêm vào hashcode
}
