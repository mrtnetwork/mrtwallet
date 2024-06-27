import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/wallet/models/account/address/core/address.dart';
import 'package:mrt_wallet/wallet/models/account/address/derivation/core/derivation.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:mrt_wallet/wallet/models/signing_request/core/signing_request.dart';

class CosmosSigningRequest extends SigningRequest<List<List<int>>> {
  CosmosSigningRequest(
      {required this.addresses,
      required this.network,
      required List<int> digest})
      : digest = BytesUtils.toBytes(digest, unmodifiable: true);
  @override
  final List<CryptoAddress> addresses;

  @override
  final WalletCosmosNetwork network;

  final List<int> digest;
  @override
  List<AddressDerivationIndex> get signers =>
      addresses.map((e) => e.keyIndex).toList();
}
