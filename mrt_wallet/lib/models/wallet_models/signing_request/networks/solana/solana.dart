import 'package:mrt_wallet/models/wallet_models/address/core/address.dart';
import 'package:mrt_wallet/models/wallet_models/address/core/derivation/address_derivation.dart';
import 'package:mrt_wallet/models/wallet_models/network/core/network.dart';
import 'package:mrt_wallet/models/wallet_models/signing_request/signing_reguest.dart';
import 'package:on_chain/solana/solana.dart';

class SolanaSigningRequest extends SigningRequest<SolanaTransaction> {
  SolanaSigningRequest(
      {required this.network,
      required List<CryptoAccountAddress> addresses,
      required this.solanaTransaction})
      : addresses = List<CryptoAccountAddress>.unmodifiable(addresses);
  @override
  final List<CryptoAccountAddress> addresses;
  final SolanaTransaction solanaTransaction;

  @override
  AppNetworkImpl network;

  @override
  List<AddressDerivationIndex> get signers =>
      addresses.map((e) => e.keyIndex).toList();
}
