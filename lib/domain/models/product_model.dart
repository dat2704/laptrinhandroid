
import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl; // Keep for backward compatibility (main image)
  final List<String> imageUrls; // For multiple images
  final String categoryId;
  final String categoryName;
  final List<String> sizes;
  final List<String> colors; // New field for colors
  final Timestamp? createdAt;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.imageUrls = const [],
    required this.categoryId,
    required this.categoryName,
    this.sizes = const [],
    this.colors = const [],
    this.createdAt,
  });

  Product copyWith({
    String? id,
    String? name,
    double? price,
    String? imageUrl,
    List<String>? imageUrls,
    String? categoryId,
    String? categoryName,
    List<String>? sizes,
    List<String>? colors,
    Timestamp? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      sizes: sizes ?? this.sizes,
      colors: colors ?? this.colors,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'imageUrls': imageUrls,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'sizes': sizes,
      'colors': colors,
      'createdAt': createdAt,
    };
  }

  factory Product.fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>;
    return Product(
      id: snap.id,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      categoryId: data['categoryId'] ?? '',
      categoryName: data['categoryName'] ?? '',
      sizes: List<String>.from(data['sizes'] ?? []),
      colors: List<String>.from(data['colors'] ?? []),
      createdAt: data['createdAt'],
    );
  }
}
