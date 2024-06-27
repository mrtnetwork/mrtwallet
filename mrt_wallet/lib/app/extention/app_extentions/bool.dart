import 'package:mrt_wallet/app/extention/app_extentions/string.dart';

extension QuickBooleanExtension on bool {
  String get tr {
    if (this) return "yes".tr;
    return "no".tr;
  }
}
