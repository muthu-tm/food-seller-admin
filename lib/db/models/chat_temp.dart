import 'package:chipchop_seller/db/models/user.dart';
import 'package:chipchop_seller/services/analytics/analytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../services/controllers/user/user_service.dart';
import 'model.dart';

part 'chat_temp.g.dart';

@JsonSerializable(explicitToJson: true)
class ChatTemplate {
  @JsonKey(name: 'from', nullable: false)
  String from;
  @JsonKey(name: 'content', nullable: false)
  String content;
  @JsonKey(name: 'msg_type', nullable: false)
  int messageType;
  @JsonKey(name: 'sender_type', nullable: false)
  int senderType;
  @JsonKey(name: 'created_at', nullable: true)
  DateTime createdAt;
  @JsonKey(name: 'updated_at', nullable: true)
  DateTime updatedAt;

  ChatTemplate();

  factory ChatTemplate.fromJson(Map<String, dynamic> json) =>
      _$ChatTemplateFromJson(json);
  Map<String, dynamic> toJson() => _$ChatTemplateToJson(this);

  CollectionReference getOrderCollectionRef(String custID, String orderID) {
    return Model.db
        .collection("buyers")
        .document(custID)
        .collection("orders")
        .document(orderID)
        .collection("order_chats");
  }

  CollectionReference getStoreCollectionRef(String storeID, String custID) {
    return Model.db
        .collection("stores")
        .document(storeID)
        .collection("customers")
        .document(custID)
        .collection("chats");
  }

  Future<void> orderChatCreate(String custID, String orderUUID) async {
    this.createdAt = DateTime.now();
    this.updatedAt = DateTime.now();
    this.from = cachedLocalUser.getID();

    await getOrderCollectionRef(custID, orderUUID)
        .document(this.createdAt.millisecondsSinceEpoch.toString())
        .setData(this.toJson());
  }

  Future<void> updateToRead(String storeID, String custID) async {
    await Model.db
        .collection("stores")
        .document(storeID)
        .collection("customers")
        .document(custID)
        .updateData({'has_store_unread': false, 'updated_at': DateTime.now()});
  }

  Future<void> updateToUnRead(String storeID, String custID) async {
    await Model.db
        .collection("stores")
        .document(storeID)
        .collection("customers")
        .document(custID)
        .updateData({'has_store_unread': true, 'updated_at': DateTime.now()});
  }

  Stream<QuerySnapshot> streamOrderChats(
      String custID, String orderID, int limit) {
    return getOrderCollectionRef(custID, orderID)
        .orderBy('created_at', descending: true)
        .limit(limit)
        .snapshots();
  }

  Future<void> storeChatCreate(String storeID, String custID) async {
    this.createdAt = DateTime.now();
    this.updatedAt = DateTime.now();
    this.from = cachedLocalUser.getID();

    await getStoreCollectionRef(storeID, custID)
        .document(this.createdAt.millisecondsSinceEpoch.toString())
        .setData(this.toJson());
  }

  Stream<QuerySnapshot> streamStoreChats(
      String storeID, String custID, int limit) {
    return getStoreCollectionRef(storeID, custID)
        .orderBy('created_at', descending: true)
        .limit(limit)
        .snapshots();
  }

  Future<List<User>> getStoreChatsList(String storeID) async {
    try {
      QuerySnapshot snap = await Model.db
          .collection('stores')
          .document(storeID)
          .collection('customers')
          .orderBy('created_at', descending: true)
          .getDocuments();

      if (snap.documents.isEmpty) return [];

      List<User> _buyers = [];

      for (var i = 0; i < snap.documents.length; i++) {
        DocumentSnapshot custSnap = await Model.db
            .collection('buyers')
            .document(snap.documents[i].data['contact_numer'])
            .get();

        if (custSnap.exists) {
          User _u = User.fromJson(custSnap.data);
          _buyers.add(_u);
        }
      }

      return _buyers;
    } catch (err) {
      Analytics.sendAnalyticsEvent({
        'type': 'store_chat_get_error',
        'store_id': storeID,
        'error': err.toString()
      }, 'chats');
      throw err;
    }
  }
}
