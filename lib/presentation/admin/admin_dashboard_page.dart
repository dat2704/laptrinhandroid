
import 'package:cua_hang_thoi_trang/data/repositories/product_repository.dart';
import 'package:cua_hang_thoi_trang/domain/models/product_model.dart';
import 'package:cua_hang_thoi_trang/presentation/admin/add_edit_product_page.dart';
import 'package:cua_hang_thoi_trang/presentation/admin/bloc/product_bloc.dart';
import 'package:cua_hang_thoi_trang/presentation/admin/widgets/admin_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProductBloc(
        productRepository: context.read<ProductRepository>(),
      )..add(LoadProducts()),
      child: const AdminDashboardView(),
    );
  }
}

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      drawer: const AdminDrawer(),
      appBar: AppBar(
        title: const Text('Quản lý Sản phẩm'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.background,
        foregroundColor: theme.colorScheme.secondary,
        elevation: 1,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                // Sửa lỗi ở đây: Cung cấp ProductBloc hiện có cho trang con
                value: context.read<ProductBloc>(),
                child: const AddEditProductPage(),
              ),
            ),
          ).then((value) {
            // Nếu trang con trả về `true` (nghĩa là có thay đổi), thì tải lại list
            if (value == true) {
              context.read<ProductBloc>().add(LoadProducts());
            }
          });
        },
        backgroundColor: theme.colorScheme.secondary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: BlocConsumer<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is ProductsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          } 
        },
        builder: (context, state) {
          if (state is ProductsLoading && state is! ProductOperationSuccess) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProductsLoaded) {
            if (state.products.isEmpty) {
              return const Center(child: Text('Chưa có sản phẩm nào.'));
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<ProductBloc>().add(LoadProducts());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: state.products.length,
                itemBuilder: (context, index) {
                  final product = state.products[index];
                  return _buildProductCard(context, product);
                },
              ),
            );
          }
          // Hiển thị một indicator nhỏ khi đang thực hiện thao tác nền
          if (state is ProductsLoading) {
             return const Center(child: CircularProgressIndicator());
          }
          return const Center(child: Text('Hãy bắt đầu bằng cách thêm sản phẩm mới!'));
        },
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12.0),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.network(
            product.imageUrl,
            width: 50, height: 50, fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported),
          ),
        ),
        title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(currencyFormatter.format(product.price)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit_outlined, color: Colors.blue.shade700),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      // Sửa lỗi ở đây: Cung cấp ProductBloc hiện có cho trang con
                      value: context.read<ProductBloc>(),
                      child: AddEditProductPage(product: product),
                    ),
                  ),
                ).then((value) {
                   if (value == true) {
                    context.read<ProductBloc>().add(LoadProducts());
                  }
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red.shade700),
              onPressed: () => _showDeleteConfirmation(context, product),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa sản phẩm "${product.name}"?'),
        actions: [
          TextButton(child: const Text('Hủy'), onPressed: () => Navigator.of(ctx).pop()),
          TextButton(
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
            onPressed: () {
              // Cung cấp bloc cho hộp thoại
              context.read<ProductBloc>().add(DeleteProduct(product));
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
}
