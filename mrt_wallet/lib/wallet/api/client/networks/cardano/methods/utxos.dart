import 'package:mrt_wallet/wallet/models/networks/cardano/models/utxos.dart';
import 'package:on_chain/ada/src/address/era/core/address.dart';
import 'package:on_chain/ada/src/provider/blockfrost/core/blockfrost.dart';
import 'package:on_chain/ada/src/provider/blockfrost/core/core.dart';
import 'package:on_chain/ada/src/provider/blockfrost/models/response_model.dart';

/// UTXOs of the address.
/// https://blockfrost.dev/api/address-utx-os
class BlockfrostRequestGetAddressUTXOs extends BlockforestRequestParam<
    List<ADAAccountUTXOs>, List<Map<String, dynamic>>> {
  BlockfrostRequestGetAddressUTXOs(this.address,
      {BlockforestRequestFilterParams? filter})
      : super(filter: filter);

  final ADAAddress address;

  /// Address UTXOs
  @override
  String get method => BlockfrostMethods.addressUTXOs.url;

  @override
  List<String> get pathParameters => [address.address];

  @override
  List<ADAAccountUTXOs> onResonse(List<Map<String, dynamic>> result) {
    return result.map((e) => ADAAccountUTXOs.fromJson(e)).toList();
  }
}
