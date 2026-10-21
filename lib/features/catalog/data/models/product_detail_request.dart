class ProductDetailRequest {
  final String id;

  const ProductDetailRequest({required this.id});

  Map<String, dynamic> toJson() => {"id": id};
}