import 'dart:async';

import 'package:mrt_native_support/models/models.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/models.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/exception/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/permission.dart';
import 'package:mrt_wallet/wallet/web3/models/models.dart';
import 'params.dart';

enum Web3RequestCompleterErrorType {
  response,
  error,

  closed,
  success;

  bool get canUpdate {
    switch (this) {
      case response:
      case error:
        return true;
      default:
        return false;
    }
  }

  bool get isDone => !canUpdate;
  bool get isSuccess => this == success;
}

class Web3RequestApplicationInformation with Equatable {
  final Web3ClientInfo info;
  final WalletEvent request;
  Web3RequestApplicationInformation._(
      {required this.info, required this.request});
  factory Web3RequestApplicationInformation(
      {required Web3ClientInfo info, required WalletEvent request}) {
    return Web3RequestApplicationInformation._(info: info, request: request);
  }

  bool get isClosed => _controller.isClosed;
  Stream<Web3RequestCompleterErrorType> get stream => _controller.stream;
  bool get hasListener => _controller.hasListener;
  late final StreamController<Web3RequestCompleterErrorType> _controller =
      StreamController<Web3RequestCompleterErrorType>.broadcast(sync: true);

  final Completer<WalletEvent> _requestComoleter = Completer<WalletEvent>();
  final Completer<Object?> _responseCompleter = Completer();

  void completeResponse(Object? response) {
    if (_responseCompleter.isCompleted) return;
    _responseCompleter.complete(response);
    _controller.add(Web3RequestCompleterErrorType.response);
  }

  void errorResponse(
      {Web3RequestException error = Web3RequestExceptionConst.rejectedByUser}) {
    if (_responseCompleter.isCompleted) return;
    _responseCompleter.completeError(error);
    _controller.add(Web3RequestCompleterErrorType.error);
  }

  void completeError() {
    _controller.add(Web3RequestCompleterErrorType.closed);
    _controller.close();
    if (!_responseCompleter.isCompleted) {
      _responseCompleter.completeError(Web3RejectException.instance);
    }
  }

  void completeSuccess() {
    _controller.add(Web3RequestCompleterErrorType.success);
    _controller.close();
    assert(_requestComoleter.isCompleted, "must be completed.");
  }

  String get applicationId => info.applicationId;

  void completeRequest(WalletEvent event) {
    _requestComoleter.complete(event);
  }

  void errorRequest() {
    _requestComoleter.completeError(Web3RejectException.instance);
  }

  Future<WalletEvent> get onCompleteRequest {
    return _requestComoleter.future;
  }

  @override
  List get variabels => [info, request.requestId];
}

typedef WEB3CHAINREQUEST<NETWORKADDRESS> = Web3Request<
    dynamic,
    NETWORKADDRESS,
    APPCHAINNETWORK<NETWORKADDRESS>,
    Web3ChainAccount<NETWORKADDRESS>,
    Web3Chain<NETWORKADDRESS, APPCHAINNETWORK<NETWORKADDRESS>,
        Web3ChainAccount<NETWORKADDRESS>>,
    Web3RequestParams<
        dynamic,
        NETWORKADDRESS,
        APPCHAINNETWORK<NETWORKADDRESS>,
        Web3ChainAccount<NETWORKADDRESS>,
        Web3Chain<NETWORKADDRESS, APPCHAINNETWORK<NETWORKADDRESS>,
            Web3ChainAccount<NETWORKADDRESS>>>>;

abstract class Web3Request<
    RESPONSE,
    NETWORKADDRESS,
    CHAIN extends APPCHAINNETWORK<NETWORKADDRESS>,
    CHANACCOUNT extends Web3ChainAccount<NETWORKADDRESS>,
    WEB3CHAIN extends Web3Chain<NETWORKADDRESS, CHAIN, CHANACCOUNT>,
    PARAMS extends Web3RequestParams<RESPONSE, NETWORKADDRESS, CHAIN,
        CHANACCOUNT, WEB3CHAIN>> {
  Web3Request(
      {required this.params,
      required this.authenticated,
      required this.chain,
      required this.info});
  final Web3RequestApplicationInformation info;
  final PARAMS params;
  final CHAIN chain;
  final Web3APPAuthentication authenticated;

  WEB3CHAIN? get currentPermission =>
      authenticated.getChainFromNetworkType(chain.network.type);
  bool get hasAnyPermission => currentPermission?.hasPermission(chain) ?? false;
  NETWORKCHAINACCOUNT<NETWORKADDRESS>? accountPermission();
  bool get isPermissionRequest => params.isPermissionRequest;
  bool get needPermission => params.account != null;

  void completeResponse(Object? response) {
    if (response is! RESPONSE) {
      throw WalletExceptionConst.invalidArgruments(
          "$RESPONSE", response.runtimeType.toString());
    }
    info.completeResponse(response);
  }

  void error(Web3RequestException message) {
    info.errorResponse(error: message);
  }

  void reject() {
    info.errorResponse();
  }

  Future<RESPONSE> getResponse() async {
    if (info.isClosed) {
      if (!info._responseCompleter.isCompleted) {
        MethodUtils.nullOnException(() => info._responseCompleter
            .completeError(Web3RejectException.instance));
      }

      throw Web3RejectException.instance;
    }
    final result = await info._responseCompleter.future;
    return result as RESPONSE;
  }

  void verifyPermissioon() => accountPermission();
}
