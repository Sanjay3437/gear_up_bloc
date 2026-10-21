import 'package:gear_up_bloc/core/exceptions/http_exception.dart';
import 'package:gear_up_bloc/core/network/model/either.dart';
import 'package:gear_up_bloc/features/catalog/data/models/category_response.dart';
import 'package:gear_up_bloc/features/catalog/data/models/product_request.dart';
import 'package:gear_up_bloc/features/catalog/data/models/product_response.dart';
import 'package:gear_up_bloc/features/catalog/domain/repositories/catalog_repository.dart';

class GetCatalogItemsUseCase {
  final CatalogRepository repository;

  GetCatalogItemsUseCase(this.repository);

  Future<Either<AppException, ProductResponse>> execute({
    ProductRequest? request,
  }) {
    return repository.getCatalogItems(request: request);
  }

  Future<Either<AppException, CategoryResponse>> getCategories() {
    return repository.getCategories();
  }
}