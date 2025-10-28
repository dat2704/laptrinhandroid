
import 'package:cua_hang_thoi_trang/domain/models/category_model.dart';
import 'package:cua_hang_thoi_trang/presentation/admin/manage_categories/bloc/category_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ManageCategoriesPage extends StatelessWidget {
  const ManageCategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Loại sản phẩm'),
      ),
      body: BlocConsumer<CategoryBloc, CategoryState>(
        listener: (context, state) {
          if (state is CategoryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          } else if (state is CategoryOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Thao tác thành công!'), backgroundColor: Colors.green),
            );
          }
        },
        builder: (context, state) {
          if (state is CategoryLoading || state is CategoryInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CategoriesLoaded) {
            if (state.categories.isEmpty) {
              return const Center(child: Text('Chưa có loại sản phẩm nào.'));
            }
            return ListView.builder(
              itemCount: state.categories.length,
              itemBuilder: (context, index) {
                final category = state.categories[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: ListTile(
                    title: Text(category.name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showAddEditDialog(context, category: category),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _showDeleteDialog(context, category),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const Center(child: Text('Đã có lỗi xảy ra.'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, {Category? category}) {
    final isEditing = category != null;
    final TextEditingController nameController = TextEditingController(text: category?.name);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isEditing ? 'Chỉnh sửa Loại' : 'Thêm Loại mới'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: nameController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Tên loại sản phẩm'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Tên loại không được để trống';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final bloc = context.read<CategoryBloc>();
                  if (isEditing) {
                    final updatedCategory = Category(id: category.id, name: nameController.text.trim());
                    bloc.add(UpdateCategory(updatedCategory));
                  } else {
                    bloc.add(AddCategory(nameController.text.trim()));
                  }
                  Navigator.pop(dialogContext);
                }
              },
              child: Text(isEditing ? 'Lưu' : 'Thêm'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: Text('Bạn có chắc muốn xóa loại "${category.name}"? \nThao tác này không thể hoàn tác.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Hủy')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                context.read<CategoryBloc>().add(DeleteCategory(category.id));
                Navigator.pop(dialogContext);
              },
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }
}
