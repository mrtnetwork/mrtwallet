import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/derivation/core/derivation.dart';

abstract class Web3ChainAccount<NETWORKADDRESS>
    with CborSerializable, Equatable {
  final AddressDerivationIndex keyIndex;
  final NETWORKADDRESS address;
  bool _defaultAddress;
  bool get defaultAddress => _defaultAddress;
  String get addressStr;
  Web3ChainAccount({
    required this.keyIndex,
    required this.address,
    required bool defaultAddress,
  }) : _defaultAddress = defaultAddress;

  void changeDefault(bool defaultAddress) {
    _defaultAddress = defaultAddress;
  }
}
