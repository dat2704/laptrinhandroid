
import 'package:cua_hang_thoi_trang/data/repositories/category_repository.dart';
import 'package:cua_hang_thoi_trang/domain/models/category_model.dart';
import 'package:cua_hang_thoi_trang/domain/models/product_model.dart';
import 'package:cua_hang_thoi_trang/presentation/admin/bloc/product_bloc.dart';
import 'package:cua_hang_thoi_trang/presentation/admin/manage_categories/bloc/category_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddEditProductPage extends StatelessWidget {
  final Product? product;

  const AddEditProductPage({super.key, this.product});

  @override
  Widget build(BuildContext context) {
    // Cung cấp CategoryBloc cho cây widget của trang này
    return BlocProvider(
      create: (context) => CategoryBloc(
        categoryRepository: context.read<CategoryRepository>(),
      )..add(LoadCategories()),
      child: AddEditProductView(product: product),
    );
  }
}

class AddEditProductView extends StatefulWidget {
  final Product? product;

  const AddEditProductView({super.key, this.product});

  @override
  State<AddEditProductView> createState() => _AddEditProductViewState();
}

class _AddEditProductViewState extends State<AddEditProductView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _imageUrlController;
  late TextEditingController _sizesController;

  Category? _selectedCategory;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name ?? '');
    _priceController = TextEditingController(text: p?.price.toStringAsFixed(0) ?? '');
    _imageUrlController = TextEditingController(text: p?.imageUrl ?? '');
    _sizesController = TextEditingController(text: p?.sizes.join(', ') ?? '');

    // Nếu đang chỉnh sửa, ta cần tìm và đặt category đã chọn
    if (_isEditing && p != null) {
      // Bloc sẽ được cung cấp ngay sau initState, nên ta đợi một chút
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final categoryState = context.read<CategoryBloc>().state;
        if (categoryState is CategoriesLoaded) {
          try {
             final initialCategory = categoryState.categories.firstWhere((c) => c.id == p.categoryId);
              setState(() {
                _selectedCategory = initialCategory;
              });
          } catch (e) {
            // Không tìm thấy category, để null
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _sizesController.dispose();
    super.dispose();
  }

  void _onSave(BuildContext context) {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
       if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn một loại sản phẩm.'), backgroundColor: Colors.red),
        );
        return;
      }

      final productData = Product(
        id: widget.product?.id ?? '',
        name: _nameController.text.trim(),
        price: double.tryParse(_priceController.text.trim()) ?? 0.0,
        imageUrl: _imageUrlController.text.trim(),
        categoryId: _selectedCategory!.id,
        categoryName: _selectedCategory!.name,
        sizes: _sizesController.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
      );

      final productBloc = context.read<ProductBloc>();

      if (_isEditing) {
        productBloc.add(UpdateProduct(productData));
      } else {
        productBloc.add(AddProduct(productData));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Chỉnh sửa sản phẩm' : 'Thêm sản phẩm mới'),
        centerTitle: true,
      ),
      body: BlocListener<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is ProductOperationSuccess) {
            // Trở về với kết quả `true` để trang trước có thể tải lại danh sách
            Navigator.of(context).pop(true);
          }
        },
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildImagePreview(),
                const SizedBox(height: 24),
                _buildTextField(_nameController, 'Tên sản phẩm'),
                _buildTextField(_priceController, 'Giá', keyboardType: TextInputType.number),
                _buildTextField(_imageUrlController, 'URL hình ảnh', onchanged: (_) => setState(() {})),
                _buildCategoryDropdown(), // << THAY ĐỔI Ở ĐÂY
                _buildTextField(_sizesController, 'Các size (cách nhau bởi dấu phẩy: S, M, L)'),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildSaveButton(context, theme),
    );
  }

  Widget _buildCategoryDropdown() {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state is CategoryLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is CategoriesLoaded) {
          // Cập nhật lại _selectedCategory nếu nó chưa được set và đang edit
           if (_isEditing && _selectedCategory == null && widget.product != null) {
            try {
              _selectedCategory = state.categories.firstWhere((c) => c.id == widget.product!.categoryId);
            } catch (e) { /* ignore */ }
          }

          return DropdownButtonFormField<Category>(
            value: _selectedCategory,
            hint: const Text('Chọn loại sản phẩm'),
            isExpanded: true,
            items: state.categories.map((Category category) {
              return DropdownMenuItem<Category>(
                value: category,
                child: Text(category.name),
              );
            }).toList(),
            onChanged: (Category? newValue) {
              setState(() {
                _selectedCategory = newValue;
              });
            },
            validator: (value) => value == null ? 'Vui lòng chọn một loại' : null,
             decoration: InputDecoration(
              labelText: 'Loại sản phẩm',
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          );
        }
        if (state is CategoryError) {
          return Text('Lỗi tải loại sản phẩm: ${state.message}');
        }
        return const SizedBox.shrink();
      },
    );
  }

   Widget _buildTextField(TextEditingController controller, String label, {TextInputType? keyboardType, Function(String)? onchanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        onChanged: onchanged,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        keyboardType: keyboardType,
        validator: (value) => value == null || value.trim().isEmpty ? 'Trường này không được để trống' : null,
      ),
    );
  }
  
  Widget _buildImagePreview() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _imageUrlController.text.trim().isEmpty
            ? const Center(child: Icon(Icons.image, size: 50, color: Colors.grey))
            : Image.network(
                _imageUrlController.text.trim(),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.red)),
              ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          final isLoading = state is ProductsLoading;

          return ElevatedButton(
            onPressed: isLoading ? null : () => _onSave(context),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: theme.colorScheme.secondary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('LƯU SẢN PHẨM'),
          );
        },
      ),
    );
  }
}
