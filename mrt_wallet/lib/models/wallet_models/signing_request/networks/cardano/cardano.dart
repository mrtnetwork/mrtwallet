import 'package:mrt_wallet/models/wallet_models/address/core/address.dart';
import 'package:mrt_wallet/models/wallet_models/address/core/derivation/address_derivation.dart';
import 'package:mrt_wallet/models/wallet_models/address/network_address/cardano/cardano.dart';
import 'package:mrt_wallet/models/wallet_models/network/core/network.dart';
import 'package:mrt_wallet/models/wallet_models/signing_request/core/signing_request.dart';
import 'package:on_chain/ada/src/builder/builder/transaction_builder.dart';
import 'package:on_chain/ada/src/models/transaction/transaction/transaction.dart';

class CardanoSigningRequest extends SigningRequest<ADATransaction> {
  CardanoSigningRequest(
      {required List<CryptoAccountAddress> addresses,
      required this.network,
      required this.transaction,
      required List<AddressDerivationIndex> signers})
      : addresses = List<ICardanoAddress>.unmodifiable(addresses),
        signers = List<AddressDerivationIndex>.unmodifiable(signers);
  @override
  final List<ICardanoAddress> addresses;

  @override
  final AppNetworkImpl network;

  final ADATransactionBuilder transaction;

  @override
  final List<AddressDerivationIndex> signers;
}
