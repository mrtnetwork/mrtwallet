part of 'wallet.dart';

mixin JSWalletStandardHandler {
  abstract final Map<JSClientType, JSWalletStandardNetworkHandler> _networks;
  void _sendEventToClient(WalletMessageEvent event, JSClientType? client);
  Future<(List<JSWalletStandardAccount>, List<String>)>
      _getWalletChange() async {
    final states =
        await Future.wait(_networks.values.map((e) => e.getState()).toList());
    final accounts = states.map((e) => e.jsAccounts).expand((e) => e).toList();
    final chains = states.map((e) => e.chains).expand((e) => e).toList();
    return (accounts, chains.map((e) => e.identifier).toList());
  }

  Future<void> _sendGlobalEvent() async {
    final change = await _getWalletChange();
    final event =
        JSWalletStandardChange.setup(accounts: change.$1, chains: change.$2);
    _sendEventToClient(WalletMessageEvent.build(data: event), null);
  }

  void _onGlobalEvent(PageMessageEvent event) {
    _sendGlobalEvent();
  }

  Future<Web3MessageCore> _onGlobalRequest(
      {required Web3GlobalRequestMethods globalMethod,
      required JSClientType? client}) async {
    switch (globalMethod) {
      case Web3GlobalRequestMethods.disconnect:
        return _networks[client]!.discoonect();
      case Web3GlobalRequestMethods.connect:
        return Web3ConnectApplication();
      default:
        throw Web3RequestExceptionConst.methodDoesNotExist;
    }
  }

  Future<WalletMessageResponse> _finalizeGlobalResponse(
      {required PageMessageRequest message,
      required Web3RequestParams? params,
      required Web3GlobalResponseMessage response}) async {
    final method = Web3GlobalRequestMethods.fromName(message.method);
    switch (method) {
      case Web3GlobalRequestMethods.disconnect:
        return WalletMessageResponse.success(true.toJS);
      case Web3GlobalRequestMethods.connect:
        final accounts = (await _getWalletChange()).$1;
        if (accounts.isNotEmpty) {
          return WalletMessageResponse.success(
              JSWalletStandardConnect.setup(accounts));
        }
        return WalletMessageResponse.fail(Web3RequestExceptionConst
            .rejectedByUser
            .toResponseMessage()
            .toJson()
            .jsify());
      default:
        throw Web3RequestExceptionConst.methodDoesNotExist;
    }
  }
}
