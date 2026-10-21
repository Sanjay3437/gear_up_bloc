import 'package:gear_up_bloc/core/exceptions/http_exception.dart';
import 'package:gear_up_bloc/core/network/model/either.dart';
import 'package:gear_up_bloc/features/catalog/data/data_source/catalog_remote_data_source.dart';
import 'package:gear_up_bloc/features/catalog/data/models/category_response.dart';
import 'package:gear_up_bloc/features/catalog/data/models/product_detail_request.dart';
import 'package:gear_up_bloc/features/catalog/data/models/product_detail_response.dart';
import 'package:gear_up_bloc/features/catalog/data/models/product_request.dart';
import 'package:gear_up_bloc/features/catalog/data/models/product_response.dart';
import 'package:gear_up_bloc/features/catalog/domain/repositories/catalog_repository.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  final CatalogRemoteDataSource remoteDataSource;

  CatalogRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<AppException, ProductResponse>> getCatalogItems({
    ProductRequest? request,
  }) {
    return remoteDataSource.getCatalogItems(request: request);
  }

  @override
  Future<Either<AppException, CategoryResponse>> getCategories() {
    return remoteDataSource.getCategories();
  }

  @override
  Future<Either<AppException, ProductDetailResponse>> getProductDetail(
      ProductDetailRequest request,
      ) {
    return remoteDataSource.getProductDetail(request);
  }
}