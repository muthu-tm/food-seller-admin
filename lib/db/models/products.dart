import 'package:chipchop_seller/services/analytics/analytics.dart';
import 'package:chipchop_seller/services/controllers/user/user_service.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chipchop_seller/db/models/model.dart';
import 'package:chipchop_seller/services/utils/constants.dart';
part 'products.g.dart';

@JsonSerializable(explicitToJson: true)
class Products extends Model {
  static CollectionReference _productsCollRef = Model.db.collection("products");

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
  @JsonKey(name: 'store_uuid', defaultValue: "")
  String storeID;
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

  Products();

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

  List<String> getProductImages() {
    if (this.productImages.isEmpty) {
      return [
        no_image_placeholder.replaceFirst(
            firebase_storage_path, image_kit_path + ik_medium_size)
      ];
    } else {
      if (this.productImages.first != null && this.productImages.first != "") {
        List<String> images = [];
        for (var img in this.productImages) {
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
    return _productsCollRef;
  }

  DocumentReference getDocumentReference(String uuid) {
    return _productsCollRef.document(uuid);
  }

  String getID() {
    return this.uuid;
  }

  Stream<DocumentSnapshot> streamStoreData() {
    return getDocumentReference(getID()).snapshots();
  }

  Future<void> create() async {
    try {
      DocumentReference docRef = getCollectionRef().document();
      this.createdAt = DateTime.now();
      this.updatedAt = DateTime.now();
      this.uuid = docRef.documentID;

      await docRef.setData(this.toJson());
      Analytics.sendAnalyticsEvent({
        'type': 'product_create',
        'store_id': this.storeID,
        'product_id': this.uuid
      }, 'product');
    } catch (err) {
      Analytics.sendAnalyticsEvent({
        'type': 'product_create_error',
        'store_id': this.storeID,
        'product_id': this.uuid,
        'error': err.toString()
      }, 'product');
      throw err;
    }
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

  Stream<QuerySnapshot> streamProducts(String storeID) {
    try {
      return getCollectionRef()
          .where('store_uuid', isEqualTo: storeID)
          .snapshots();
    } catch (err) {
      throw err;
    }
  }

  Stream<QuerySnapshot> streamProductsForCategory(
      String storeID, String categoryID) {
    try {
      return getCollectionRef()
          .where('store_uuid', isEqualTo: storeID)
          .where('product_category', isEqualTo: categoryID)
          .snapshots();
    } catch (err) {
      throw err;
    }
  }

  Stream<QuerySnapshot> streamProductsForSubCategory(
      String storeID, String categoryID, String subCategoryID) {
    try {
      return getCollectionRef()
          .where('store_uuid', isEqualTo: storeID)
          .where('product_category', isEqualTo: categoryID)
          .where('product_sub_category', isEqualTo: subCategoryID)
          .snapshots();
    } catch (err) {
      throw err;
    }
  }

  Future<Products> getByProductID(String uuid) async {
    try {
      DocumentSnapshot snap = await getCollectionRef().document(uuid).get();

      if (snap.exists) return Products.fromJson(snap.data);

      return null;
    } catch (err) {
      Analytics.sendAnalyticsEvent({
        'type': 'product_get_error',
        'product_id': uuid,
        'error': err.toString()
      }, 'product');
      throw err;
    }
  }

  Stream<QuerySnapshot> streamAvailableProducts(String storeID) {
    try {
      return getCollectionRef()
          .where('store_uuid', isEqualTo: storeID)
          .where('is_available', isEqualTo: true)
          .snapshots();
    } catch (err) {
      throw err;
    }
  }

  Stream<QuerySnapshot> streamUnAvailableProducts(String storeID) {
    try {
      return getCollectionRef()
          .where('store_uuid', isEqualTo: storeID)
          .where('is_available', isEqualTo: false)
          .snapshots();
    } catch (err) {
      throw err;
    }
  }

  Stream<QuerySnapshot> streamPopularProducts(String storeID) {
    try {
      return getCollectionRef()
          .where('store_uuid', isEqualTo: storeID)
          .where('is_popular', isEqualTo: true)
          .snapshots();
    } catch (err) {
      throw err;
    }
  }

  Future<List<Map<String, dynamic>>> getByNameRange(String searchKey) async {
    try {
      List<Map<String, dynamic>> pList = [];

      for (var i = 0; i < cachedLocalUser.stores.length; i++) {
        QuerySnapshot snap = await getCollectionRef()
            .where('store_uuid', isEqualTo: cachedLocalUser.stores[i])
            .where('keywords', arrayContainsAny: searchKey.split(" "))
            .getDocuments();

        if (snap.documents.isNotEmpty) {
          snap.documents.forEach((p) {
            pList.add(p.data);
          });
        }
      }

      return pList;
    } catch (err) {
      Analytics.sendAnalyticsEvent({
        'type': 'product_search_error',
        'search_key': searchKey,
        'error': err.toString()
      }, 'product');
      throw err;
    }
  }

  Future updateProductStatus(String docID, bool isAvail) async {
    try {
      await getDocumentReference(docID).updateData(
        {'is_available': isAvail, 'updated_at': DateTime.now()},
      );
    } catch (err) {
      Analytics.sendAnalyticsEvent({
        'type': 'product_status_update_error',
        'product_id': docID,
        'error': err.toString()
      }, 'product');
      throw err;
    }
  }
}
