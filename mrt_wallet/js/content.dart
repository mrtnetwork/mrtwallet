import 'package:mrt_native_support/models/events/models/wallet_event.dart';
import 'package:mrt_native_support/web/mrt_native_web.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/messages/models/models/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/models/authenticated.dart';
import 'js_wallet/constant/constant.dart';
import 'js_wallet/wallet/core/wallet.dart';
import 'js_wallet/models/models/requests.dart';

void main() async {
  final applicationId =
      Web3APPAuthentication.toApplicationId(jsWindow.location.origin);
  if (applicationId == null) {
    throw Web3RequestExceptionConst.invalidHost;
  }
  final future =
      JSExtentionWallet.sendBackgroudMessage(JSWalletConstant.tabIdEvent);

  future.then((backgroundEvent) async {
    JSWalletMessageResponse message;
    if (backgroundEvent.type == WalletEventTypes.exception) {
      final exception =
          Web3ExceptionMessage.deserialize(bytes: backgroundEvent.data);
      message = JSWalletMessageResponse(
          requestId: backgroundEvent.requestId,
          data: exception.toJson(),
          client: JSClientType.ethereum,
          status: JSWalletResponseType.failed);
    } else {
      message = JSWalletMessageResponse(
          requestId: backgroundEvent.requestId,
          data: backgroundEvent.clientId,
          client: JSClientType.ethereum,
          status: JSWalletResponseType.success);
      jsWindow.dispatchEvent(CustomEvent.create(
          type: JSWalletConstant.activationEventName,
          data: message.toCbor().encode(),
          clone: true));
      await Future.delayed(const Duration(seconds: 1));
      JSExtentionWallet.initialize(backgroundEvent);
    }
  });
}
