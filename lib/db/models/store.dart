import 'package:chipchop_seller/db/models/store_locations.dart';
import 'package:chipchop_seller/services/controllers/user/user_service.dart';
import 'package:chipchop_seller/services/utils/constants.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chipchop_seller/db/models/model.dart';
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
  @JsonKey(name: 'store_profile', defaultValue: "")
  String storeProfile;
  @JsonKey(name: 'users')
  List<int> users;
  @JsonKey(name: 'created_at', nullable: true)
  DateTime createdAt;
  @JsonKey(name: 'updated_at', nullable: true)
  DateTime updatedAt;

  Store();

  String getMediumProfilePicPath() {
    if (this.storeProfile != null && this.storeProfile != "")
      return this
          .storeProfile
          .replaceFirst(firebase_storage_path, image_kit_path + ik_medium_size);
    else
      return "";
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

  Future<Store> create(StoreLocations loc) async {
    this.createdAt = DateTime.now();
    this.updatedAt = DateTime.now();

    WriteBatch bWrite = Model.db.batch();

    DocumentReference docRef = this.getCollectionRef().document();
    this.uuid = docRef.documentID;
    bWrite.setData(docRef, this.toJson());

    DocumentReference locDocRef = getDocumentReference(this.uuid)
        .collection("store_locations")
        .document();

    loc.uuid = locDocRef.documentID;
    bWrite.setData(locDocRef, loc.toJson());
    await bWrite.commit();
    return this;
  }

  Stream<QuerySnapshot> streamStoresForUser() {
    return getCollectionRef()
        .where('users', arrayContains: cachedLocalUser.getIntID())
        .snapshots();
  }
}
