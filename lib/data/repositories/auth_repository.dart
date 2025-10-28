
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cua_hang_thoi_trang/domain/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firebaseFirestore;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firebaseFirestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

  // Stream để lắng nghe sự thay đổi trạng thái của người dùng
  Stream<User?> get user => _firebaseAuth.authStateChanges();

  // Lấy người dùng hiện tại
  User? get currentUser => _firebaseAuth.currentUser;

  // Collection reference tới users
  CollectionReference get _usersCollection => _firebaseFirestore.collection('users');

  // Đăng ký bằng email và mật khẩu
  Future<void> signUp({required String email, required String password}) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Nếu tạo tài khoản thành công, tạo document trong Firestore
      if (credential.user != null) {
        final newUser = UserModel(
          id: credential.user!.uid,
          email: email,
          role: 'user', // Gán vai trò mặc định là user
          createdAt: Timestamp.now(),
        );
        // Set document với ID là UID của user
        await _usersCollection.doc(credential.user!.uid).set(newUser.toMap());
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('Mật khẩu quá yếu.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('Email này đã được sử dụng.');
      }
      throw Exception('Có lỗi xảy ra trong quá trình đăng ký.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Đăng nhập bằng email và mật khẩu
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        throw Exception('Email hoặc mật khẩu không chính xác.');
      }
      throw Exception('Có lỗi xảy ra trong quá trình đăng nhập.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Đăng xuất
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Thay đổi mật khẩu
  Future<void> changePassword(String newPassword) async {
    try {
      await _firebaseAuth.currentUser!.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('Mật khẩu mới quá yếu.');
      }
      throw Exception('Có lỗi xảy ra khi thay đổi mật khẩu.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
