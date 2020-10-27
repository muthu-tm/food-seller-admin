part of 'product_sub_categories.dart';

ProductSubCategories _$ProductSubCategoriesFromJson(Map<String, dynamic> json) {
  return ProductSubCategories()
    ..uuid = json['uuid'] as String
    ..categoryID = json['category_id'] as String
    ..name = json['name'] as String ?? ''
    ..shortDetails = json['short_details'] as String
    ..productImages = (json['product_images'] as List)
            ?.map((e) => e == null ? null : e as String)
            ?.toList() ??
        []
    ..createdAt = json['created_at'] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(
            _getMillisecondsSinceEpoch(json['created_at'] as Timestamp))
    ..updatedAt = json['updated_at'] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(
            _getMillisecondsSinceEpoch(json['updated_at'] as Timestamp));
}

int _getMillisecondsSinceEpoch(Timestamp ts) {
  return ts.millisecondsSinceEpoch;
}

Map<String, dynamic> _$ProductSubCategoriesToJson(
        ProductSubCategories instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'category_id': instance.categoryID,
      'name': instance.name,
      'short_details': instance.shortDetails,
      'product_images':
          instance.productImages == null ? [] : instance.productImages,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
