
import 'package:bloc/bloc.dart';
import 'package:cua_hang_thoi_trang/data/repositories/category_repository.dart';
import 'package:cua_hang_thoi_trang/domain/models/category_model.dart';
import 'package:equatable/equatable.dart';

part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository _categoryRepository;

  CategoryBloc({required CategoryRepository categoryRepository}) 
      : _categoryRepository = categoryRepository, super(CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<AddCategory>(_onAddCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
  }

  void _onLoadCategories(LoadCategories event, Emitter<CategoryState> emit) async {
    emit(CategoryLoading());
    try {
      final categories = await _categoryRepository.getCategories();
      emit(CategoriesLoaded(categories));
    } catch (e) {
      emit(CategoryError("Không thể tải danh sách loại: ${e.toString()}"));
    }
  }

  void _onAddCategory(AddCategory event, Emitter<CategoryState> emit) async {
    try {
      await _categoryRepository.addCategory(event.name);
      emit(CategoryOperationSuccess());
      add(LoadCategories()); // Tải lại danh sách
    } catch (e) {
      emit(CategoryError("Thêm loại thất bại: ${e.toString()}"));
    }
  }

  void _onUpdateCategory(UpdateCategory event, Emitter<CategoryState> emit) async {
    try {
      await _categoryRepository.updateCategory(event.category.id, event.category.name);
      emit(CategoryOperationSuccess());
       add(LoadCategories());
    } catch (e) {
      emit(CategoryError("Cập nhật loại thất bại: ${e.toString()}"));
    }
  }

  void _onDeleteCategory(DeleteCategory event, Emitter<CategoryState> emit) async {
    try {
      await _categoryRepository.deleteCategory(event.categoryId);
      emit(CategoryOperationSuccess());
       add(LoadCategories());
    } catch (e) {
      emit(CategoryError("Xóa loại thất bại: ${e.toString()}"));
    }
  }
}
