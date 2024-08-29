import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/derivation/core/derivation.dart';

abstract class Web3ChainAccount<NETWORKADDRESS>
    with CborSerializable, Equatable {
  final AddressDerivationIndex keyIndex;
  final NETWORKADDRESS address;
  final bool defaultAddress;
  String get addressStr;
  Web3ChainAccount({
    required this.keyIndex,
    required this.address,
    required this.defaultAddress,
  });
}
