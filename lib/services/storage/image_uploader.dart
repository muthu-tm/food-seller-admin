import 'dart:io';
import 'package:chipchop_seller/db/models/store.dart';
import 'package:chipchop_seller/services/controllers/user/user_service.dart';
import 'package:chipchop_seller/services/analytics/analytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:exif/exif.dart';
import 'package:image/image.dart' as img;

class Uploader {
  Future<String> uploadImageFile(
      bool rotationCheck, String localFilePath, String filePath) async {
    try {
      File imageFile;
      if (rotationCheck)
        imageFile = await fixExifRotation(localFilePath);
      else
        imageFile = File(localFilePath);

      if (imageFile != null) {
        UploadTask task =
            FirebaseStorage.instance.ref().child(filePath).putFile(imageFile);
        TaskSnapshot taskSnapshot = await task;
        return await taskSnapshot.ref.getDownloadURL();
      }

      return "";
    } catch (err) {
      throw err;
    }
  }

  Future<File> fixExifRotation(String imagePath) async {
    final originalFile = File(imagePath);
    try {
      List<int> imageBytes = await originalFile.readAsBytes();
      final originalImage = img.decodeImage(imageBytes);

      final height = originalImage.height;
      final width = originalImage.width;

      if (height >= width) {
        return originalFile;
      }
      final exifData = await readExifFromBytes(imageBytes);
      img.Image fixedImage;

      print(
          'Rotating image necessary' + exifData['Image Orientation'].printable);
      if (exifData['Image Orientation'].printable.contains('90 CW') ||
          exifData['Image Orientation'].printable.contains('Horizontal')) {
        fixedImage = img.copyRotate(originalImage, 90);
      } else if (exifData['Image Orientation'].printable.contains('180')) {
        fixedImage = img.copyRotate(originalImage, -90);
      } else if (exifData['Image Orientation'].printable.contains('CCW')) {
        fixedImage = img.copyRotate(originalImage, 180);
      } else {
        fixedImage = img.copyRotate(originalImage, 0);
      }

      final fixedFile =
          await originalFile.writeAsBytes(img.encodePng(fixedImage));

      return fixedFile;
    } catch (err) {
      return originalFile;
    }
  }

  Future<void> uploadImage(int type, String fileDir, File fileToUpload,
      String fileName, int id, Function onUploaded) async {
    String filePath = '$fileDir/$fileName.png';
    UploadTask uploadTask =
        FirebaseStorage.instance.ref().child(filePath).putFile(fileToUpload);
    TaskSnapshot taskSnapshot = await uploadTask;

    try {
      var profilePathUrl = await taskSnapshot.ref.getDownloadURL();
      if (type == 0) {
        await updateUserData('profile_path', profilePathUrl);
        cachedLocalUser.profilePath = profilePathUrl;
      } else
        await updateStoreData('store_profile', fileName, id, profilePathUrl);
    } catch (err) {
      Analytics.reportError({
        "type": 'image_upload_error',
        'user_id': id,
        'error': err.toString()
      }, 'storage');
    }

    onUploaded();
  }

  Future<void> updateUserData(String field, String profilePathUrl) async {
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
