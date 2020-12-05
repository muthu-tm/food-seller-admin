import 'dart:math';

import 'package:chipchop_seller/db/models/order_status.dart';
import 'package:chipchop_seller/db/models/order_written_details.dart';
import 'package:chipchop_seller/services/analytics/analytics.dart';
import 'package:chipchop_seller/services/controllers/user/user_service.dart';
import 'package:flutter/material.dart';
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
  @JsonKey(name: 'written_orders', nullable: false)
  List<WrittenOrders> writtenOrders;
  @JsonKey(name: 'customer_notes', defaultValue: "")
  String customerNotes;
  @JsonKey(name: 'store_notes', defaultValue: "")
  String storeNotes;
  @JsonKey(name: 'status')
  int status;
  @JsonKey(name: 'status_details')
  List<OrderStatus> statusDetails;
  @JsonKey(name: 'is_returnable', defaultValue: false)
  bool isReturnable;
  @JsonKey(name: 'return_days', defaultValue: false)
  int returnDays;
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
    var _random = new Random();

    return DateFormat('yyMMdd').format(this.createdAt) +
        "-" +
        this.totalProducts.toString() +
        (10 + _random.nextInt(10000 - 10)).toString();
  }

  String getStatus(int status) {
    switch (status) {
      case 0:
        return "Ordered";
        break;
      case 1:
        return "Confirmed";
        break;
      case 2:
        return "Cancelled By User";
        break;
      case 3:
        return "Cancelled By Store";
        break;
      case 4:
        return "DisPatched";
        break;
      case 5:
        return "Delivered";
        break;
      case 6:
        return "Return Requested";
        break;
      case 7:
        return "Return Cancelled";
        break;
      default:
        return "Returned";
    }
  }

  Color getTextColor() {
    switch (status) {
      case 0:
        return Colors.orange;
        break;
      case 1:
      case 4:
        return Colors.blue;
        break;
      case 2:
      case 3:
      case 7:
        return Colors.red;
        break;
      case 5:
        return Colors.green;
        break;
      default:
        return Colors.black;
    }
  }

  Color getBackGround() {
    switch (status) {
      case 0:
        return Colors.orange[100];
        break;
      case 1:
      case 4:
        return Colors.blue[100];
        break;
      case 2:
      case 3:
      case 7:
        return Colors.red[100];
        break;
      case 5:
        return Colors.green[100];
        break;
      default:
        return Colors.black45;
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

  Future<void> deliverOrder(String buyerID, DateTime dateTime, String notes,
      String deliverredTo, String deliverredBy, String number) async {
    try {
      List<OrderStatus> _newStatus = this.statusDetails;
      _newStatus.add(
        OrderStatus.fromJson({
          'created_at': DateTime.now().millisecondsSinceEpoch,
          'updated_by': cachedLocalUser.getFullName(),
          'user_number': cachedLocalUser.getID(),
          'status': 5
        }),
      );

      await this.getCollectionRef(buyerID).document(this.uuid).updateData(
        {
          'status_details': _newStatus?.map((e) => e?.toJson())?.toList(),
          'status': 5,
          'updated_at': DateTime.now(),
          'delivery.delivered_at':
              dateTime == null ? null : dateTime.millisecondsSinceEpoch,
          'delivery.delivered_by': deliverredBy,
          'delivery.delivered_to': deliverredTo,
          'delivery.notes': notes,
          'delivery.delivery_contact': number,
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

  Future<void> updateDeliveryDetails(
      String buyerID, int status, DateTime eDelivery, String number) async {
    try {
      if (status != this.status) {
        List<OrderStatus> _newStatus = this.statusDetails;
        _newStatus.add(
          OrderStatus.fromJson({
            'created_at': DateTime.now().millisecondsSinceEpoch,
            'updated_by': cachedLocalUser.getFullName(),
            'user_number': cachedLocalUser.getID(),
            'status': status
          }),
        );

        await this.getCollectionRef(buyerID).document(this.uuid).updateData(
          {
            'status_details': _newStatus?.map((e) => e?.toJson())?.toList(),
            'status': status,
            'updated_at': DateTime.now(),
            'delivery.expected_at':
                eDelivery == null ? null : eDelivery.millisecondsSinceEpoch,
            'delivery.delivery_contact': number,
          },
        );
      } else if (this.delivery.expectedAt !=
              (eDelivery == null ? null : eDelivery.millisecondsSinceEpoch) ||
          this.delivery.deliveryContact != number) {
        await this.getCollectionRef(buyerID).document(this.uuid).updateData(
          {
            'updated_at': DateTime.now(),
            'delivery.expected_at':
                eDelivery == null ? null : eDelivery.millisecondsSinceEpoch,
            'delivery.delivery_contact': number,
          },
        );
      }
    } catch (err) {
      Analytics.sendAnalyticsEvent({
        'type': 'order_delivery_update_error',
        'order_id': this.uuid,
        'error': err.toString()
      }, 'order');
      throw err;
    }
  }

  Future<void> cancelOrder(bool isReturn, String notes) async {
    List<OrderStatus> _newStatus = this.statusDetails;
    _newStatus.add(
      OrderStatus.fromJson({
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_by': cachedLocalUser.getFullName(),
        'user_number': cachedLocalUser.getID(),
        'status': isReturn ? 7 : 3
      }),
    );

    await this
        .getCollectionRef(this.userNumber)
        .document(this.getID())
        .updateData(
      {
        'status_details': _newStatus?.map((e) => e?.toJson())?.toList(),
        'status': isReturn ? 7 : 3,
        'updated_at': DateTime.now(),
        'store_notes': notes
      },
    );
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

  Future<List<Order>> getCurrentDayOrders(String id) async {
    final now = DateTime.now();
    final lastMidnight = new DateTime(now.year, now.month, now.day);

    QuerySnapshot snap = await getGroupQuery()
        .where('store_uuid', isEqualTo: id)
        .where('created_at', isGreaterThan: lastMidnight)
        .getDocuments();

    List<Order> oList = [];
    if (snap.documents.isNotEmpty) {
      snap.documents.forEach((order) {
        Order _order = Order.fromJson(order.data);
        oList.add(_order);
      });
    }

    return oList;
  }

  Stream<DocumentSnapshot> streamOrderByID(String userID, String uuid) {
    return getCollectionRef(userID).document(uuid).snapshots();
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

  Stream<QuerySnapshot> streamOrdersForStore(String storeID, List<int> status) {
    return getGroupQuery()
        .where('store_uuid', isEqualTo: storeID)
        .where('status', whereIn: status)
        .orderBy('created_at', descending: true)
        .snapshots();
  }

  Future<List<Order>> searchForOrder(String id) async {
    QuerySnapshot snap = await getGroupQuery()
        .where('store_uuid', whereIn: cachedLocalUser.stores)
        .where('order_id', isEqualTo: id)
        .getDocuments();

    List<Order> oList = [];
    if (snap.documents.isNotEmpty) {
      snap.documents.forEach((order) {
        oList.add(Order.fromJson(order.data));
      });
    }

    return oList;
  }
}
