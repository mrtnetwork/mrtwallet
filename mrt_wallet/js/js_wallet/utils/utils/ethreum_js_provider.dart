import 'dart:async';

import 'package:blockchain_utils/exception/exception/rpc_error.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/app/error/exception/exception.dart'
    show ApiProviderException;
import 'package:mrt_wallet/wallet/api/provider/networks/ethereum.dart';
import 'package:mrt_wallet/wallet/api/services/core/base_service.dart'
    show BaseServiceProtocol;
import 'package:mrt_wallet/wallet/api/services/models/models/protocols.dart';
import 'package:mrt_wallet/wallet/api/services/models/networks/ethereum.dart';
import 'package:mrt_wallet/wallet/api/services/networks/http/services/ethereum.dart';
import 'package:mrt_wallet/wallet/api/services/networks/websocket/services/ethereum.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/exception/exception.dart'
    show Web3RequestException;
import 'package:on_chain/ethereum/src/rpc/core/methods.dart'
    show EthereumMethods;
import 'package:on_chain/ethereum/src/rpc/methds/dynamic.dart';
import 'package:on_chain/ethereum/src/rpc/provider/provider.dart';

typedef ONETHSubsribe = void Function(EthereumSubscribeResult);

class JSEthereumClient {
  final EthereumProvider provider;
  JSEthereumClient._(this.provider);
  factory JSEthereumClient(EthereumAPIProvider provider,
      {Duration? requestTimeout}) {
    if (provider.protocol == ServiceProtocol.websocket) {
      return JSEthereumClient._(
          EthereumProvider(EthereumWebsocketService(provider: provider)));
    }
    return JSEthereumClient._(EthereumProvider(EthereumHTTPService(
        provider: provider, requestTimeout: requestTimeout)));
  }
  bool get isConnect => true;
  BaseServiceProtocol<EthereumAPIProvider> get service =>
      provider.rpc as BaseServiceProtocol<EthereumAPIProvider>;
  bool get supportSubscribe => service.protocol == ServiceProtocol.websocket;
  void addSubscriptionListener(ONETHSubsribe listener) {
    if (!supportSubscribe) return;
    (service as EthereumWebsocketService).addSubscriptionListener(listener);
  }

  void removeSubscriptionListener(ONETHSubsribe listener) {
    if (!supportSubscribe) return;
    (service as EthereumWebsocketService).removeSubscriptionListener(listener);
  }

  Future<String> _subscribe({List<dynamic> params = const []}) async {
    if (!supportSubscribe) {
      throw Web3RequestExceptionConst.methodDoesNotSupport;
    }
    final result = await provider.request(EthereumRequestDynamic<String>(
        methodName: EthereumMethods.subscribe.value, params: params));
    return result;
  }

  Future<dynamic> _dynamicCall(String method, dynamic params) async {
    return await provider
        .request(EthereumRequestDynamic(methodName: method, params: params));
  }

  final Map<int, Completer> _completers = {};
  int _id = 0;
  Future<void> addRequest({
    required int id,
    required EthereumMethods method,
    required List<dynamic> params,
  }) async {
    try {
      dynamic result;
      if (method == EthereumMethods.subscribe) {
        result = await _subscribe(params: params);
      } else {
        result = await _dynamicCall(method.value, params);
      }
      final completer = _completers.remove(id);
      completer?.complete(result);
    } catch (e) {
      final completer = _completers.remove(id);
      completer?.completeError(e);
    }
  }

  Future<dynamic> call(String methodName, List<dynamic> params) async {
    if (!isConnect) {
      throw Web3RequestExceptionConst.disconnectedChain;
    }
    final method = EthereumMethods.fromName(methodName);
    if (method == null) {
      throw Web3RequestExceptionConst.methodDoesNotExist;
    }
    try {
      final id = _id++;
      final completer = Completer();
      _completers[id] = completer;
      addRequest(id: id, method: method, params: params);
      return completer.future;
    } on Web3RequestException {
      rethrow;
    } on RPCError catch (e) {
      throw Web3RequestExceptionConst.fromException(e);
    } on ApiProviderException catch (e) {
      if (e.isTimeout) {
        throw Web3RequestExceptionConst.disconnectProvider;
      } else {
        throw Web3RequestExceptionConst.disconnectProvider;
      }
    } catch (e) {
      throw Web3RequestExceptionConst.disconnectProvider;
    }
  }

  void close() {
    final completers = _completers.keys;
    service.disposeService();
    for (final i in completers) {
      final completer = _completers.remove(i);
      if (completer == null || completer.isCompleted) continue;
      try {
        completer.completeError(Web3RequestExceptionConst.disconnectProvider);
      } catch (_) {}
    }
  }
}
