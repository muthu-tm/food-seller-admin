part of 'products.dart';

Products _$ProductsFromJson(Map<String, dynamic> json) {
  return Products()
    ..uuid = json['uuid'] as String
    ..name = json['name'] as String ?? ''
    ..shortDetails = json['short_details'] as String
    ..storeUUID = json['store_uuid'] as String ?? ''
    ..locUUID = json['loc_uuid'] as String ?? ''
    ..productImages = (json['product_images'] as List)
            ?.map((e) => e == null ? null : e as String)
            ?.toList() ??
        []
    ..weight = (json['weight'] as num)?.toDouble() ?? 0.00
    ..originalPrice = (json['org_price'] as num)?.toDouble() ?? 0.00
    ..offer = (json['offer'] as num)?.toDouble() ?? 0.00
    ..currentPrice = (json['current_price'] as num)?.toDouble() ?? 0.00
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

Map<String, dynamic> _$ProductsToJson(Products instance) => <String, dynamic>{
      'uuid': instance.uuid,
      'name': instance.name,
      'short_details': instance.shortDetails,
      'store_uuid': instance.storeUUID ?? "",
      'loc_uuid': instance.locUUID ?? "",
      'product_images': instance.productImages == null ? [] : instance.productImages,
      'weight': instance.weight ?? 0.00,
      'org_price': instance.originalPrice ?? 0.00,
      'offer': instance.offer ?? 0.00,
      'current_price': instance.currentPrice ?? 0.00,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
