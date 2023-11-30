import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

abstract class CryptoAddress with CborSerializable {
  abstract final CryptoCoins coin;
  abstract final CryptoAddressDetailsCore address;
  abstract final AddressDerivationIndex keyIndex;
  abstract final AppNetworkImpl network;
  List<String> get signers;
  String accountToString();
}
