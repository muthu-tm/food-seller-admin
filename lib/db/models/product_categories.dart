import 'package:chipchop_seller/db/models/store.dart';
import 'package:chipchop_seller/services/utils/constants.dart';
import './model.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'product_categories.g.dart';

@JsonSerializable(explicitToJson: true)
class ProductCategories extends Model {
  static CollectionReference _categoriesCollRef =
      Model.db.collection("product_categories");

  @JsonKey(name: 'uuid', nullable: false)
  String uuid;
  @JsonKey(name: 'type_id', nullable: false)
  String typeID;
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

  ProductCategories();

  String getCategoryImage() {
    if (this.productImages.isEmpty) {
      return no_image_placeholder.replaceFirst(
          firebase_storage_path, image_kit_path + ik_medium_size);
    } else {
      if (this.productImages.first != null && this.productImages.first != "") {
        return this.productImages.first.replaceFirst(
            firebase_storage_path, image_kit_path + ik_medium_size);
      } else
        return no_image_placeholder.replaceFirst(
            firebase_storage_path, image_kit_path + ik_medium_size);
    }
  }

  factory ProductCategories.fromJson(Map<String, dynamic> json) =>
      _$ProductCategoriesFromJson(json);
  Map<String, dynamic> toJson() => _$ProductCategoriesToJson(this);

  CollectionReference getCollectionRef() {
    return _categoriesCollRef;
  }

  DocumentReference getDocumentReference(String uuid) {
    return getCollectionRef().document(uuid);
  }

  String getID() {
    return this.uuid;
  }

  Future<List<ProductCategories>> getCategoriesForTypes(
      List<String> ids) async {
    // handle empty params
    if (ids.isEmpty) return [];

    List<ProductCategories> categories = [];

    if (ids.length > 9) {
      int end = 0;
      for (int i = 0; i < ids.length; i = i + 9) {
        if (end + 9 > ids.length)
          end = ids.length;
        else
          end = end + 9;

        QuerySnapshot snap = await getCollectionRef()
            .where('type_id', whereIn: ids.sublist(i, end))
            .getDocuments();
        for (var j = 0; j < snap.documents.length; j++) {
          ProductCategories _c =
              ProductCategories.fromJson(snap.documents[j].data);
          categories.add(_c);
        }
      }
    } else {
      QuerySnapshot snap = await getCollectionRef()
          .where('type_id', whereIn: ids)
          .getDocuments();
      for (var j = 0; j < snap.documents.length; j++) {
        ProductCategories _c =
            ProductCategories.fromJson(snap.documents[j].data);
        categories.add(_c);
      }
    }

    return categories;
  }

  Future<List<ProductCategories>> getCategoriesForIDs(List<String> ids) async {
    List<ProductCategories> categories = [];
    try {
      // handle empty params
      if (ids.isEmpty) return [];

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
            ProductCategories _c =
                ProductCategories.fromJson(snap.documents[j].data);
            categories.add(_c);
          }
        }
      } else {
        QuerySnapshot snap =
            await getCollectionRef().where('uuid', whereIn: ids).getDocuments();
        for (var j = 0; j < snap.documents.length; j++) {
          ProductCategories _c =
              ProductCategories.fromJson(snap.documents[j].data);
          categories.add(_c);
        }
      }
    } catch (err) {
      throw err;
    }
    return categories;
  }

  Future<List<ProductCategories>> getCategoriesForStoreID(
      String id, String typeID) async {
    List<ProductCategories> categories = [];
    try {
      if (id.trim().isNotEmpty && id.trim() != '0') {
        Map<String, dynamic> storeData = await Store().getByID(id);

        if (storeData != null) {
          Store _s = Store.fromJson(storeData);
          List<String> ids = _s.availProductCategories;
          // handle empty params
          if (ids.isEmpty) return [];

          if (ids.length > 9) {
            int end = 0;
            for (int i = 0; i < ids.length; i = i + 9) {
              if (end + 9 > ids.length)
                end = ids.length;
              else
                end = end + 9;

              QuerySnapshot snap = await getCollectionRef()
                  .where('uuid', whereIn: ids.sublist(i, end))
                  .where('type_id', isEqualTo: typeID)
                  .getDocuments();
              for (var j = 0; j < snap.documents.length; j++) {
                ProductCategories _c =
                    ProductCategories.fromJson(snap.documents[j].data);
                categories.add(_c);
              }
            }
          } else {
            QuerySnapshot snap = await getCollectionRef()
                .where('uuid', whereIn: ids)
                .where('type_id', isEqualTo: typeID)
                .getDocuments();
            for (var j = 0; j < snap.documents.length; j++) {
              ProductCategories _c =
                  ProductCategories.fromJson(snap.documents[j].data);
              categories.add(_c);
            }
          }
        }
      }
    } catch (err) {
      throw err;
    }
    return categories;
  }
}
