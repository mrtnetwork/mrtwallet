import 'dart:js_interop';

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
  final backgroundEvent =
      await JSExtentionWallet.sendBackgroudMessage(JSWalletConstant.tabIdEvent);
  WalletMessageResponse message;
  if (backgroundEvent.type == WalletEventTypes.exception) {
    final exception =
        Web3ExceptionMessage.deserialize(bytes: backgroundEvent.data);
    message = WalletMessageResponse.fail(exception.toJson().jsify());
  } else {
    message = WalletMessageResponse.success(backgroundEvent.clientId.jsify());
  }
  JSExtentionWallet? wallet;
  if (message.statusType == JSWalletResponseType.success) {
    wallet = JSExtentionWallet.initialize(backgroundEvent);
  }
  jsWindow.dispatchEvent(CustomEvent.create(
      type: JSWalletConstant.activationEventName,
      eventData: WalletMessage.response(
          requestId: "0", client: JSClientType.global, data: message),
      clone: true));
  wallet?.initClients();
}
