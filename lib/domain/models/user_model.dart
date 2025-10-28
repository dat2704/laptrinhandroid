
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;      // UID từ Firebase Auth
  final String email;
  final String role;    // Vai trò: 'admin' hoặc 'user'
  final String? displayName;
  final String? photoUrl;
  final String? address; // Thêm địa chỉ
  final Timestamp createdAt;

  UserModel({
    required this.id,
    required this.email,
    this.role = 'user', // Mặc định là user
    this.displayName,
    this.photoUrl,
    this.address,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'address': address,
      'createdAt': createdAt,
    };
  }

  // Factory constructor để tạo UserModel từ một DocumentSnapshot
  factory UserModel.fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>;
    return UserModel(
      id: data['id'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'user',
      displayName: data['displayName'],
      photoUrl: data['photoUrl'],
      address: data['address'],
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}
