import 'package:chipchop_seller/db/models/customers.dart';
import 'package:chipchop_seller/db/models/model.dart';
import 'package:chipchop_seller/services/controllers/user/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_store_wallet_history.g.dart';

@JsonSerializable(explicitToJson: true)
class UserStoreWalletHistory {
  @JsonKey(name: 'id')
  String id;
  @JsonKey(name: 'type')
  int type; // 0 - Order Debit, 1 - Order Credit, 2 - Store Transaction, 3 - Referral, 4 - offer code
  @JsonKey(name: 'details')
  String details;
  @JsonKey(name: 'store_uuid')
  String storeUUID;
  @JsonKey(name: 'added_by')
  String addedBy;
  @JsonKey(name: 'user_number')
  String userNumber;
  @JsonKey(name: 'amount', defaultValue: 0)
  double amount;
  @JsonKey(name: 'created_at', nullable: true)
  int createdAt;

  UserStoreWalletHistory();

  factory UserStoreWalletHistory.fromJson(Map<String, dynamic> json) =>
      _$UserStoreWalletHistoryFromJson(json);
  Map<String, dynamic> toJson() => _$UserStoreWalletHistoryToJson(this);

  Query getGroupQuery() {
    return Model.db.collectionGroup('user_store_wallet');
  }

  CollectionReference getCollectionRef(String storeID, String custID) {
    return Model.db
        .collection("stores")
        .doc(storeID)
        .collection("customers")
        .doc(custID)
        .collection('user_store_wallet');
  }

  DocumentReference getDocumentRef(String storeID) {
    return Model.db
        .collection("stores")
        .doc(storeID)
        .collection("customers")
        .doc(cachedLocalUser.getID());
  }

  String getID() {
    return this.createdAt.toString();
  }

  Future<void> addTransaction(String storeID, String custID) async {
    try {
      DocumentReference custDocRef = Model.db
          .collection("stores")
          .doc(storeID)
          .collection("customers")
          .doc(custID);

      await Model.db.runTransaction((tx) {
        return tx.get(custDocRef).then((doc) async {
          Customers cust = Customers.fromJson(doc.data());

          cust.availableBalance += this.amount;
          if (!this.amount.isNegative) cust.totalAmount += this.amount;

          Model().txCreate(
              tx,
              this.getCollectionRef(storeID, custID).doc(getID()),
              this.toJson());

          Model().txUpdate(tx, custDocRef, cust.toJson());
        });
      });
    } catch (err) {
      throw err;
    }
  }

  Stream<QuerySnapshot> streamUsersStoreWallet(String storeID, String custID) {
    return getCollectionRef(storeID, custID)
        .orderBy('created_at', descending: true)
        .snapshots();
  }

  Future<Customers> getStoreCustomer(String storeID) async {
    DocumentSnapshot snap = await getDocumentRef(storeID).get();
    if (snap.exists)
      return Customers.fromJson(snap.data());
    else
      return null;
  }
}
