import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/web3/web3.dart';
import 'package:mrt_wallet/wallet/models/chain/address/core/address.dart';
import 'package:mrt_wallet/wallet/web3/core/request/web_request.dart';

abstract class Web3StateContoller extends StateController
    with Web3RequestControllerState {}

mixin Web3RequestControllerState on StateController {
  Web3Request get web3Request;
  StreamSubscription<dynamic>? onRequestError;
  final GlobalKey<Web3PageProgressState> progressKey =
      GlobalKey<Web3PageProgressState>();

  void _onChangeStatus(Web3RequestCompleterErrorType status) {
    switch (status) {
      case Web3RequestCompleterErrorType.success:
        progressKey.successRequest();
        break;
      case Web3RequestCompleterErrorType.closed:
        progressKey.closedRequest();
        break;
      default:
    }
  }

  void _init() {
    if (web3Request.info.isClosed) {
      progressKey.closedRequest();
    } else {
      onRequestError =
          web3Request.info.stream.asBroadcastStream().listen(_onChangeStatus);
      progressKey.idle();
    }
  }

  ChainAccount? permissionAccount;

  @override
  void close() {
    onRequestError?.cancel();
    onRequestError = null;
    super.close();
  }

  Future<void> readyWeb3() async {
    permissionAccount = web3Request.accountPermission();
    notify();
    await MethodUtils.after(() async => _init());
  }

  @override
  void ready() {
    super.ready();
    readyWeb3();
  }
}
