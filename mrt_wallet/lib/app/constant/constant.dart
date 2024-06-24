import 'package:mrt_wallet/models/app/app_image.dart';

export 'custom_colors.dart';
export 'link_const.dart';
export 'page_path.dart';
export 'storage_key.dart';
export 'state_ids.dart';
export 'network_constant/ripple_const.dart';
export 'network_constant/ton.dart';
export 'network_constant/cosmos.dart';

class AppGlobalConst {
  static const AppImage logo = AppImage.local("assets/image/mrt_wallet.png");
  static const AppImage telegramLogo = AppImage.local("assets/image/t.png");
  static const AppImage githubLogo = AppImage.local("assets/image/g.png");
  static const String name = "MRT WALLET";
  static const Duration animationDuraion = Duration(milliseconds: 400);
  static const Duration milliseconds100 = Duration(milliseconds: 100);
  static const Duration oneSecoundDuration = Duration(seconds: 1);
  static const Duration twoSecoundDuration = Duration(seconds: 2);
  static const double double80 = 80;
  static const double double40 = 40;
  static const double double20 = 20;
  static const double dialogWidth = 650;
  static const double maxTextFieldWidth = 400;
  static final RegExp accountNameRegExp = RegExp(r'^[^\n]{0,20}$');
  static final RegExp keyNameRegex = RegExp(r'^[^\n]{0,20}$');

  static const String exampleBase58 = "sEd7FSsSXz9CGy18ajtP8nAkrr....";
  static const String exampleHex = "";
}
