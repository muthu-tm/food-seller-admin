import 'package:chipchop_seller/db/models/store_locations.dart';
import 'package:chipchop_seller/services/utils/constants.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chipchop_seller/db/models/model.dart';
part 'products.g.dart';

@JsonSerializable(explicitToJson: true)
class Products extends Model {
  static CollectionReference _storeCollRef = Model.db.collection("products");

  @JsonKey(name: 'uuid', nullable: false)
  String uuid;
  @JsonKey(name: 'name', defaultValue: "")
  String name;
  @JsonKey(name: 'short_details', defaultValue: "")
  String shortDetails;
  @JsonKey(name: 'store_uuid', defaultValue: "")
  String storeUUID;
  @JsonKey(name: 'loc_uuid', defaultValue: "")
  String locUUID;
  @JsonKey(name: 'product_images', defaultValue: [""])
  List<String> productImages;
  @JsonKey(name: 'weight')
  double weight;
  @JsonKey(name: 'org_price')
  double originalPrice;
  @JsonKey(name: 'offer', defaultValue: 0.00)
  double offer;
  @JsonKey(name: 'current_price')
  double currentPrice;
  @JsonKey(name: 'created_at', nullable: true)
  DateTime createdAt;
  @JsonKey(name: 'updated_at', nullable: true)
  DateTime updatedAt;

  Products();

  List<String> getSmallProfilePicPath() {
    List<String> paths = [];

    for (var productImage in productImages) {
      if (productImage != null && productImage != "")
        paths.add(productImage.replaceFirst(
            firebase_storage_path, image_kit_path + ik_small_size));
    }

    return paths;
  }

  List<String> getMediumProfilePicPath() {
    List<String> paths = [];

    for (var productImage in productImages) {
      if (productImage != null && productImage != "")
        paths.add(productImage.replaceFirst(
            firebase_storage_path, image_kit_path + ik_medium_size));
    }

    return paths;
  }

  factory Products.fromJson(Map<String, dynamic> json) =>
      _$ProductsFromJson(json);
  Map<String, dynamic> toJson() => _$ProductsToJson(this);

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

  Future<Products> create(StoreLocations loc) async {
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
}
