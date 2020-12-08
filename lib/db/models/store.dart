import 'package:chipchop_seller/db/models/product_categories_map.dart';
import 'package:chipchop_seller/services/analytics/analytics.dart';
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
  String name;
  @JsonKey(name: 'short_details', defaultValue: "")
  String shortDetails;
  @JsonKey(name: 'geo_point', defaultValue: "")
  GeoPointData geoPoint;
  @JsonKey(name: 'avail_products')
  List<ProductCategoriesMap> availProducts;
  @JsonKey(name: 'avail_product_categories')
  List<ProductCategoriesMap> availProductCategories;
  @JsonKey(name: 'avail_product_sub_categories')
  List<ProductCategoriesMap> availProductSubCategories;
  @JsonKey(name: 'working_days')
  List<int> workingDays;
  @JsonKey(name: 'active_from')
  String activeFrom;
  @JsonKey(name: 'active_till')
  String activeTill;
  @JsonKey(name: 'address')
  Address address;
  @JsonKey(name: 'deliver_anywhere', defaultValue: false)
  bool deliverAnywhere;
  @JsonKey(name: 'is_active', defaultValue: true)
  bool isActive;
  @JsonKey(name: 'image', defaultValue: "")
  String image;
  @JsonKey(name: 'store_images', defaultValue: [""])
  List<String> storeImages;
  @JsonKey(name: 'users')
  List<String> users;
  @JsonKey(name: 'upi')
  String upiID;
  @JsonKey(name: 'wallet_number')
  String walletNumber;
  @JsonKey(name: 'avail_payments')
  List<int> availablePayments; // 0 - Cash, 1 - Gpay, 2 - Card, 3, PayTM
  @JsonKey(name: 'users_access')
  List<StoreUserAccess> usersAccess;
  @JsonKey(name: 'contacts')
  List<StoreContacts> contacts;
  @JsonKey(name: 'delivery')
  DeliveryDetails deliveryDetails;
  @JsonKey(name: 'keywords', defaultValue: [""])
  List<String> keywords;
  @JsonKey(name: 'created_at', nullable: true)
  DateTime createdAt;
  @JsonKey(name: 'updated_at', nullable: true)
  DateTime updatedAt;

  Store();

  List<String> getStoreImages() {
    if (this.storeImages.isEmpty) {
      return [
        no_image_placeholder.replaceFirst(
            firebase_storage_path, image_kit_path + ik_medium_size)
      ];
    } else {
      if (this.storeImages.first != null && this.storeImages.first != "") {
        List<String> images = [];
        for (var img in this.storeImages) {
          images.add(img.replaceFirst(
              firebase_storage_path, image_kit_path + ik_medium_size));
        }
        return images;
      } else
        return [
          no_image_placeholder.replaceFirst(
              firebase_storage_path, image_kit_path + ik_medium_size)
        ];
    }
  }

  String getPrimaryImage() {
    if (image != null && image.trim() != "")
      return image.replaceFirst(
          firebase_storage_path, image_kit_path + ik_medium_size);
    else
      return no_image_placeholder.replaceFirst(
          firebase_storage_path, image_kit_path + ik_medium_size);
  }

  List<String> getStoreOriginalImages() {
    if (this.storeImages.isEmpty) {
      return [
        no_image_placeholder.replaceFirst(firebase_storage_path, image_kit_path)
      ];
    } else {
      if (this.storeImages.first != null && this.storeImages.first != "") {
        List<String> images = [];
        for (var img in this.storeImages) {
          images.add(img.replaceFirst(firebase_storage_path, image_kit_path));
        }
        return images;
      } else
        return [
          no_image_placeholder.replaceFirst(
              firebase_storage_path, image_kit_path)
        ];
    }
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
    try {
      bWrite.setData(docRef, this.toJson());
      cachedLocalUser.stores == null
          ? cachedLocalUser.stores = [this.uuid]
          : cachedLocalUser.stores.add(this.uuid);
      bWrite.updateData(
          cachedLocalUser.getDocumentReference(cachedLocalUser.getID()),
          {'stores': cachedLocalUser.stores});
      await bWrite.commit();

      Analytics.sendAnalyticsEvent(
          {'type': 'store_create', 'store_id': this.uuid}, 'store');
      return this;
    } catch (err) {
      if (cachedLocalUser.stores.contains(this.uuid))
        cachedLocalUser.stores.remove(this.uuid);
      Analytics.reportError({
        'type': 'store_create_error',
        'store_id': this.uuid,
        'message': err.toString()
      }, 'store');
      throw err;
    }
  }

  Future<void> updateLocation(GeoPointData geoData) async {
    try {
      await this.update({'geo_point': geoData.toJson()});
    } catch (err) {
      throw err;
    }
  }

  Stream<QuerySnapshot> streamStoresForUser() {
    return getCollectionRef()
        .where('users', arrayContains: cachedLocalUser.getID())
        .snapshots();
  }

  Future<List<Store>> getStoresForUser() async {
    try {
      QuerySnapshot snap = await getCollectionRef()
          .where('users', arrayContains: cachedLocalUser.getID())
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

  Future<List<Map<String, dynamic>>> getStoreByName(String searchKey) async {
    List<Map<String, dynamic>> stores = [];

    QuerySnapshot snap = await getCollectionRef()
        .where('keywords', arrayContainsAny: searchKey.split(' '))
        .getDocuments();
    if (snap.documents.isNotEmpty) {
      for (var i = 0; i < snap.documents.length; i++) {
        stores.add(snap.documents[i].data);
      }
    }

    return stores;
  }

  Future updateStoreStatus(String docID, bool isLive) async {
    try {
      await getCollectionRef()
          .document(docID)
          .updateData({'is_active': isLive, 'updated_at': DateTime.now()});
    } catch (err) {
      Analytics.reportError({
        'type': 'store_status_update_error',
        'store_id': docID,
        'message': err.toString()
      }, 'store');
      throw err;
    }
  }
}
