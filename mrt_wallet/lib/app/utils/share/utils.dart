import 'package:mrt_native_support/models/models.dart';
import 'package:mrt_wallet/app/native_impl/cross/share.dart';

class ShareUtils {
  static Future<bool> shareFile(String path, String fileName,
      {String? text, String? subject, FileMimeTypes? mimeType}) async {
    return await ShareImpl.shareFile(path, fileName,
        subject: subject, text: text, mimeType: mimeType);
  }
}
