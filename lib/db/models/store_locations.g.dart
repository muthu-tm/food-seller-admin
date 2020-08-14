// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_locations.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StoreLocations _$StoreLocationsFromJson(Map<String, dynamic> json) {
  return StoreLocations()
    ..locationName = json['loc_name'] as String ?? ''
    ..availProducts =
        (json['avail_products'] as List)?.map((e) => e as int)?.toList()
    ..workingDays =
        (json['working_days'] as List)?.map((e) => e as int)?.toList()
    ..activeFrom = json['active_from'] as String
    ..activeTill = json['active_till'] as String
    ..address = json['address'] == null
        ? new Address()
        : Address.fromJson(json['address'] as Map<String, dynamic>)
    ..isActive = json['is_active'] as bool ?? true
    ..contacts = (json['contacts'] as List)
        ?.map((e) => e == null
            ? null
            : StoreContacts.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..deliveryDetails = (json['delivery'] as List)
        ?.map((e) => e == null
            ? null
            : DeliveryDetails.fromJson(e as Map<String, dynamic>))
        ?.toList();
}

Map<String, dynamic> _$StoreLocationsToJson(StoreLocations instance) =>
    <String, dynamic>{
      'loc_name': instance.locationName,
      'avail_products': instance.availProducts,
      'working_days': instance.workingDays,
      'active_from': instance.activeFrom,
      'active_till': instance.activeTill,
      'address': instance.address?.toJson(),
      'is_active': instance.isActive,
      'contacts': instance.contacts?.map((e) => e?.toJson())?.toList(),
      'delivery': instance.deliveryDetails?.map((e) => e?.toJson())?.toList(),
    };
