import 'package:mrt_wallet/app/native_impl/lunch_url.dart';

class LunchUri {
  static Future<bool> lunch(String uri) async {
    return await LunchUrlImpl.lunchUri(uri);
  }
}
