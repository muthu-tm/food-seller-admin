import 'package:chipchop_seller/db/models/store_locations.dart';
import 'package:chipchop_seller/services/controllers/user/user_service.dart';
import 'package:chipchop_seller/services/utils/constants.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chipchop_seller/db/models/model.dart';
import 'package:chipchop_seller/db/models/store_contacts.dart';
import 'package:chipchop_seller/db/models/address.dart';
import 'package:chipchop_seller/db/models/geopoint_data.dart';
import 'package:chipchop_seller/db/models/store_user_access.dart';
import 'package:chipchop_seller/db/models/delivery_details.dart';
part 'store.g.dart';

@JsonSerializable(explicitToJson: true)
class Store extends Model {
  static CollectionReference _storeCollRef = Model.db.collection("stores");

  @JsonKey(name: 'uuid', nullable: false)
  String uuid;
  @JsonKey(name: 'owned_by', defaultValue: "")
  String ownedBy;
  @JsonKey(name: 'store_name', defaultValue: "")
  String storeName;
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
  @JsonKey(name: 'created_at', nullable: true)
  DateTime createdAt;
  @JsonKey(name: 'updated_at', nullable: true)
  DateTime updatedAt;

  StoreLocations location;

  Store();

  String getMediumProfilePicPath() {
    if (this.storeProfile != null && this.storeProfile != "")
      return this
          .storeProfile
          .replaceFirst(firebase_storage_path, image_kit_path + ik_medium_size);
    else
        return no_image_placeholder.replaceFirst(
            firebase_storage_path, image_kit_path + ik_medium_size);
  }

  factory Store.fromJson(Map<String, dynamic> json) => _$StoreFromJson(json);
  Map<String, dynamic> toJson() => _$StoreToJson(this);

  CollectionReference getCollectionRef() {
    return _storeCollRef;
  }

  DocumentReference getDocumentReference(String uuid) {
    return _storeCollRef.document(uuid);
  }

  String getID() {
    return this.uuid;
  }

  Stream<DocumentSnapshot> streamStoreData() {
    return getDocumentReference(getID()).snapshots();
  }

  Future<Store> create() async {
    this.createdAt = DateTime.now();
    this.updatedAt = DateTime.now();

    WriteBatch bWrite = Model.db.batch();

    DocumentReference docRef = this.getCollectionRef().document();
    this.uuid = docRef.documentID;
    bWrite.setData(docRef, this.toJson());
    await bWrite.commit();
    return this;
  }

  Stream<QuerySnapshot> streamStoresForUser() {
    return getCollectionRef()
        .where('users', arrayContains: cachedLocalUser.getIntID())
        .snapshots();
  }

  Future<List<Store>> getStoresForUser() async {
    try {
      QuerySnapshot snap = await getCollectionRef()
          .where('users', arrayContains: cachedLocalUser.getIntID())
          .getDocuments();

      List<Store> stores = [];
      if (snap.documents.isNotEmpty) {
        for (var i = 0; i < snap.documents.length; i++) {
          Store _s = Store.fromJson(snap.documents[i].data);
          stores.add(_s);
        }
      }

      return stores;
    } catch (err) {
      throw err;
    }
  }

  Future<List<Store>> getStoresWithLocation() async {
    try {
      List<Store> stores = [];

      QuerySnapshot snap = await getCollectionRef()
          .where('users', arrayContains: cachedLocalUser.getIntID())
          .getDocuments();
      if (snap.documents.isNotEmpty) {
        for (var i = 0; i < snap.documents.length; i++) {
          Store _s = Store.fromJson(snap.documents[i].data);
          QuerySnapshot locsnap = await getDocumentReference(_s.uuid)
              .collection("store_locations")
              .where('users', arrayContains: cachedLocalUser.getIntID())
              .getDocuments();

          if (locsnap.documents.isNotEmpty) {
            for (var j = 0; j < locsnap.documents.length; j++) {
              StoreLocations _sl =
                  StoreLocations.fromJson(locsnap.documents[j].data);
              _s.location = _sl;
              stores.add(_s);
            }
          }
          // stores.add(_s);
        }
      }

      return stores;
    } catch (err) {
      throw err;
    }
  }

  Future<List<StoreLocations>> getLocations(String uuid) async {
    try {
      List<StoreLocations> locations = [];

      QuerySnapshot locsnap = await getDocumentReference(uuid)
          .collection("store_locations")
          .where('users', arrayContains: cachedLocalUser.getIntID())
          .getDocuments();

      if (locsnap.documents.isNotEmpty) {
        for (var j = 0; j < locsnap.documents.length; j++) {
          StoreLocations _sl =
              StoreLocations.fromJson(locsnap.documents[j].data);
          locations.add(_sl);
        }
      }

      return locations;
    } catch (err) {
      throw err;
    }
  }
}
