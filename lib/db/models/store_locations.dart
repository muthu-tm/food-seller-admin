import 'package:chipchop_seller/db/models/delivery_details.dart';
import 'package:chipchop_seller/db/models/store_contacts.dart';
import 'package:chipchop_seller/db/models/address.dart';
import 'package:json_annotation/json_annotation.dart';

part 'store_locations.g.dart';

@JsonSerializable(explicitToJson: true)
class StoreLocations {
  @JsonKey(name: 'loc_name', defaultValue: "")
  String locationName;
  @JsonKey(name: 'avail_products')
  List<int> availProducts;
  @JsonKey(name: 'working_days')
  List<int> workingDays;
  @JsonKey(name: 'active_from')
  String activeFrom;
  @JsonKey(name: 'active_till')
  String activeTill;
  @JsonKey(name: 'address')
  Address address;
  @JsonKey(name: 'is_active', defaultValue: true)
  bool isActive;
  @JsonKey(name: 'contacts')
  List<StoreContacts> contacts;
  @JsonKey(name: 'delivery')
  List<DeliveryDetails> deliveryDetails;

  StoreLocations();

  factory StoreLocations.fromJson(Map<String, dynamic> json) =>
      _$StoreLocationsFromJson(json);
  Map<String, dynamic> toJson() => _$StoreLocationsToJson(this);
}
