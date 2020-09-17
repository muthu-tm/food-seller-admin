import 'dart:io';
import 'package:chipchop_seller/db/models/store.dart';
import 'package:chipchop_seller/services/controllers/user/user_service.dart';
import 'package:chipchop_seller/services/analytics/analytics.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Uploader {
  Future<void> uploadImage(int type, String fileDir, File fileToUpload,
      String fileName, int id, Function onUploaded) async {
    String filePath = '$fileDir/$fileName.png';
    StorageReference reference = FirebaseStorage.instance.ref().child(filePath);
    StorageUploadTask uploadTask = reference.putFile(fileToUpload);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;

    try {
      var profilePathUrl = await storageTaskSnapshot.ref.getDownloadURL();
      if (type == 0) {
        await updateUserData('profile_path', profilePathUrl);
        cachedLocalUser.profilePath = profilePathUrl;
      } else await updateStoreData('store_profile', fileName, id, profilePathUrl);
    } catch (err) {
      Analytics.reportError({
        "type": 'image_upload_error',
        'user_id': id,
        'error': err.toString()
      }, 'storage');
    }

    onUploaded();
  }

  Future<void> updateUserData(
      String field, String profilePathUrl) async {
    try {
      await cachedLocalUser.update({field: profilePathUrl});
    } catch (err) {
      Analytics.reportError({
        "type": 'url_update_error',
        'user_id': cachedLocalUser.getID(),
        'path': profilePathUrl,
        'error': err.toString()
      }, 'storage');
    }
  }

  Future<void> updateStoreData(
      String field, String id, int mobileNumber, String profilePathUrl) async {
    try {
      await Store().updateByID({field: profilePathUrl}, id);
    } catch (err) {
      Analytics.reportError({
        "type": 'url_update_error',
        'user_id': mobileNumber,
        'finance_id': id,
        'path': profilePathUrl,
        'error': err.toString()
      }, 'storage');
    }
  }
}
