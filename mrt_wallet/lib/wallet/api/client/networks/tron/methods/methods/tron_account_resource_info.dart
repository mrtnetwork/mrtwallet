import 'package:mrt_wallet/wallet/models/networks/tron/models/account_resource_info.dart';
import 'package:on_chain/tron/tron.dart';

/// Query the resource information of an account(bandwidth,energy,etc).
/// [developers.tron.network](https://developers.tron.network/reference/getaccountresource).
class TronRequestGetAccountResourceInfo
    extends TVMRequestParam<TronAccountResourceInfo, Map<String, dynamic>> {
  TronRequestGetAccountResourceInfo(
      {required this.address, this.visible = true});

  /// Address
  final TronAddress address;
  @override
  final bool visible;

  @override
  TronHTTPMethods get method => TronHTTPMethods.getaccountresource;

  /// wallet/getaccountresource
  @override
  Map<String, dynamic> toJson() {
    return {"address": address, "visible": visible};
  }

  @override
  TronAccountResourceInfo onResonse(result) {
    return TronAccountResourceInfo.fromJson(result);
  }

  @override
  String toString() {
    return "TronRequestGetAccountResource{${toJson()}}";
  }
}
