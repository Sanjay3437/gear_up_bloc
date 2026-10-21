class ProductRequest {
  final int? page;
  final int? limit;
  final String? categoryId;
  final String? search;
  final String? sortBy;

  const ProductRequest({
    this.page,
    this.limit,
    this.categoryId,
    this.search,
    this.sortBy,
  });

  Map<String, dynamic> toQueryParams() {
    final Map<String, dynamic> params = {};
    if (page != null) params["page"] = page;
    if (limit != null) params["limit"] = limit;
    if (categoryId != null && categoryId!.isNotEmpty) {
      params["categoryId"] = categoryId;
    }
    if (search != null && search!.isNotEmpty) params["search"] = search;
    if (sortBy != null && sortBy!.isNotEmpty) params["sortBy"] = sortBy;
    return params;
  }
}