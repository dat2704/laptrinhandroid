
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cua_hang_thoi_trang/domain/models/product_model.dart';

class ProductRepository {
  final CollectionReference _productsCollection;

  ProductRepository({FirebaseFirestore? firestore})
      : _productsCollection = (firestore ?? FirebaseFirestore.instance).collection('products');

  // Lấy tất cả sản phẩm
  Future<List<Product>> getAllProducts() async {
    try {
      final snapshot = await _productsCollection.orderBy('createdAt', descending: true).get();
      return snapshot.docs.map((doc) => Product.fromSnapshot(doc)).toList();
    } catch (e) {
      print('Lỗi khi lấy tất cả sản phẩm: $e');
      rethrow;
    }
  }

  // Tìm kiếm sản phẩm theo tên
  Future<List<Product>> searchProducts(String query) async {
    if (query.isEmpty) {
      return [];
    }
    try {
      final snapshot = await _productsCollection
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .get();
      return snapshot.docs.map((doc) => Product.fromSnapshot(doc)).toList();
    } catch (e) {
      print('Lỗi khi tìm kiếm sản phẩm: $e');
      rethrow;
    }
  }

  // Lấy sản phẩm liên quan
  Future<List<Product>> getRelatedProducts({required String categoryId, required String currentProductId, int limit = 5}) async {
    try {
      final snapshot = await _productsCollection
          .where('categoryId', isEqualTo: categoryId)
          .where(FieldPath.documentId, isNotEqualTo: currentProductId)
          .limit(limit)
          .get();
      return snapshot.docs.map((doc) => Product.fromSnapshot(doc)).toList();
    } catch (e) {
      print('Lỗi khi lấy sản phẩm liên quan: $e');
      rethrow;
    }
  }

  // Lấy sản phẩm nổi bật
  Future<List<Product>> getFeaturedProducts() async {
    try {
      final snapshot = await _productsCollection.limit(10).get();
      return snapshot.docs.map((doc) => Product.fromSnapshot(doc)).toList();
    } catch (e) {
      print('Lỗi khi lấy sản phẩm nổi bật: $e');
      rethrow;
    }
  }

  // Thêm sản phẩm mới
  Future<void> addProduct(Product product) async {
    try {
      final docRef = _productsCollection.doc();
      final newProduct = product.copyWith(
        id: docRef.id,
        createdAt: Timestamp.now(),
      );
      await docRef.set(newProduct.toMap());
    } catch (e) {
      print('Lỗi khi thêm sản phẩm: $e');
      rethrow;
    }
  }

  // Cập nhật sản phẩm
  Future<void> updateProduct(Product product) async {
    try {
      await _productsCollection.doc(product.id).update(product.toMap());
    } catch (e) {
      print('Lỗi khi cập nhật sản phẩm: $e');
      rethrow;
    }
  }

  // Xóa sản phẩm
  Future<void> deleteProduct(String productId) async {
    try {
      await _productsCollection.doc(productId).delete();
    } catch (e) {
      print('Lỗi khi xóa sản phẩm: $e');
      rethrow;
    }
  }
}
