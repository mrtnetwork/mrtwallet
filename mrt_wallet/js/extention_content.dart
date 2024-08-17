import 'package:mrt_native_support/models/events/models/wallet_event.dart';
import 'package:mrt_native_support/web/mrt_native_web.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/messages/models/models/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/models/authenticated.dart';
import 'js_wallet/handler/handler.dart';
import 'js_wallet/models/models/page_request.dart';

final tabIdEvent = WalletEvent(
    clientId: "background",
    data: [],
    requestId: "",
    type: WalletEventTypes.tabId);
// @JS("cloneInto")
// external T cloneInto<T extends JSAny>(T? object, JSAny? where);
void main() async {
  final applicationId =
      Web3APPAuthentication.toApplicationId(jsWindow.location.origin);
  if (applicationId == null) {
    throw Web3RequestExceptionConst.invalidHost;
  }
  final future = ExtentionWalletHandler.sendBackgroudMessage(tabIdEvent);
  future.then((backgroundEvent) async {
    WalletRequestResponse message;
    if (backgroundEvent.type == WalletEventTypes.exception) {
      final exception =
          Web3ExceptionMessage.deserialize(bytes: backgroundEvent.data);
      message = WalletRequestResponse(
          requestId: backgroundEvent.requestId,
          data: exception.toJson(),
          client: ClientMessageType.ethereum,
          status: WalletRequestResponseType.failed);
    } else {
      final wallet = await ExtentionWalletHandler.initialize(backgroundEvent);
      message = WalletRequestResponse(
          requestId: backgroundEvent.requestId,
          data: wallet.clientId,
          client: ClientMessageType.ethereum,
          status: WalletRequestResponseType.success);
    }
    jsWindow.dispatchEvent(CustomEvent.create(
        type: "MRT_ACTIVATION", data: message.toCbor().encode(), clone: true));
  });
}
