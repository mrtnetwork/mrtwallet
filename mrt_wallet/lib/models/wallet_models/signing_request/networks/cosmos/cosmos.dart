import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/models/wallet_models/address/core/address.dart';
import 'package:mrt_wallet/models/wallet_models/address/core/derivation/address_derivation.dart';
import 'package:mrt_wallet/models/wallet_models/network/core/network.dart';
import 'package:mrt_wallet/models/wallet_models/signing_request/core/signing_request.dart';

class CosmosSigningRequest extends SigningRequest<List<List<int>>> {
  CosmosSigningRequest(
      {required this.addresses,
      required this.network,
      required List<int> digest})
      : digest = BytesUtils.toBytes(digest, unmodifiable: true);
  @override
  final List<CryptoAccountAddress> addresses;

  @override
  final APPCosmosNetwork network;

  final List<int> digest;
  @override
  List<AddressDerivationIndex> get signers =>
      addresses.map((e) => e.keyIndex).toList();
}
