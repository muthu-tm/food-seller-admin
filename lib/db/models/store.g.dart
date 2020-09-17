// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Store _$StoreFromJson(Map<String, dynamic> json) {
  return Store()
    ..uuid = json['uuid'] as String
    ..storeName = json['store_name'] as String ?? ''
    ..ownedBy = json['owned_by'] as String
    ..storeProfile = json['store_profile'] as String ?? ''
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

Map<String, dynamic> _$StoreToJson(Store instance) => <String, dynamic>{
      'uuid': instance.uuid,
      'store_name': instance.storeName,
      'owned_by': instance.ownedBy,
      'store_profile': instance.storeProfile ?? "",
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
