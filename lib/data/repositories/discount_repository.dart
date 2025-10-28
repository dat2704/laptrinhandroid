import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cua_hang_thoi_trang/domain/models/discount_model.dart';

class DiscountRepository {
  final FirebaseFirestore _firestore;

  DiscountRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> addDiscount(Discount discount) async {
    try {
      await _firestore.collection('discounts').add(discount.toMap());
    } catch (e) {
      print('Lỗi khi thêm mã giảm giá: $e');
      rethrow;
    }
  }

  Stream<List<Discount>> getDiscounts() {
    final now = DateTime.now();
    final startOfToday = Timestamp.fromDate(DateTime(now.year, now.month, now.day));

    return _firestore
        .collection('discounts')
        .where('expiryDate', isGreaterThanOrEqualTo: startOfToday)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Discount.fromSnapshot(doc)).toList());
  }

  Future<void> updateDiscount(Discount discount) async {
    try {
      await _firestore
          .collection('discounts')
          .doc(discount.id)
          .update(discount.toMap());
    } catch (e) {
      print('Lỗi khi cập nhật mã giảm giá: $e');
      rethrow;
    }
  }

  Future<void> deleteDiscount(String id) async {
    try {
      await _firestore.collection('discounts').doc(id).delete();
    } catch (e) {
      print('Lỗi khi xóa mã giảm giá: $e');
      rethrow;
    }
  }
}
