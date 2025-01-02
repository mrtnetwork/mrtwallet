import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/network/ripple/transaction/controller/impl/memo_impl.dart';
import 'package:mrt_wallet/future/widgets/widgets/progress_bar/widgets/page_progress.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:xrpl_dart/xrpl_dart.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';

abstract class RippleTransactionImpl extends StateController {
  RippleTransactionImpl({
    required this.walletProvider,
    required this.account,
  });
  final WalletProvider walletProvider;
  final RippleChain account;
  WalletXRPNetwork get network => account.network;
  RippleClient get apiProvider => account.client;
  IXRPAddress get address => account.address;
  void setFee(String? feeType, {BigInt? customFee});
  List<XRPLMemo> get memos;
  Future<void> onSetupMemo(XRPLMemo? memo, OnSetupMemo onSetupMemo);
  IntegerBalance get fee;
  XrplFeeType? get feeType;
  Map<String, IntegerBalance> get fees;
  final GlobalKey<PageProgressState> progressKey = GlobalKey<PageProgressState>(
      debugLabel: "progressKey_XRPTransaactionStateController");
}
