import 'package:mrt_wallet/app/models/models/image.dart';

class APPConst {
  static const APPImage logo = APPImage.local("assets/image/mrt_wallet.png");
  static const APPImage telegramLogo = APPImage.local("assets/image/t.png");
  static const APPImage githubLogo = APPImage.local("assets/image/g.png");
  static const APPImage ltc = APPImage.local("assets/image/ltc.png");
  static const APPImage bch = APPImage.local("assets/image/bch.png");
  static const APPImage btc = APPImage.local("assets/image/btc.png");
  static const APPImage doge = APPImage.local("assets/image/doge.png");
  static const APPImage pepecoin = APPImage.local("assets/image/pepecoin.png");
  static const APPImage bsv = APPImage.local("assets/image/bsv.png");
  static const APPImage dash = APPImage.local("assets/image/dash.png");
  static const APPImage xrp = APPImage.local("assets/image/xrp.png");
  static const APPImage eth = APPImage.local("assets/image/eth.png");
  static const APPImage matic = APPImage.local("assets/image/matic.png");
  static const APPImage bnb = APPImage.local("assets/image/bnb.png");
  static const APPImage trx = APPImage.local("assets/image/trx.png");
  static const APPImage sol = APPImage.local("assets/image/sol.png");
  static const APPImage ada = APPImage.local("assets/image/ada.png");
  static const APPImage atom = APPImage.local("assets/image/atom.png");
  static const APPImage cacao = APPImage.local("assets/image/cacao.png");

  static const APPImage thor = APPImage.local("assets/image/thor.png");
  static const APPImage kujira = APPImage.local("assets/image/kujira.png");
  static const APPImage osmo = APPImage.local("assets/image/osmo.png");
  static const APPImage ton = APPImage.local("assets/image/ton.png");

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
