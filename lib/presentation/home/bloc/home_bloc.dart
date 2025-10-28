
import 'package:bloc/bloc.dart';
import 'package:cua_hang_thoi_trang/data/repositories/category_repository.dart';
import 'package:cua_hang_thoi_trang/data/repositories/product_repository.dart';
import 'package:cua_hang_thoi_trang/domain/models/category_model.dart';
import 'package:cua_hang_thoi_trang/domain/models/product_model.dart';
import 'package:equatable/equatable.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final ProductRepository _productRepository;
  final CategoryRepository _categoryRepository;

  HomeBloc({
    required ProductRepository productRepository,
    required CategoryRepository categoryRepository,
  })  : _productRepository = productRepository,
        _categoryRepository = categoryRepository,
        super(HomeLoading()) {
    on<LoadHomeData>(_onLoadHomeData);
  }

  Future<void> _onLoadHomeData(LoadHomeData event, Emitter<HomeState> emit) async {
    try {
      emit(HomeLoading());
      // Tải đồng thời cả sản phẩm và loại sản phẩm
      final Future<List<Product>> productsFuture = _productRepository.getAllProducts();
      final Future<List<Category>> categoriesFuture = _categoryRepository.getCategories();

      // Chờ cả hai hoàn thành
      final List<dynamic> results = await Future.wait([productsFuture, categoriesFuture]);

      final List<Product> allProducts = results[0] as List<Product>;
      final List<Category> categories = results[1] as List<Category>;

      emit(HomeLoaded(allProducts: allProducts, categories: categories));
    } catch (e) {
      emit(HomeError('Không thể tải dữ liệu: ${e.toString()}'));
    }
  }
}
