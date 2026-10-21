class CategoryModel {
  final String? id;
  final String? name;
  final String? slug;
  final String? iconUrl;
  final String? bannerUrl;
  final int? displayOrder;

  const CategoryModel({
    this.id,
    this.name,
    this.slug,
    this.iconUrl,
    this.bannerUrl,
    this.displayOrder,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
    id: json["id"] ?? "",
    name: json["name"] ?? "",
    slug: json["slug"] ?? "",
    iconUrl: json["iconUrl"] ?? "",
    bannerUrl: json["bannerUrl"] ?? "",
    displayOrder: json["displayOrder"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "slug": slug,
    "iconUrl": iconUrl,
    "bannerUrl": bannerUrl,
    "displayOrder": displayOrder,
  };
}