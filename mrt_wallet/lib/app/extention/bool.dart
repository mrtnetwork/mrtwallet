import 'package:mrt_wallet/app/extention/string.dart';

extension QuickBooleanExtension on bool {
  String get tr {
    if (this) return "yes".tr;
    return "no".tr;
  }
}
