import 'package:gear_up_bloc/core/constants/endpoints.dart';
import 'package:gear_up_bloc/core/exceptions/http_exception.dart';
import 'package:gear_up_bloc/core/network/model/either.dart';
import 'package:gear_up_bloc/core/network/network_service.dart';
import 'package:gear_up_bloc/core/utils/error_logger.dart';
import 'package:gear_up_bloc/features/catalog/data/models/category_response.dart';
import 'package:gear_up_bloc/features/catalog/data/models/product_detail_request.dart';
import 'package:gear_up_bloc/features/catalog/data/models/product_detail_response.dart';
import 'package:gear_up_bloc/features/catalog/data/models/product_request.dart';
import 'package:gear_up_bloc/features/catalog/data/models/product_response.dart';

abstract class CatalogRemoteDataSource {
  Future<Either<AppException, ProductResponse>> getCatalogItems({
    ProductRequest? request,
  });

  Future<Either<AppException, CategoryResponse>> getCategories();

  Future<Either<AppException, ProductDetailResponse>> getProductDetail(
      ProductDetailRequest request,
      );
}

class CatalogRemoteDataSourceImpl implements CatalogRemoteDataSource {
  final NetworkService networkService;

  CatalogRemoteDataSourceImpl(this.networkService);

  @override
  Future<Either<AppException, ProductResponse>> getCatalogItems({
    ProductRequest? request,
  }) async {
    try {
      Either eitherType = await networkService.get(
        ApiEndpoint.products,
        queryParameters: request?.toQueryParams(),
      );
      return eitherType.fold(
            (exception) => Left(exception),
            (response) => Right(ProductResponse.fromJson(response.data)),
      );
    } catch (e) {
      return ErrorLogger.handleException(
        e,
        'CatalogRemoteDataSource.getCatalogItems',
      );
    }
  }

  @override
  Future<Either<AppException, CategoryResponse>> getCategories() async {
    try {
      Either eitherType = await networkService.get(ApiEndpoint.categories);
      return eitherType.fold(
            (exception) => Left(exception),
            (response) => Right(CategoryResponse.fromJson(response.data)),
      );
    } catch (e) {
      return ErrorLogger.handleException(
        e,
        'CatalogRemoteDataSource.getCategories',
      );
    }
  }

  @override
  Future<Either<AppException, ProductDetailResponse>> getProductDetail(
      ProductDetailRequest request,
      ) async {
    try {
      Either eitherType = await networkService.get(
        '${ApiEndpoint.products}/${request.id}',
      );
      return eitherType.fold(
            (exception) => Left(exception),
            (response) => Right(ProductDetailResponse.fromJson(response.data)),
      );
    } catch (e) {
      return ErrorLogger.handleException(
        e,
        'CatalogRemoteDataSource.getProductDetail',
      );
    }
  }
}