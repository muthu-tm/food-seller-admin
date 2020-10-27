import 'dart:math';

import 'package:chipchop_seller/services/analytics/analytics.dart';
import 'package:chipchop_seller/services/controllers/user/user_service.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import './order_amount.dart';
import './order_delivery.dart';
import './order_product.dart';
import 'model.dart';
part 'order.g.dart';

@JsonSerializable(explicitToJson: true)
class Order {
  @JsonKey(name: 'uuid', nullable: false)
  String uuid;
  @JsonKey(name: 'order_id', nullable: false)
  String orderID;
  @JsonKey(name: 'store_name', nullable: false)
  String storeName;
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
  @JsonKey(name: 'confirmed_at', nullable: true)
  int confirmedAt;
  @JsonKey(name: 'dispatched_at', nullable: true)
  int dispatchedAt;
  @JsonKey(name: 'cancelled_at', nullable: true)
  int cancelledAt;
  @JsonKey(name: 'return_requested_at', nullable: true)
  int returnRequestedAt;
  @JsonKey(name: 'return_cancelled_at', nullable: true)
  int returnCancelledAt;
  @JsonKey(name: 'returned_at', nullable: true)
  int returnedAt;
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
    } else if (this.status == 5) {
      return "Delivered";
    } else if (this.status == 6) {
      return "Return Requested";
    } else if (this.status == 7) {
      return "Return Cancelled";
    } else {
      return "Returned";
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
    String field = "confirmed_at";

    if (status == 1) {
      field = "confirmed_at";
    } else if (status == 2 || status == 3) {
      field = "cancelled_at";
    } else if (status == 4) {
      field = "dispatched_at";
    } else if (status == 5) {
      field = "delivery.delivered_at";
    } else {
      field = "returned_at";
    }

    try {
      await this.getCollectionRef(buyerID).document(this.uuid).updateData(
        {
          'status': status,
          'updated_at': DateTime.now(),
          'delivery.expected_at':
              eDelivery == null ? null : eDelivery.millisecondsSinceEpoch,
          'delivery.delivery_contact': number,
          field: DateTime.now().millisecondsSinceEpoch
        },
      );
    } catch (err) {
      Analytics.sendAnalyticsEvent({
        'type': 'order_delivery_update_error',
        'order_id': this.uuid,
        'error': err.toString()
      }, 'order');
      throw err;
    }
  }

  Future<void> updateAmountDetails(
      String buyerID, double oAmount, double dAmount, double rAmount) async {
    try {
      await this.getCollectionRef(buyerID).document(this.uuid).updateData(
        {
          'updated_at': DateTime.now(),
          'amount.order_amount': oAmount,
          'amount.delivery_charge': dAmount,
          'delivery.delivery_charge': dAmount,
          'amount.paid_amount': rAmount
        },
      );
    } catch (err) {
      Analytics.sendAnalyticsEvent({
        'type': 'order_amount_update_error',
        'order_id': this.uuid,
        'error': err.toString()
      }, 'order');
      throw err;
    }
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

  Stream<QuerySnapshot> streamOrdersByStatus(List<String> stores, int status) {
    if (status == null) {
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

  Future<List<Map<String, dynamic>>> getByOrderID(String id) async {
    QuerySnapshot snap = await getGroupQuery()
        .where('store_uuid', whereIn: cachedLocalUser.stores)
        .where('order_id', isGreaterThanOrEqualTo: id)
        .getDocuments();

    List<Map<String, dynamic>> oList = [];
    if (snap.documents.isNotEmpty) {
      snap.documents.forEach((order) {
        oList.add(order.data);
      });
    }

    return oList;
  }
}
