import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wroker/derivation/core/derivation.dart';

abstract class Web3ChainAccount<NETWORKADDRESS>
    with CborSerializable, Equatable {
  final AddressDerivationIndex keyIndex;
  final NETWORKADDRESS address;
  String get addressStr;
  Web3ChainAccount({required this.keyIndex, required this.address});
}
