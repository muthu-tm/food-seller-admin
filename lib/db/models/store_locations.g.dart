// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_locations.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StoreLocations _$StoreLocationsFromJson(Map<String, dynamic> json) {
  return StoreLocations()
    ..uuid = json['uuid'] as String ?? ''
    ..storeUUID = json['store_uuid'] as String ?? ''
    ..locationName = json['loc_name'] as String ?? ''
    ..availProducts =
        (json['avail_products'] as List)?.map((e) => e as String)?.toList()
    ..availProductCategories = (json['avail_product_categories'] as List)
        ?.map((e) => e as String)
        ?.toList()
    ..availProductSubCategories = (json['avail_product_sub_categories'] as List)
        ?.map((e) => e as String)
        ?.toList()
    ..workingDays =
        (json['working_days'] as List)?.map((e) => e as int)?.toList()
    ..activeFrom = json['active_from'] as String
    ..activeTill = json['active_till'] as String
    ..address = json['address'] == null
        ? new Address()
        : Address.fromJson(json['address'] as Map<String, dynamic>)
    ..geoPoint = json['geo_point'] == null
        ? null
        : GeoPointData.fromJson(json['geo_point'] as Map<String, dynamic>)
    ..isActive = json['is_active'] as bool ?? true
    ..contacts = (json['contacts'] as List)
        ?.map((e) => e == null
            ? null
            : StoreContacts.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..storeProfile = json['store_profile'] as String ?? ''
    ..users = (json['users'] as List)
            ?.map((e) => e == null ? null : e as int)
            ?.toList() ??
        []
    ..usersAccess = (json['users_access'] as List)
        ?.map((e) => e == null
            ? null
            : StoreUserAccess.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..deliveryDetails = (json['delivery'] as List)
        ?.map((e) => e == null
            ? new DeliveryDetails()
            : DeliveryDetails.fromJson(e as Map<String, dynamic>))
        ?.toList();
}

Map<String, dynamic> _$StoreLocationsToJson(StoreLocations instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'store_uuid': instance.storeUUID,
      'loc_name': instance.locationName,
      'avail_products': instance.availProducts,
      'working_days': instance.workingDays,
      'active_from': instance.activeFrom,
      'active_till': instance.activeTill,
      'address': instance.address?.toJson(),
      'geo_point': instance.geoPoint?.toJson(),
      'is_active': instance.isActive,
      'store_profile': instance.storeProfile ?? "",
      'contacts': instance.contacts?.map((e) => e?.toJson())?.toList(),
      'users': instance.users == null ? [] : instance.users,
      'users_access': instance.usersAccess?.map((e) => e?.toJson())?.toList(),
      'delivery': instance.deliveryDetails?.map((e) => e?.toJson())?.toList(),
    };
