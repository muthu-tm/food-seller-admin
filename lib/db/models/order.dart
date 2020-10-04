import 'dart:math';

import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/controllers/user/user_service.dart';
import './order_amount.dart';
import './order_delivery.dart';
import './order_product.dart';
import 'model.dart';
import 'user.dart';
part 'order.g.dart';

@JsonSerializable(explicitToJson: true)
class Order {
  @JsonKey(name: 'uuid', nullable: false)
  String uuid;
  @JsonKey(name: 'order_id', nullable: false)
  String orderID;
  @JsonKey(name: 'store_uuid', nullable: false)
  String storeID;
  @JsonKey(name: 'user_number', nullable: false)
  String userNumber;
  @JsonKey(name: 'total_products', nullable: false)
  int totalProducts;
  @JsonKey(name: 'products', nullable: false)
  List<OrderProduct> products;
  @JsonKey(name: 'order_images', defaultValue: [""])
  List<String> orderImages;
  @JsonKey(name: 'written_orders', defaultValue: "")
  String writtenOrders;
  @JsonKey(name: 'customer_notes', defaultValue: "")
  String customerNotes;
  @JsonKey(name: 'status', defaultValue: 0)
  int status; // 0 - Ordered,
  @JsonKey(name: 'is_returnable', defaultValue: false)
  bool isReturnable;
  @JsonKey(name: 'return_days', defaultValue: false)
  int returnDays;
  @JsonKey(name: 'returned_at', nullable: true)
  int returnedAt;
  @JsonKey(name: 'cancelled_at', nullable: true)
  int cancelledAt;
  @JsonKey(name: 'delivery')
  OrderDelivery delivery;
  @JsonKey(name: 'amount')
  OrderAmount amount;
  @JsonKey(name: 'created_at', nullable: true)
  DateTime createdAt;
  @JsonKey(name: 'updated_at', nullable: true)
  DateTime updatedAt;

  Order();

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  Map<String, dynamic> toJson() => _$OrderToJson(this);

  CollectionReference getCollectionRef(String buyerID) {
    return Model.db.collection('buyers').document(buyerID).collection("orders");
  }

  Query getGroupQuery() {
    return Model.db.collectionGroup('orders');
  }

  DocumentReference getDocumentReference(String buyerID, String id) {
    return getCollectionRef(buyerID).document(id);
  }

  String getID() {
    return this.uuid;
  }

  String generateOrderID() {
    return DateFormat('ddMMyy').format(this.createdAt) +
        "-" +
        Random(100).nextInt(1000).toString() +
        this.totalProducts.toString();
  }

  String getStatus() {
    if (this.status == 0) {
      return "Ordered";
    } else if (this.status == 1) {
      return "Confirmed";
    } else if (this.status == 2) {
      return "Cancelled By User";
    } else if (this.status == 3) {
      return "Cancelled By Store";
    } else if (this.status == 4) {
      return "DisPatched";
    } else {
      return "Delivered";
    }
  }

  String getDeliveryType() {
    if (this.delivery.deliveryType == 0) {
      return "Pickup from Store";
    } else if (this.delivery.deliveryType == 1) {
      return "Instant Delivery";
    } else if (this.delivery.deliveryType == 2) {
      return "Same-Day Delivery";
    } else if (this.delivery.deliveryType == 3) {
      return "Scheduled Delivery";
    } else {
      return "Pickup from Store";
    }
  }

  Future<void> updateDeliveryDetails(
      String buyerID, int status, DateTime eDelivery, String number) async {
    await this.getCollectionRef(buyerID).document(this.uuid).updateData(
      {
        'status': status,
        'updated_at': DateTime.now(),
        'delivery.expected_at': eDelivery.millisecondsSinceEpoch,
        'delivery.delivery_contact': number
      },
    );
  }

  Stream<QuerySnapshot> streamOrders(String id) {
    return getGroupQuery()
        .where('store_uuid', isEqualTo: id)
        .orderBy('created_at', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> streamOrderByID(
      String userID, String storeID, String uuid) {
    return getGroupQuery()
        .where('store_uuid', isEqualTo: storeID)
        .where('user_number', isEqualTo: userID)
        .where('uuid', isEqualTo: uuid)
        .snapshots();
  }

  Stream<QuerySnapshot> streamOrdersByStatus(
      List<String> stores, int status) {
    if (status == null ) {
      return getGroupQuery()
          .where('store_uuid', whereIn: stores)
          .orderBy('created_at', descending: true)
          .snapshots();
    } else {
      return getGroupQuery()
          .where('store_uuid', whereIn: stores)
          .where('status', isEqualTo: status)
          .orderBy('created_at', descending: true)
          .snapshots();
    }
  }
}
