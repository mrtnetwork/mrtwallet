import 'package:mrt_wallet/app/models/models/image.dart';

class APPConst {
  static const APPImage logo = APPImage.local("assets/image/mrt_wallet.png");
  static const APPImage telegramLogo = APPImage.local("assets/image/t.png");
  static const APPImage githubLogo = APPImage.local("assets/image/g.png");
  static const String name = "MRT WALLET";
  static const Duration animationDuraion = Duration(milliseconds: 400);
  static const Duration milliseconds100 = Duration(milliseconds: 100);
  static const Duration oneSecoundDuration = Duration(seconds: 1);
  static const Duration twoSecoundDuration = Duration(seconds: 2);
  static const Duration tenSecoundDuration = Duration(seconds: 10);
  // static const Duration fiveSecoundDuration = Duration(seconds: 20);

  static const double double80 = 80;
  static const double double40 = 40;
  static const double double20 = 20;
  static const double dialogWidth = 650;
  static const double maxTextFieldWidth = 400;
  static final RegExp accountNameRegExp = RegExp(r'^[^\n]{0,20}$');
  static final RegExp keyNameRegex = RegExp(r'^[^\n]{0,20}$');

  static const String exampleBase58 = "sEd7FSsSXz9CGy18ajtP8nAkrr....";
  static const String exampleHex = "";

  static const int defaultDecimalPlaces = 8;
}
