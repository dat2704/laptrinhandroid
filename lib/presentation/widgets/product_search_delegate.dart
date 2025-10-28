
import 'package:cua_hang_thoi_trang/data/repositories/product_repository.dart';
import 'package:cua_hang_thoi_trang/domain/models/product_model.dart';
import 'package:cua_hang_thoi_trang/presentation/product_detail/product_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ProductSearchDelegate extends SearchDelegate<Product?> {
  @override
  String get searchFieldLabel => 'Tìm kiếm sản phẩm...';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text('Vui lòng nhập tên sản phẩm để tìm kiếm.'));
    }

    return FutureBuilder<List<Product>>(
      future: context.read<ProductRepository>().searchProducts(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Lỗi tìm kiếm: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Không tìm thấy sản phẩm nào cho "$query"'));
        }

        final products = snapshot.data!;
        return _buildProductList(products);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Có thể hiển thị lịch sử tìm kiếm hoặc các gợi ý phổ biến ở đây.
    // Để đơn giản, ta sẽ trả về một widget trống.
    return const SizedBox.shrink();
  }

  Widget _buildProductList(List<Product> products) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ListTile(
          leading: Image.network(product.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
          title: Text(product.name),
          subtitle: Text(currencyFormatter.format(product.price)),
          onTap: () {
            // Đóng màn hình tìm kiếm và điều hướng đến trang chi tiết sản phẩm
            close(context, product);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProductDetailPage(product: product)),
            );
          },
        );
      },
    );
  }
}
