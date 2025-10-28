
import 'package:cua_hang_thoi_trang/data/repositories/product_repository.dart';
import 'package:cua_hang_thoi_trang/domain/models/cart_item_model.dart';
import 'package:cua_hang_thoi_trang/domain/models/product_model.dart';
import 'package:cua_hang_thoi_trang/presentation/cart/bloc/cart_bloc.dart';
import 'package:cua_hang_thoi_trang/presentation/home/widgets/home_app_bar.dart';
import 'package:cua_hang_thoi_trang/presentation/product_detail/bloc/product_detail_bloc.dart';
import 'package:cua_hang_thoi_trang/presentation/widgets/product_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

// Helper function to convert hex string to Color
Color hexToColor(String hexString) {
  final buffer = StringBuffer();
  if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
  buffer.write(hexString.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}

class ProductDetailPage extends StatelessWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final allImageUrls = [product.imageUrl, ...product.imageUrls].toSet().toList();

    return BlocProvider(
      create: (context) => ProductDetailBloc()..add(ImageSelected(allImageUrls.first)),
      child: Scaffold(
        // Use the same AppBar as the home page for consistency
        appBar: const HomeAppBar(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildProductDisplay(context, allImageUrls),
              const SizedBox(height: 24),
              _buildRelatedProducts(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductDisplay(BuildContext context, List<String> imageUrls) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: BlocBuilder<ProductDetailBloc, ProductDetailState>(
            builder: (context, state) {
              return Container(
                height: 500, 
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(
                    image: NetworkImage(state.selectedImage ?? product.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageThumbnails(context, imageUrls),
              const SizedBox(height: 16),
              _buildProductInfoPanel(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageThumbnails(BuildContext context, List<String> imageUrls) {
    if (imageUrls.length <= 1) return const SizedBox.shrink();
    return SizedBox(
      height: 200,
      child: ListView.builder(
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          final imageUrl = imageUrls[index];
          return GestureDetector(
            onTap: () => context.read<ProductDetailBloc>().add(ImageSelected(imageUrl)),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductInfoPanel(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(product.name, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(currencyFormatter.format(product.price), style: theme.textTheme.titleLarge?.copyWith(color: Colors.red[700])),
        const SizedBox(height: 24),
        if (product.colors.isNotEmpty) _buildColorSelector(context),
        if (product.sizes.isNotEmpty) _buildSizeSelector(context),
        const SizedBox(height: 24),
        _buildAddToCartButton(context),
      ],
    );
  }

  Widget _buildColorSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Màu sắc', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        BlocBuilder<ProductDetailBloc, ProductDetailState>(
          builder: (context, state) {
            return Wrap(
              spacing: 12,
              children: product.colors.map((colorStr) {
                final color = hexToColor(colorStr);
                final isSelected = state.selectedColor == colorStr;
                return GestureDetector(
                  onTap: () => context.read<ProductDetailBloc>().add(ColorSelected(colorStr)),
                  child: Container(
                    width: 32, 
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey.shade300,
                        width: 3,
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

   Widget _buildSizeSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Kích thước', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        BlocBuilder<ProductDetailBloc, ProductDetailState>(
          builder: (context, state) {
            return Wrap(
              spacing: 8.0,
              children: product.sizes.map((size) {
                final isSelected = state.selectedSize == size;
                return ChoiceChip(
                  label: Text(size),
                  selected: isSelected,
                  onSelected: (selected) {
                    context.read<ProductDetailBloc>().add(SizeSelected(size));
                  },
                  selectedColor: Colors.black,
                  labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                  backgroundColor: Colors.grey[200],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAddToCartButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: BlocBuilder<ProductDetailBloc, ProductDetailState>(
        builder: (context, state) {
          return ElevatedButton.icon(
            onPressed: () {
               if (product.sizes.isNotEmpty && state.selectedSize == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn kích thước.')));
                return;
              }
              if (product.colors.isNotEmpty && state.selectedColor == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn màu sắc.')));
                return;
              }

              final cartItem = CartItem(
                product: product, 
                selectedSize: state.selectedSize,
                selectedColor: state.selectedColor,
              );
              context.read<CartBloc>().add(CartItemAdded(cartItem));

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã thêm vào giỏ hàng!'), backgroundColor: Colors.green),
              );
            },
            icon: const Icon(Icons.shopping_cart_checkout),
            label: const Text('Thêm Vào Giỏ'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }

   Widget _buildRelatedProducts(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Text('Sản Phẩm Liên Quan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        FutureBuilder<List<Product>>(
          future: context.read<ProductRepository>().getRelatedProducts(
                categoryId: product.categoryId,
                currentProductId: product.id,
              ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(height: 280, child: Center(child: CircularProgressIndicator()));
            }
            if (snapshot.hasError) {
              return const SizedBox(height: 280, child: Center(child: Text('Lỗi tải sản phẩm liên quan.')));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const SizedBox.shrink(); // Không hiển thị gì nếu không có sản phẩm liên quan
            }
            final relatedProducts = snapshot.data!;
            return SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: relatedProducts.length,
                itemBuilder: (context, index) {
                  return ProductListItem(product: relatedProducts[index]);
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
