import 'package:chipchop_seller/db/models/product_description.dart';
import 'package:chipchop_seller/db/models/product_variants.dart';
import 'package:chipchop_seller/services/analytics/analytics.dart';
import 'package:chipchop_seller/services/controllers/user/user_service.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chipchop_seller/db/models/model.dart';
import 'package:chipchop_seller/services/utils/constants.dart';
import 'package:chipchop_seller/db/models/product_categories_map.dart';
part 'products.g.dart';

@JsonSerializable(explicitToJson: true)
class Products extends Model {
  static CollectionReference _productsCollRef = Model.db.collection("products");

  @JsonKey(name: 'uuid', nullable: false)
  String uuid;
  @JsonKey(name: 'product_type', nullable: false)
  ProductCategoriesMap productType;
  @JsonKey(name: 'product_category', defaultValue: "")
  ProductCategoriesMap productCategory;
  @JsonKey(name: 'product_sub_category', defaultValue: "")
  ProductCategoriesMap productSubCategory;
  @JsonKey(name: 'brand_name', defaultValue: "")
  String brandName;
  @JsonKey(name: 'name', defaultValue: "")
  String name;
  @JsonKey(name: 'rating', defaultValue: 1)
  double rating;
  @JsonKey(name: 'total_ratings', defaultValue: 1)
  double totalRatings;
  @JsonKey(name: 'total_reviews', defaultValue: 1)
  int totalReviews;
  @JsonKey(name: 'short_details', defaultValue: "")
  String shortDetails;
  @JsonKey(name: 'store_uuid', defaultValue: "")
  String storeID;
  @JsonKey(name: 'store_name', defaultValue: "")
  String storeName;
  @JsonKey(name: 'orders')
  int orders;
  @JsonKey(name: 'image', defaultValue: "")
  String image;
  @JsonKey(name: 'product_images', defaultValue: [""])
  List<String> productImages;
  @JsonKey(name: 'product_description', defaultValue: [""])
  List<ProductDescription> productDescription;
  @JsonKey(name: 'variants', defaultValue: [""])
  List<ProductVariants> variants;
  @JsonKey(name: 'is_returnable', defaultValue: false)
  bool isReturnable;
  @JsonKey(name: 'return_within', defaultValue: false)
  int returnWithin;
  @JsonKey(name: 'is_replaceable', defaultValue: false)
  bool isReplaceable;
  @JsonKey(name: 'replace_within', defaultValue: false)
  int replaceWithin;
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

  List<String> getProductImages() {
    if (this.productImages.isEmpty) {
      return [
        noImagePlaceholder.replaceFirst(
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
          noImagePlaceholder.replaceFirst(
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
      throw err;
    }
  }

  String getSmallProductImage() {
    if (image != null && image.trim() != "")
      return image.replaceFirst(
          firebase_storage_path, image_kit_path + ik_small_size);
    else
      return noImagePlaceholder.replaceFirst(
          firebase_storage_path, image_kit_path + ik_small_size);
  }

  String getProductImage() {
    if (image != null && image.trim() != "")
      return image.replaceFirst(
          firebase_storage_path, image_kit_path + ik_medium_size);
    else
      return noImagePlaceholder.replaceFirst(
          firebase_storage_path, image_kit_path + ik_medium_size);
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
          .where('product_category.uuid', isEqualTo: categoryID)
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
          .where('product_category.uuid', isEqualTo: categoryID)
          .where('product_sub_category.uuid', isEqualTo: subCategoryID)
          .snapshots();
    } catch (err) {
      throw err;
    }
  }

  Future<List<Products>> getProductsForCategories(
      String storeID, String categoryID) async {
    try {
      List<Products> products = [];

      QuerySnapshot snap = await getCollectionRef()
          .where('store_uuid', isEqualTo: storeID)
          .where('product_category.uuid', isEqualTo: categoryID)
          .getDocuments();
      for (var j = 0; j < snap.documents.length; j++) {
        Products _c = Products.fromJson(snap.documents[j].data);
        products.add(_c);
      }

      return products;
    } catch (err) {
      throw err;
    }
  }

  Future<List<Products>> getProductsForSubCategories(
      String storeID, String categoryID, String subCategoryID) async {
    try {
      List<Products> products = [];
      QuerySnapshot snap = await getCollectionRef()
          .where('store_uuid', isEqualTo: storeID)
          .where('product_category.uuid', isEqualTo: categoryID)
          .where('product_sub_category.uuid', isEqualTo: subCategoryID)
          .getDocuments();
      for (var j = 0; j < snap.documents.length; j++) {
        Products _c = Products.fromJson(snap.documents[j].data);
        products.add(_c);
      }

      return products;
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

  Future updateProductStatus(
      String docID, String variantID, bool isAvail) async {
    try {
      List<ProductVariants> _newVariants = this.variants;

      this.variants.asMap().forEach((index, value) {
        if (value.id == variantID) {
          _newVariants[index].isAvailable = isAvail;
        }
      });

      await getDocumentReference(docID).updateData(
        {
          'variants': _newVariants?.map((e) => e?.toJson())?.toList(),
          'updated_at': DateTime.now()
        },
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

  Future<bool> removeByID(String uuid) async {
    try {
      DocumentSnapshot snap = await getCollectionRef().document(uuid).get();

      if (snap.exists) {
        await snap.reference.delete();
        return true;
      }

      return false;
    } catch (err) {
      Analytics.sendAnalyticsEvent({
        'type': 'product_remove_error',
        'product_id': uuid,
        'error': err.toString()
      }, 'product');
      return false;
    }
  }
}
