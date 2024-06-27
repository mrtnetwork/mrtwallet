import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/network/ethereum/transaction/controller/impl/fee_impl.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';

abstract class EthTransactionImpl extends StateController {
  EthTransactionImpl(
      {required this.walletProvider,
      required this.account,
      required this.network,
      required this.address,
      required this.apiProvider});
  final WalletProvider walletProvider;
  final NetworkAccountCore account;
  final WalletEthereumNetwork network;
  final EthereumClient apiProvider;
  final IEthAddress address;
  IEthAddress get owner => address;
  void setFee(EIP1559FeeSpeed? speed, {EthereumFee? customFee});
  void stopGasEstimate();
  final GlobalKey<PageProgressState> progressKey = GlobalKey<PageProgressState>(
      debugLabel: "progressKey_EthTransactionImpl");
}
