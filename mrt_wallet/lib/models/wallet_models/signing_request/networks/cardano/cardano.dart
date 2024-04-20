import 'package:mrt_wallet/models/wallet_models/address/core/address.dart';
import 'package:mrt_wallet/models/wallet_models/address/core/derivation/address_derivation.dart';
import 'package:mrt_wallet/models/wallet_models/network/core/network.dart';
import 'package:mrt_wallet/models/wallet_models/signing_request/core/signing_request.dart';
import 'package:on_chain/ada/src/builder/builder/transaction_builder.dart';

class CardanoSigningRequest implements SigningRequest {
  const CardanoSigningRequest(
      {required this.addresses,
      required this.network,
      required this.transaction});
  @override
  final List<CryptoAccountAddress> addresses;

  @override
  final AppNetworkImpl network;

  final ADATransactionBuilder transaction;

  @override
  List<AddressDerivationIndex> get signers =>
      addresses.map((e) => e.keyIndex).toList();
}
