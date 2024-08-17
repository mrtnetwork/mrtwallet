import 'package:mrt_wallet/app/utils/method/utiils.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/ethereum.dart';
import 'package:mrt_wallet/wallet/api/services/impl/socket/protocols/websocket.dart';
import 'package:mrt_wallet/wallet/api/services/models/models/request_completer.dart';
import 'package:mrt_wallet/wallet/api/services/models/networks/ethereum.dart';
import 'package:on_chain/on_chain.dart';

class _EthereumWebsocketServiceConst {
  static const String subscriptionMethodName = "eth_subscription";
  static const String params = "params";
  static const String method = "method";
}

class EthereumWebsocketService extends WebSocketService<EthereumAPIProvider>
    implements JSONRPCService {
  EthereumWebsocketService(
      {required super.url,
      required super.provider,
      this.defaultTimeOut = const Duration(seconds: 30)});
  final List<ONETHSubsribe> _listeners = [];

  void addSubscriptionListener(ONETHSubsribe listener) {
    _listeners.add(listener);
  }

  void removeSubscriptionListener(ONETHSubsribe listener) {
    _listeners.remove(listener);
  }

  void _emitListeners(EthereumSubscribeResult result) {
    for (final i in [..._listeners]) {
      MethodUtils.nullOnException(() => i(result));
    }
  }

  @override
  Map<String, dynamic>? onMessge(String event) {
    final message = super.onMessge(event);
    if (message != null &&
        message[_EthereumWebsocketServiceConst.method] ==
            _EthereumWebsocketServiceConst.subscriptionMethodName) {
      final result = MethodUtils.nullOnException(() {
        return EthereumSubscribeResult.fromJson(
            message[_EthereumWebsocketServiceConst.params]);
      });
      if (result != null) {
        _emitListeners(result);
      }
    }
    return message;
  }

  final Duration defaultTimeOut;
  @override
  Future<Map<String, dynamic>> call(ETHRequestDetails params,
      [Duration? timeout]) async {
    final SocketRequestCompeleter message =
        SocketRequestCompeleter(params.params, params.id);
    return await addMessage(message, timeout ?? defaultTimeOut);
  }

  @override
  void disposeService() {
    super.disposeService();
    _listeners.clear();
  }
}
