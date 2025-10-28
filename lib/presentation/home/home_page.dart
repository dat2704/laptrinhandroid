
import 'package:cua_hang_thoi_trang/data/repositories/category_repository.dart';
import 'package:cua_hang_thoi_trang/data/repositories/product_repository.dart';
import 'package:cua_hang_thoi_trang/domain/models/product_model.dart';
import 'package:cua_hang_thoi_trang/presentation/home/bloc/home_bloc.dart';
import 'package:cua_hang_thoi_trang/presentation/home/widgets/hero_banner.dart';
import 'package:cua_hang_thoi_trang/presentation/home/widgets/home_app_bar.dart';
import 'package:cua_hang_thoi_trang/presentation/products/all_products_page.dart';
import 'package:cua_hang_thoi_trang/presentation/widgets/product_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(
        productRepository: context.read<ProductRepository>(),
        categoryRepository: context.read<CategoryRepository>(),
      )..add(LoadHomeData()),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HomeAppBar(),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is HomeLoaded) {
            final categories = state.categories;
            final allProducts = state.allProducts;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const HeroBanner(),
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Danh Mục Sản Phẩm',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...categories.map((category) {
                    final categoryProducts = allProducts.where((p) => p.categoryId == category.id).toList();
                    if (categoryProducts.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return ProductCategorySection(
                      categoryName: category.name,
                      products: categoryProducts,
                    );
                  }).toList(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AllProductsPage()),
                          );
                        },
                        child: const Text('XEM THÊM'),
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.black,
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    child: const Text(
                      'Chúng tôi cam kết mang đến sự hài lòng cho mọi khách hàng.',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }
          if (state is HomeError) {
            return Center(child: Text('Lỗi: ${state.message}'));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class ProductCategorySection extends StatelessWidget {
  final String categoryName;
  final List<Product> products;

  const ProductCategorySection({
    super.key,
    required this.categoryName,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            categoryName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            itemBuilder: (context, index) {
              // Use the new reusable widget
              return ProductListItem(product: products[index]);
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
