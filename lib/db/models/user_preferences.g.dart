// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPreferences _$UserPreferencesFromJson(Map<String, dynamic> json) {
  return UserPreferences()
    ..prefLanguage = json['language'] as String ?? 'English'
    ..isfingerAuthEnabled = json['enable_fingerprint_auth'] as bool ?? false;
}

Map<String, dynamic> _$UserPreferencesToJson(UserPreferences instance) =>
    <String, dynamic>{
      'language': instance.prefLanguage,
      'enable_fingerprint_auth': instance.isfingerAuthEnabled,
    };
