import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';

enum TonChainId {
  mainnet(value: '-239', workchain: 0),
  testnet(value: '-3', workchain: -1);

  final String value;
  final int workchain;

  const TonChainId({required this.value, required this.workchain});
  static TonChainId fromNetworkId(int id) {
    return values.firstWhere((e) => e.workchain == id,
        orElse: () => throw Web3RequestExceptionConst.invalidNetwork);
  }
}
