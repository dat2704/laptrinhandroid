
import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  final String id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>;
    return Category(
      id: snap.id,
      name: data['name'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }
}
