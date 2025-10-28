
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cua_hang_thoi_trang/domain/models/order_model.dart';

class OrderRepository {
  final CollectionReference _ordersCollection;

  OrderRepository({FirebaseFirestore? firestore})
      : _ordersCollection = (firestore ?? FirebaseFirestore.instance).collection('orders');

  // For Admin: Get all orders from all users
  Future<List<OrderModel>> getAllOrders() async {
    try {
      final snapshot = await _ordersCollection.orderBy('orderDate', descending: true).get();
      return snapshot.docs.map((doc) => OrderModel.fromSnapshot(doc)).toList();
    } catch (e) {
      print('Error getting all orders: $e');
      rethrow;
    }
  }

  // For Admin: Update the status of an order
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _ordersCollection.doc(orderId).update({'status': newStatus});
    } catch (e) {
      print('Error updating order status: $e');
      rethrow;
    }
  }

  // For User: Add a new order
  Future<void> addOrder(OrderModel order) async {
    try {
      // The toMap() method should not include the ID
      await _ordersCollection.add(order.toMap());
    } catch (e) {
      print('Lỗi khi thêm đơn hàng: $e');
      rethrow;
    }
  }

  // For User: Get their own orders
  Future<List<OrderModel>> getOrdersForUser(String userId) async {
    try {
      final snapshot = await _ordersCollection
          .where('userId', isEqualTo: userId)
          .orderBy('orderDate', descending: true)
          .get();
      return snapshot.docs.map((doc) => OrderModel.fromSnapshot(doc)).toList();
    } catch (e) {
      print('Lỗi khi lấy đơn hàng của người dùng: $e');
      rethrow;
    }
  }
}
