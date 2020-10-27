import 'package:chipchop_seller/services/analytics/analytics.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageUtils {
  Future<bool> removeFile(String fileURL) async {
    try {
      StorageReference reference =
          await FirebaseStorage.instance.getReferenceFromUrl(fileURL);

      await reference.delete();
      return true;
    } catch (err) {
      Analytics.reportError({
        'type': 'storage_remove_error',
        'file': fileURL,
        'error': err.toString()
      }, 'storage');
      return false;
    }
  }
}
