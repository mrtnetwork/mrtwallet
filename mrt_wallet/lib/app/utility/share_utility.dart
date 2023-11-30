import 'package:mrt_native_support/models/share.dart';
import 'package:mrt_wallet/app/native_impl/share.dart';

class ShareUtility {
  static Future<bool> shareFile(String path, String fileName,
      {String? text, String? subject, FileMimeTypes? mimeType}) async {
    return await ShareImpl.shareFile(path, fileName,
        subject: subject, text: text, mimeType: mimeType);
  }
}
