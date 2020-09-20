import 'package:chipchop_seller/db/models/delivery_details.dart';
import 'package:chipchop_seller/db/models/model.dart';
import 'package:chipchop_seller/db/models/store.dart';
import 'package:chipchop_seller/db/models/store_contacts.dart';
import 'package:chipchop_seller/db/models/address.dart';
import 'package:chipchop_seller/db/models/geopoint_data.dart';
import 'package:chipchop_seller/db/models/store_user_access.dart';
import 'package:chipchop_seller/services/controllers/user/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'store_locations.g.dart';

@JsonSerializable(explicitToJson: true)
class StoreLocations {
  @JsonKey(name: 'uuid', defaultValue: "")
  String uuid;
  @JsonKey(name: 'store_uuid', defaultValue: "")
  String storeUUID;
  @JsonKey(name: 'loc_name', defaultValue: "")
  String locationName;
  @JsonKey(name: 'geo_point', defaultValue: "")
  GeoPointData geoPoint;
  @JsonKey(name: 'avail_products')
  List<String> availProducts;
  @JsonKey(name: 'avail_product_categories')
  List<String> availProductCategories;
  @JsonKey(name: 'avail_product_sub_categories')
  List<String> availProductSubCategories;
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
  @JsonKey(name: 'store_profile', defaultValue: "")
  String storeProfile;
  @JsonKey(name: 'users')
  List<int> users;
  @JsonKey(name: 'users_access')
  List<StoreUserAccess> usersAccess;
  @JsonKey(name: 'contacts')
  List<StoreContacts> contacts;
  @JsonKey(name: 'delivery')
  List<DeliveryDetails> deliveryDetails;

  StoreLocations();

  factory StoreLocations.fromJson(Map<String, dynamic> json) =>
      _$StoreLocationsFromJson(json);
  Map<String, dynamic> toJson() => _$StoreLocationsToJson(this);

  CollectionReference getCollectionRef(String uuid) {
    return Store().getDocumentReference(uuid).collection("store_locations");
  }

  Query getGroupQuery() {
    return Model.db.collectionGroup('store_locations');
  }

  String getID() {
    return this.uuid;
  }

  DocumentReference getDocumentReference(String storeUUID, String locUUID) {
    return getCollectionRef(storeUUID).document(locUUID);
  }

  Future<List<StoreLocations>> getStoresWithLocation() async {
    try {
      List<StoreLocations> stores = [];

      QuerySnapshot locsnap = await getGroupQuery()
          .where('users', arrayContains: cachedLocalUser.getIntID())
          .getDocuments();

      if (locsnap.documents.isNotEmpty) {
        for (var j = 0; j < locsnap.documents.length; j++) {
          StoreLocations _sl =
              StoreLocations.fromJson(locsnap.documents[j].data);
          stores.add(_sl);
        }
      }

      return stores;
    } catch (err) {
      throw err;
    }
  }
}
