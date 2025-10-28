import 'package:cloud_firestore/cloud_firestore.dart';

class Discount {
  final String id;
  final String code;
  final double percentage;
  final Timestamp expiryDate;

  Discount({
    required this.id,
    required this.code,
    required this.percentage,
    required this.expiryDate,
  });

  factory Discount.fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>;
    return Discount(
      id: snap.id,
      code: data['code'] ?? '',
      percentage: (data['percentage'] ?? 0.0).toDouble(),
      expiryDate: data['expiryDate'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'percentage': percentage,
      'expiryDate': expiryDate,
    };
  }
}
