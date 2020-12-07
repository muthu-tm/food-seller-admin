import 'package:chipchop_seller/db/models/store.dart';
import 'package:chipchop_seller/services/utils/constants.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chipchop_seller/db/models/model.dart';

part 'product_types.g.dart';

@JsonSerializable(explicitToJson: true)
class ProductTypes extends Model {
  static CollectionReference _storeCollRef =
      Model.db.collection("product_types");

  @JsonKey(name: 'uuid', nullable: false)
  String uuid;
  @JsonKey(name: 'name', defaultValue: "")
  String name;
  @JsonKey(name: 'short_details', defaultValue: "")
  String shortDetails;
  @JsonKey(name: 'product_images', defaultValue: [""])
  List<String> productImages;
  @JsonKey(name: 'created_at', nullable: true)
  DateTime createdAt;
  @JsonKey(name: 'updated_at', nullable: true)
  DateTime updatedAt;

  ProductTypes();

  List<String> getMediumProfilePicPath() {
    List<String> paths = [];

    for (var productImage in productImages) {
      if (productImage != null && productImage != "")
        paths.add(productImage.replaceFirst(
            firebase_storage_path, image_kit_path + ik_medium_size));
    }

    return paths;
  }

  factory ProductTypes.fromJson(Map<String, dynamic> json) =>
      _$ProductTypesFromJson(json);
  Map<String, dynamic> toJson() => _$ProductTypesToJson(this);

  CollectionReference getCollectionRef() {
    return _storeCollRef;
  }

  DocumentReference getDocumentReference(String uuid) {
    return _storeCollRef.document(uuid);
  }

  String getID() {
    return this.uuid;
  }

  Stream<QuerySnapshot> streamProductTypes() {
    return getCollectionRef().snapshots();
  }

  Future<List<ProductTypes>> getProductTypes() async {
    try {
      QuerySnapshot snap = await getCollectionRef().getDocuments();

      List<ProductTypes> types = [];
      if (snap.documents.isNotEmpty) {
        for (var i = 0; i < snap.documents.length; i++) {
          ProductTypes _s = ProductTypes.fromJson(snap.documents[i].data);
          types.add(_s);
        }
      }

      return types;
    } catch (err) {
      throw err;
    }
  }

  Future<List<ProductTypes>> getProductTypesForStoreID(String id) async {
    try {
      List<ProductTypes> types = [];
      if (id.trim().isNotEmpty && id.trim() != '0') {
        Map<String, dynamic> storeData = await Store().getByID(id);

        if (storeData != null) {
          Store _s = Store.fromJson(storeData);
          List<String> ids = _s.availProducts;

          if (ids.length > 9) {
            int end = 0;
            for (int i = 0; i < ids.length; i = i + 9) {
              if (end + 9 > ids.length)
                end = ids.length;
              else
                end = end + 9;

              QuerySnapshot snap = await getCollectionRef()
                  .where('uuid', whereIn: ids.sublist(i, end))
                  .getDocuments();
              for (var j = 0; j < snap.documents.length; j++) {
                ProductTypes _c = ProductTypes.fromJson(snap.documents[j].data);
                types.add(_c);
              }
            }
          } else {
            QuerySnapshot snap = await getCollectionRef()
                .where('uuid', whereIn: ids)
                .getDocuments();
            for (var j = 0; j < snap.documents.length; j++) {
              ProductTypes _c = ProductTypes.fromJson(snap.documents[j].data);
              types.add(_c);
            }
          }
        }
      }

      return types;
    } catch (err) {
      throw err;
    }
  }
}
