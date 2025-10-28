
part of 'product_bloc.dart';

@immutable
abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object> get props => [];
}

// Trạng thái khi đang tải danh sách sản phẩm
class ProductsLoading extends ProductState {}

// Trạng thái khi đã tải thành công danh sách sản phẩm
class ProductsLoaded extends ProductState {
  final List<Product> products;

  const ProductsLoaded(this.products);

  @override
  List<Object> get props => [products];
}

// Trạng thái khi một thao tác (thêm, sửa, xóa) thành công
class ProductOperationSuccess extends ProductState {}

// Trạng thái khi có lỗi xảy ra
class ProductsError extends ProductState {
  final String message;

  const ProductsError(this.message);

  @override
  List<Object> get props => [message];
}
