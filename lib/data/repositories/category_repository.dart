
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cua_hang_thoi_trang/domain/models/category_model.dart';

class CategoryRepository {
  final CollectionReference _categoryCollection;

  CategoryRepository({FirebaseFirestore? firestore}) 
      : _categoryCollection = (firestore ?? FirebaseFirestore.instance).collection('categories');

  Future<List<Category>> getCategories() async {
    final snapshot = await _categoryCollection.orderBy('name').get();
    return snapshot.docs.map((doc) => Category.fromSnapshot(doc)).toList();
  }

  Future<void> addCategory(String name) async {
    await _categoryCollection.add({'name': name});
  }

  Future<void> updateCategory(String id, String newName) async {
    await _categoryCollection.doc(id).update({'name': newName});
  }

  Future<void> deleteCategory(String id) async {
    await _categoryCollection.doc(id).delete();
  }
}
