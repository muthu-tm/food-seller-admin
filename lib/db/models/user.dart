import 'package:chipchop_seller/db/models/model.dart';
import 'package:chipchop_seller/db/models/address.dart';
import 'package:chipchop_seller/db/models/user_preferences.dart';
import 'package:chipchop_seller/db/models/user_locations.dart';
import 'package:chipchop_seller/services/analytics/analytics.dart';
import 'package:chipchop_seller/services/utils/constants.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
part 'user.g.dart';

@JsonSerializable(explicitToJson: true)
class User extends Model {
  static CollectionReference _userCollRef = Model.db.collection("sellers");

  @JsonKey(name: 'guid', nullable: false)
  String guid;
  @JsonKey(name: 'first_name', defaultValue: "")
  String firstName;
  @JsonKey(name: 'last_name', defaultValue: "")
  String lastName;
  @JsonKey(name: 'stores', defaultValue: "")
  List<String> stores;
  @JsonKey(name: 'mobile_number', nullable: false)
  int mobileNumber;
  @JsonKey(name: 'country_code', nullable: false)
  int countryCode;
  @JsonKey(name: 'emailID', defaultValue: "")
  String emailID;
  @JsonKey(name: 'password', nullable: false)
  String password;
  @JsonKey(name: 'gender', defaultValue: "")
  String gender;
  @JsonKey(name: 'profile_path', defaultValue: "")
  String profilePath;
  @JsonKey(name: 'date_of_birth', defaultValue: "")
  int dateOfBirth;
  @JsonKey(name: 'address', nullable: true)
  Address address;
  @JsonKey(name: 'last_signed_in_at', nullable: true)
  DateTime lastSignInTime;
  @JsonKey(name: 'is_active', defaultValue: true)
  bool isActive;
  @JsonKey(name: 'deactivated_at', nullable: true)
  int deactivatedAt;
  @JsonKey(name: 'preferences')
  UserPreferences preferences;
  @JsonKey(name: 'primary_location')
  UserLocations primaryLocation;
  @JsonKey(name: 'created_at', nullable: true)
  DateTime createdAt;
  @JsonKey(name: 'updated_at', nullable: true)
  DateTime updatedAt;

  User();

  String getProfilePicPath() {
    if (this.profilePath != null && this.profilePath != "")
      return this.profilePath;
    return "";
  }

  String getSmallProfilePicPath() {
    if (this.profilePath != null && this.profilePath != "")
      return this
          .profilePath
          .replaceFirst(firebase_storage_path, image_kit_path + ik_small_size);
    else
      return "";
  }

  String getMediumProfilePicPath() {
    if (this.profilePath != null && this.profilePath != "")
      return this
          .profilePath
          .replaceFirst(firebase_storage_path, image_kit_path + ik_medium_size);
    else
      return "";
  }

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  CollectionReference getCollectionRef() {
    return _userCollRef;
  }

  DocumentReference getDocumentReference(String id) {
    return _userCollRef.document(id);
  }

  String getID() {
    return this.countryCode.toString() + this.mobileNumber.toString();
  }

  int getIntID() {
    return int.parse(
        this.countryCode.toString() + this.mobileNumber.toString());
  }

  String getFullName() {
    return this.firstName + " " + this.lastName ?? "";
  }

  Stream<DocumentSnapshot> streamUserData() {
    return getDocumentReference(getID()).snapshots();
  }

  Future<User> create() async {
    this.createdAt = DateTime.now();
    this.updatedAt = DateTime.now();
    this.isActive = true;

    try {
      await super.add(this.toJson());
      Analytics.sendAnalyticsEvent(
          {'type': 'seller_create', 'user_id': this.getID()}, 'seller');
      return this;
    } catch (err) {
      Analytics.reportError({
        'type': 'seller_create_error',
        'store_id': this.getID(),
        'message': err.toString()
      }, 'seller');
      throw err;
    }
  }

  Future updatePlatformDetails(Map<String, dynamic> data) async {
    this.update(data);
  }
}
