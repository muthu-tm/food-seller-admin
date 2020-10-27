import 'package:chipchop_seller/db/models/model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'customers.g.dart';

@JsonSerializable(explicitToJson: true)
class Customers {
  @JsonKey(name: 'contact_number', nullable: false)
  String contactNumber;
  @JsonKey(name: 'first_name', nullable: false)
  String firstName;
  @JsonKey(name: 'last_name', nullable: false)
  String lastName;
  @JsonKey(name: 'store_name', nullable: false)
  String storeName;
  @JsonKey(name: 'store_uuid', nullable: false)
  String storeID;
  @JsonKey(name: 'total_amount', defaultValue: 0)
  double totalAmount;
  @JsonKey(name: 'available_balance', defaultValue: 0)
  double availableBalance;
  @JsonKey(name: 'has_customer_unread')
  bool hasCustUnread;
  @JsonKey(name: 'has_store_unread')
  bool hasStoreUnread;
  @JsonKey(name: 'created_at', nullable: true)
  DateTime createdAt;
  @JsonKey(name: 'updated_at', nullable: true)
  DateTime updatedAt;

  Customers();

  factory Customers.fromJson(Map<String, dynamic> json) =>
      _$CustomersFromJson(json);
  Map<String, dynamic> toJson() => _$CustomersToJson(this);

  CollectionReference getCollectionRef(String storeID) {
    return Model.db
        .collection("stores")
        .document(storeID)
        .collection("customers");
  }

  Stream<QuerySnapshot> streamStoreCustomers(String storeID) {
    return getCollectionRef(storeID).snapshots();
  }

  Stream<DocumentSnapshot> streamUsersData(String storeID, String custID) {
    return getCollectionRef(storeID)
        .document(custID)
        .snapshots();
  }
}
