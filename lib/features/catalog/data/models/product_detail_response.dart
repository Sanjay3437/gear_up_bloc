class ProductDetailResponse {
  final bool? status;
  final String? message;
  final ProductDetailModel? data;

  const ProductDetailResponse({this.status, this.message, this.data});

  factory ProductDetailResponse.fromJson(Map<String, dynamic> json) =>
      ProductDetailResponse(
        status: json["status"] ?? false,
        message: json["message"] ?? "",
        data: json["data"] != null
            ? ProductDetailModel.fromJson(json["data"])
            : null,
      );
}

class ProductDetailModel {
  final String? id;
  final String? name;
  final String? packSize;
  final num? mrp;
  final num? discountPrice;
  final int? stock;
  final String? imageUrl;
  final String? dealBadge;
  final num? rating;
  final int? ratingCount;
  final List<String>? images;
  final String? description;
  final String? categoryName;

  const ProductDetailModel({
    this.id,
    this.name,
    this.packSize,
    this.mrp,
    this.discountPrice,
    this.stock,
    this.imageUrl,
    this.dealBadge,
    this.rating,
    this.ratingCount,
    this.images,
    this.description,
    this.categoryName,
  });

  factory ProductDetailModel.fromJson(Map<String, dynamic> json) =>
      ProductDetailModel(
        id: json["id"] ?? "",
        name: json["name"] ?? "",
        packSize: json["packSize"] ?? "",
        mrp: json["mrp"] ?? 0,
        discountPrice: json["discountPrice"] ?? 0,
        stock: json["stock"] ?? 0,
        imageUrl: json["imageUrl"] ?? "",
        dealBadge: json["dealBadge"] ?? "",
        rating: json["rating"] ?? 0.0,
        ratingCount: json["ratingCount"] ?? 0,
        images: json["images"] != null
            ? List<String>.from(json["images"].map((x) => x.toString()))
            : [],
        description: json["description"] ?? "",
        categoryName: json["categoryName"] ?? "",
      );
}