import 'package:mrt_wallet/wallet/models/account/address/core/address.dart';
import 'package:mrt_wallet/wallet/models/account/address/derivation/core/derivation.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:mrt_wallet/wallet/models/signing_request/signing_reguest.dart';
import 'package:on_chain/solana/solana.dart';

class SolanaSigningRequest extends SigningRequest<SolanaTransaction> {
  SolanaSigningRequest(
      {required this.network,
      required List<CryptoAddress> addresses,
      required this.solanaTransaction})
      : addresses = List<CryptoAddress>.unmodifiable(addresses);
  @override
  final List<CryptoAddress> addresses;
  final SolanaTransaction solanaTransaction;

  @override
  WalletNetwork network;

  @override
  List<AddressDerivationIndex> get signers =>
      addresses.map((e) => e.keyIndex).toList();
}
