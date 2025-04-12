// import 'package:bitcoin_base/bitcoin_base.dart';
// import 'package:blockchain_utils/cbor/cbor.dart';
// import 'package:mrt_wallet/app/core.dart';
// import 'package:mrt_wallet/wallet/web3/core/core.dart';
// import 'package:mrt_wallet/wallet/web3/networks/bitcoin/methods/methods.dart';
// import 'package:mrt_wallet/wallet/web3/networks/bitcoin/params/core/request.dart';

// class Web3BitcoinSwitchChain extends Web3BitcoinRequestParam<bool> {
//   Web3BitcoinSwitchChain();

//   factory Web3BitcoinSwitchChain.deserialize(
//       {List<int>? bytes, CborObject? object, String? hex}) {
//     CborSerializable.cborTagValue(
//         cborBytes: bytes,
//         object: object,
//         hex: hex,
//         tags: Web3MessageTypes.walletRequest.tag);
//     return Web3BitcoinSwitchChain();
//   }
//   @override
//   Web3BitcoinRequestMethods get method =>
//       Web3BitcoinRequestMethods.switchNetwork;

//   @override
//   CborTagValue toCbor() {
//     return CborTagValue(CborListValue.fixedLength([method.tag]), type.tag);
//   }

//   @override
//   Map<String, dynamic> toJson() {
//     return {};
//   }

//   @override
//   BitcoinBaseAddress? get account => null;
// }
