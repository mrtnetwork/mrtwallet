import 'package:mrt_native_support/models/models.dart';
import 'package:mrt_native_support/platform_interface.dart';
import 'package:mrt_wallet/app/native_impl/core/core.dart';

mixin ShareImpl {
  static Future<bool> shareFile(String path, String fileName,
      {String? text, String? subject, FileMimeTypes? mimeType}) async {
    if (PlatformInterface.isWindows) {
      return await BaseNativeMEthod.platform.launchUri(path);
    }

    return await BaseNativeMEthod.platform.share(Share.file(path, fileName,
        subject: subject, text: text, mimeType: mimeType));
  }
}
