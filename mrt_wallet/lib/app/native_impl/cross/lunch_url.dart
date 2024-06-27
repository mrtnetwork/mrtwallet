import 'package:mrt_wallet/app/native_impl/core/core.dart';

mixin LunchUrlImpl {
  static Future<bool> lunchUri(String uri) async {
    return await BaseNativeMEthod.platform.launchUri(uri);
  }
}
