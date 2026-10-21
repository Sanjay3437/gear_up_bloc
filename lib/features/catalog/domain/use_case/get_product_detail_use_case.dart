import 'package:gear_up_bloc/core/exceptions/http_exception.dart';
import 'package:gear_up_bloc/core/network/model/either.dart';
import 'package:gear_up_bloc/features/catalog/data/models/product_detail_request.dart';
import 'package:gear_up_bloc/features/catalog/data/models/product_detail_response.dart';
import 'package:gear_up_bloc/features/catalog/domain/repositories/catalog_repository.dart';

class GetProductDetailUseCase {
  final CatalogRepository _repository;

  GetProductDetailUseCase(this._repository);

  Future<Either<AppException, ProductDetailResponse>> execute(
      ProductDetailRequest request,
      ) {
    return _repository.getProductDetail(request);
  }
}