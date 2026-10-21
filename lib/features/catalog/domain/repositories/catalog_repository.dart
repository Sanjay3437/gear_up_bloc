import 'package:gear_up_bloc/core/exceptions/http_exception.dart';
import 'package:gear_up_bloc/core/network/model/either.dart';
import 'package:gear_up_bloc/features/catalog/data/models/category_response.dart';
import 'package:gear_up_bloc/features/catalog/data/models/product_detail_request.dart';
import 'package:gear_up_bloc/features/catalog/data/models/product_detail_response.dart';
import 'package:gear_up_bloc/features/catalog/data/models/product_request.dart';
import 'package:gear_up_bloc/features/catalog/data/models/product_response.dart';

abstract class CatalogRepository {
  Future<Either<AppException, ProductResponse>> getCatalogItems({
    ProductRequest? request,
  });

  Future<Either<AppException, CategoryResponse>> getCategories();

  Future<Either<AppException, ProductDetailResponse>> getProductDetail(
      ProductDetailRequest request,
      );
}






