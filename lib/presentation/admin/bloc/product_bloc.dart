
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../data/repositories/product_repository.dart';
import '../../../domain/models/product_model.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository _productRepository;

  ProductBloc({required ProductRepository productRepository})
      : _productRepository = productRepository,
        super(ProductsLoading()) {

    on<LoadProducts>(_onLoadProducts);
    on<AddProduct>(_onAddProduct);
    on<UpdateProduct>(_onUpdateProduct);
    on<DeleteProduct>(_onDeleteProduct);
  }

  void _onLoadProducts(LoadProducts event, Emitter<ProductState> emit) async {
    emit(ProductsLoading());
    try {
      final products = await _productRepository.getAllProducts();
      emit(ProductsLoaded(products));
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  void _onAddProduct(AddProduct event, Emitter<ProductState> emit) async {
    // Báo cho UI biết là đang xử lý
    emit(ProductsLoading());
    try {
      await _productRepository.addProduct(event.product);
      // Báo cho UI biết thao tác đã thành công
      emit(ProductOperationSuccess());
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  void _onUpdateProduct(UpdateProduct event, Emitter<ProductState> emit) async {
    emit(ProductsLoading());
    try {
      await _productRepository.updateProduct(event.product);
      emit(ProductOperationSuccess());
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  void _onDeleteProduct(DeleteProduct event, Emitter<ProductState> emit) async {
    // Không cần emit ProductsLoading ở đây vì nó sẽ làm toàn bộ list biến mất
    try {
      await _productRepository.deleteProduct(event.product.id);
      emit(ProductOperationSuccess());
      // Sau khi xóa thành công, tải lại danh sách
      add(LoadProducts());
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }
}
