import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chipchop_seller/db/models/model.dart';
import 'package:chipchop_seller/services/utils/constants.dart';
part 'chipchop_products.g.dart';

@JsonSerializable(explicitToJson: true)
class ChipChopProducts extends Model {
  static CollectionReference _storeCollRef =
      Model.db.collection("chipchop_products");

  @JsonKey(name: 'uuid', nullable: false)
  String uuid;
  @JsonKey(name: 'product_type', nullable: false)
  String productType;
  @JsonKey(name: 'product_category', defaultValue: "")
  String productCategory;
  @JsonKey(name: 'product_sub_category', defaultValue: "")
  String productSubCategory;
  @JsonKey(name: 'name', defaultValue: "")
  String name;
  @JsonKey(name: 'short_details', defaultValue: "")
  String shortDetails;
  @JsonKey(name: 'product_images', defaultValue: [""])
  List<String> productImages;
  @JsonKey(name: 'weight')
  double weight;
  @JsonKey(name: 'unit')
  int unit;
  @JsonKey(name: 'org_price')
  double originalPrice;
  @JsonKey(name: 'offer', defaultValue: 0.00)
  double offer;
  @JsonKey(name: 'current_price')
  double currentPrice;
  @JsonKey(name: 'is_returnable', defaultValue: false)
  bool isReturnable;
  @JsonKey(name: 'is_available')
  bool isAvailable;
  @JsonKey(name: 'is_deliverable')
  bool isDeliverable;
  @JsonKey(name: 'is_popular')
  bool isPopular;
  @JsonKey(name: 'keywords', defaultValue: [""])
  List<String> keywords;
  @JsonKey(name: 'created_at', nullable: true)
  DateTime createdAt;
  @JsonKey(name: 'updated_at', nullable: true)
  DateTime updatedAt;

  ChipChopProducts();

  String getUnit() {
    if (this.unit == null) return "";

    if (this.unit == 0) {
      return "Count";
    } else if (this.unit == 1) {
      return "Kg";
    } else if (this.unit == 2) {
      return "gram";
    } else if (this.unit == 3) {
      return "milli gram";
    } else if (this.unit == 4) {
      return "litre";
    } else if (this.unit == 5) {
      return "milli litre";
    } else {
      return "Count";
    }
  }

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

  factory ChipChopProducts.fromJson(Map<String, dynamic> json) =>
      _$ChipChopProductsFromJson(json);
  Map<String, dynamic> toJson() => _$ChipChopProductsToJson(this);

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

  String getProductImage() {
    if (this.productImages.isEmpty) {
      return no_image_placeholder.replaceFirst(
          firebase_storage_path, image_kit_path + ik_medium_size);
    } else {
      if (this.productImages.first != null && this.productImages.first != "")
        return this.productImages.first.replaceFirst(
            firebase_storage_path, image_kit_path + ik_medium_size);
      else
        return no_image_placeholder.replaceFirst(
            firebase_storage_path, image_kit_path + ik_medium_size);
    }
  }

  Future<List<ChipChopProducts>> searchByKeyword(String key) async {
    try {
      List<ChipChopProducts> products = [];

      QuerySnapshot locsnap = await getCollectionRef()
          .where('keywords', arrayContains: key)
          .getDocuments();

      for (var doc in locsnap.documents) {
        ChipChopProducts prod = ChipChopProducts.fromJson(doc.data);
        products.add(prod);
      }

      return products;
    } catch (err) {
      throw err;
    }
  }
}
