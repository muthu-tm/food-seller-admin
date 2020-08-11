// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeliveryDetails _$DeliveryDetailsFromJson(Map<String, dynamic> json) {
  return DeliveryDetails()
    ..maxDistance = json['max_distance'] as int ?? 5
    ..deliveryFrom = json['delivery_from'] as int
    ..deliveryTill = json['delivery_till'] as int
    ..availableOptions =
        (json['delivery_options'] as List)?.map((e) => e as int)?.toList() ??
            [1, 2]
    ..deliveryCharges02 = json['delivery_charges_02'] as int
    ..deliveryCharges25 = json['delivery_charges_25'] as int
    ..deliveryChargesPerKM = json['delivery_charges_km'] as int;
}

Map<String, dynamic> _$DeliveryDetailsToJson(DeliveryDetails instance) =>
    <String, dynamic>{
      'max_distance': instance.maxDistance ?? 5,
      'delivery_from': instance.deliveryFrom,
      'delivery_till': instance.deliveryTill,
      'delivery_options': instance.availableOptions ?? [1, 2],
      'delivery_charges_02': instance.deliveryCharges02,
      'delivery_charges_25': instance.deliveryCharges25,
      'delivery_charges_km': instance.deliveryChargesPerKM,
    };
