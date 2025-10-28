
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String? id;
  final String userId;
  final List<Map<String, dynamic>> items;
  final double totalAmount;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final String paymentMethod;
  final String status;
  final Timestamp orderDate;
  final String? discount;

  OrderModel({
    this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.paymentMethod,
    this.status = 'Chờ xác nhận',
    required this.orderDate,
    this.discount,
  });

  OrderModel copyWith({
    String? id,
    String? userId,
    List<Map<String, dynamic>>? items,
    double? totalAmount,
    String? customerName,
    String? customerPhone,
    String? customerAddress,
    String? paymentMethod,
    String? status,
    Timestamp? orderDate,
    String? discount,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerAddress: customerAddress ?? this.customerAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      orderDate: orderDate ?? this.orderDate,
      discount: discount ?? this.discount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items,
      'totalAmount': totalAmount,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerAddress': customerAddress,
      'paymentMethod': paymentMethod,
      'status': status,
      'orderDate': orderDate,
      'discount': discount,
    };
  }

  factory OrderModel.fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>? ?? {};

    final itemsFromDb = data['items'] as List<dynamic>?;
    final List<Map<String, dynamic>> items = itemsFromDb
            ?.map((itemData) => Map<String, dynamic>.from(itemData as Map))
            .toList() ??
        [];

    Timestamp orderDate;
    if (data['orderDate'] is Timestamp) {
      orderDate = data['orderDate'];
    } else {
      orderDate = Timestamp.now(); // Giá trị mặc định an toàn
    }

    return OrderModel(
      id: snap.id,
      userId: data['userId'] as String? ?? '',
      items: items,
      totalAmount: (data['totalAmount'] as num? ?? 0).toDouble(),
      customerName: data['customerName'] as String? ?? '',
      customerPhone: data['customerPhone'] as String? ?? '',
      customerAddress: data['customerAddress'] as String? ?? '',
      paymentMethod: data['paymentMethod'] as String? ?? '',
      status: data['status'] as String? ?? 'Chờ xác nhận',
      orderDate: orderDate,
      discount: data['discount'] as String?,
    );
  }
}
