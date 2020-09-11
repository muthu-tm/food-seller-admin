import 'package:chipchop_seller/db/models/address.dart';
import 'package:chipchop_seller/db/models/user_preferences.dart';
import 'package:chipchop_seller/services/controllers/user/user_service.dart';
import 'package:chipchop_seller/services/utils/hash_generator.dart';
import 'package:chipchop_seller/db/models/user.dart';
import 'package:chipchop_seller/services/analytics/analytics.dart';
import 'package:chipchop_seller/services/fcm/user_token.dart';
import 'package:chipchop_seller/services/utils/response_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController {
  dynamic registerWithMobileNumber(int mobileNumber, int countryCode,
      String passkey, String firstName, String lastName, String uid) async {
    try {
      User user = User();
      String hKey = HashGenerator.hmacGenerator(
          passkey, countryCode.toString() + mobileNumber.toString());
      user.password = hKey;
      user.countryCode = countryCode;
      user.mobileNumber = mobileNumber;
      user.firstName = firstName;
      user.lastName = lastName;
      user.guid = uid;
      user.gender = "Male";
      user.address = Address.fromJson(Address().toJson());
      user.preferences = UserPreferences.fromJson(UserPreferences().toJson());
      user = await user.create();

      Analytics.signupEvent(mobileNumber.toString());

      var platformData = await UserFCM().getPlatformDetails();

      if (platformData != null) {
        user.updatePlatformDetails({"platform_data": platformData});
      } else {
        Analytics.reportError({
          "type": 'platform_update_error',
          "user_id": mobileNumber,
          'name': firstName,
          'error': "Unable to update User's platform details"
        }, 'platform_update');
      }

      user.update({'last_signed_in_at': DateTime.now()});
      user.lastSignInTime = DateTime.now();

      // cache the user data
      cachedLocalUser = user;

      return CustomResponse.getSuccesReponse(user.toJson());
    } catch (err) {
      return CustomResponse.getFailureReponse(err.toString());
    }
  }

  dynamic signInWithMobileNumber(User user) async {
    try {
      var platformData = await UserFCM().getPlatformDetails();

      if (platformData != null) {
        user.updatePlatformDetails({"platform_data": platformData});
      } else {
        Analytics.reportError({
          "type": 'platform_update_error',
          "user_id": user.mobileNumber,
          'error': "Unable to update User's platform details"
        }, 'platform_update');
      }

      Analytics.loginEvent(user.mobileNumber.toString());

      // update cloud firestore "users" collection
      user.update({'last_signed_in_at': DateTime.now()});

      // cache the user data
      cachedLocalUser = user;

      return CustomResponse.getSuccesReponse(user);
    } catch (err) {
      Analytics.reportError({
        "type": 'log_in_error',
        "user_id": user.mobileNumber,
        'name': user.firstName,
        'error': err.toString()
      }, 'log_in');
      return CustomResponse.getFailureReponse(err.toString());
    }
  }

  dynamic signOut() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

    try {
      await _auth.signOut();
      final SharedPreferences prefs = await _prefs;
      await prefs.remove("mobile_number");

      return CustomResponse.getSuccesReponse("Successfully signed out");
    } catch (err) {
      return CustomResponse.getFailureReponse(err.toString());
    }
  }
}
