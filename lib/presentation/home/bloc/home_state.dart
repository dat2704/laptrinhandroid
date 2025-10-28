
part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<Product> allProducts;
  final List<Category> categories;

  const HomeLoaded({
    required this.allProducts,
    required this.categories,
  });

  @override
  List<Object> get props => [allProducts, categories];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object> get props => [message];
}
