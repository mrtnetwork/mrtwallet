export 'custom_colors.dart';
export 'link_const.dart';
export 'page_path.dart';
export 'storage_key.dart';
export 'state_ids.dart';

class AppGlobalConst {
  static const String logo = "assets/image/mrt_wallet.png";
  static const String telegramLogo = "assets/image/t.png";
  static const String githubLogo = "assets/image/g.png";
  static const String name = "MRT WALLET";
  static const Duration animationDuraion = Duration(milliseconds: 400);
  static const Duration milliseconds100 = Duration(milliseconds: 100);
  static const Duration oneSecoundDuration = Duration(seconds: 1);
  static const double double80 = 80;
  static const double double40 = 40;
  static const double dialogWidth = 450;
  static const double maxTextFieldWidth = 400;
  static final RegExp accountNameRegExp = RegExp(r'^[^\n]{0,20}$');
}
