import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';

enum ContentType {
  local(0),
  extenal(1),
  hex(2),
  base64(3),
  network(4),
  favIcon(5);

  final int value;
  const ContentType(this.value);

  static ContentType fromValue(int? value, {ContentType? defaultValue}) {
    return values.firstWhere((element) => element.value == value, orElse: () {
      if (defaultValue != null) return defaultValue;
      throw WalletExceptionConst.dataVerificationFailed;
    });
  }
}
