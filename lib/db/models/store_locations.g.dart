// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_locations.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StoreLocations _$StoreLocationsFromJson(Map<String, dynamic> json) {
  return StoreLocations()
    ..locationName = json['loc_name'] as String ?? ''
    ..workingDays =
        (json['working_days'] as List)?.map((e) => e as int)?.toList()
    ..activeFrom = json['active_from'] as int
    ..activeTill = json['active_till'] as int
    ..address = json['address'] as String
    ..pincode = json['pincode'] as String ?? ''
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
      'working_days': instance.workingDays,
      'active_from': instance.activeFrom,
      'active_till': instance.activeTill,
      'address': instance.address,
      'pincode': instance.pincode,
      'is_active': instance.isActive,
      'contacts': instance.contacts?.map((e) => e?.toJson())?.toList(),
      'delivery': instance.deliveryDetails?.map((e) => e?.toJson())?.toList(),
    };
