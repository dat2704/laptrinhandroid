
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cua_hang_thoi_trang/domain/models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> addUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(user.toMap());
    } catch (e) {
      print('Lỗi khi thêm người dùng vào Firestore: $e');
      rethrow;
    }
  }

  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromSnapshot(doc);
      }
      return null;
    } catch (e) {
      print('Lỗi khi lấy dữ liệu người dùng: $e');
      rethrow;
    }
  }

  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      print('Lỗi khi cập nhật dữ liệu người dùng: $e');
      rethrow;
    }
  }

  // Lấy tất cả người dùng
  Future<List<UserModel>> getAllUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      return snapshot.docs.map((doc) => UserModel.fromSnapshot(doc)).toList();
    } catch (e) {
      print('Lỗi khi lấy tất cả người dùng: $e');
      rethrow;
    }
  }

  // Cập nhật vai trò cho một người dùng
  Future<void> updateUserRole(String uid, String newRole) async {
    try {
      await _firestore.collection('users').doc(uid).update({'role': newRole});
    } catch (e) {
      print('Lỗi khi cập nhật vai trò người dùng: $e');
      rethrow;
    }
  }
}
