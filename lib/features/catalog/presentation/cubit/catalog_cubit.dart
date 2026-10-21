import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gear_up_bloc/core/constants/constant.dart';
import 'package:gear_up_bloc/features/catalog/data/models/category_model.dart';
import 'package:gear_up_bloc/features/catalog/data/models/product_model.dart';
import 'package:gear_up_bloc/features/catalog/data/models/product_request.dart';
import 'package:gear_up_bloc/features/catalog/domain/use_case/get_catalog_items_use_case.dart';

part 'catalog_state.dart';

class CatalogCubit extends Cubit<CatalogState> {
  final GetCatalogItemsUseCase _getCatalogItemsUseCase;

  CatalogCubit(this._getCatalogItemsUseCase) : super(const CatalogState());

  Future<void> init() async {
    emit(state.copyWith(isLoading: true, errorMessage: ''));

    final categoriesResult = await _getCatalogItemsUseCase.getCategories();
    final itemsResult = await _getCatalogItemsUseCase.execute(
      request: const ProductRequest(page: 1, limit: pageLimit),
    );

    categoriesResult.fold(
          (error) => emit(state.copyWith(isLoading: false, errorMessage: error.message)),
          (categoryResponse) {
        final allCategories = categoryResponse.data?.items ?? [];

        itemsResult.fold(
              (error) => emit(state.copyWith(isLoading: false, errorMessage: error.message)),
              (productResponse) {
            final items = productResponse.data?.items ?? [];
            final totalPages = productResponse.data?.pageMeta?.totalPages ?? 1;

            emit(state.copyWith(
              isLoading: false,
              categories: allCategories,
              items: items,
              selectedCategory: 'All',
              selectedCategoryId: null,
              currentPage: 1,
              totalPages: totalPages,
              hasReachedMax: 1 >= totalPages,
            ));
          },
        );
      },
    );
  }

  Future<void> selectCategory(String categoryName) async {
    if (state.selectedCategory == categoryName && !state.isLoading) return;

    String? targetCategoryId;
    if (categoryName != 'All') {
      final category = state.categories.where((e) => e.name == categoryName).firstOrNull;
      targetCategoryId = category?.id;
    }

    emit(state.copyWith(
      isLoading: true,
      selectedCategory: categoryName,
      selectedCategoryId: targetCategoryId,
      items: [],
      currentPage: 1,
      hasReachedMax: false,
      errorMessage: '',
    ));

    final result = await _getCatalogItemsUseCase.execute(
      request: ProductRequest(
        page: 1,
        limit: pageLimit,
        categoryId: targetCategoryId,
      ),
    );

    result.fold(
          (error) => emit(state.copyWith(isLoading: false, errorMessage: error.message)),
          (productResponse) {
        final items = productResponse.data?.items ?? [];
        final totalPages = productResponse.data?.pageMeta?.totalPages ?? 1;

        emit(state.copyWith(
          isLoading: false,
          items: items,
          currentPage: 1,
          totalPages: totalPages,
          hasReachedMax: 1 >= totalPages,
        ));
      },
    );
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || state.hasReachedMax) return;

    emit(state.copyWith(isLoadingMore: true));

    final nextPage = state.currentPage + 1;
    final result = await _getCatalogItemsUseCase.execute(
      request: ProductRequest(
        page: nextPage,
        limit: pageLimit,
        categoryId: state.selectedCategoryId,
      ),
    );

    result.fold(
          (error) => emit(state.copyWith(isLoadingMore: false, errorMessage: error.message)),
          (productResponse) {
        final newItems = productResponse.data?.items ?? [];
        final totalPages = productResponse.data?.pageMeta?.totalPages ?? state.totalPages;
        final updatedItems = [...state.items, ...newItems];

        emit(state.copyWith(
          isLoadingMore: false,
          items: updatedItems,
          currentPage: nextPage,
          totalPages: totalPages,
          hasReachedMax: nextPage >= totalPages || newItems.isEmpty,
        ));
      },
    );
  }
}