import 'package:mrt_wallet/wallet/models/account/address/core/address.dart';
import 'package:mrt_wallet/wallet/models/account/address/derivation/core/derivation.dart';
import 'package:mrt_wallet/wallet/models/account/address/networks/cardano/cardano.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:mrt_wallet/wallet/models/signing_request/core/signing_request.dart';
import 'package:on_chain/ada/src/builder/builder/transaction_builder.dart';
import 'package:on_chain/ada/src/models/transaction/transaction/transaction.dart';

class CardanoSigningRequest extends SigningRequest<ADATransaction> {
  CardanoSigningRequest(
      {required List<CryptoAddress> addresses,
      required this.network,
      required this.transaction,
      required List<AddressDerivationIndex> signers})
      : addresses = List<ICardanoAddress>.unmodifiable(addresses),
        signers = List<AddressDerivationIndex>.unmodifiable(signers);
  @override
  final List<ICardanoAddress> addresses;

  @override
  final WalletNetwork network;

  final ADATransactionBuilder transaction;

  @override
  final List<AddressDerivationIndex> signers;
}
