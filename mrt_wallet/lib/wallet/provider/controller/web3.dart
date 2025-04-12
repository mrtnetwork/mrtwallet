part of 'package:mrt_wallet/wallet/provider/wallet_provider.dart';

/// wallet web3 operations
mixin Web3Impl on WalletManager {
  Future<Web3EncryptedMessage> _getWeb3Authenticated(
      Web3ClientInfo info) async {
    final auth = await _getOrCreateAppAuthenticated(info);
    final sha256 = await crypto.generateHash(
        type: CryptoRequestHashingType.sha256,
        dataBytes: StringUtils.encode(info.clientId),
        isolate: false);
    final message = Web3ChainMessage(
        authenticated: auth.createAuth(_appChains.getWeb3NetworkData()),
        type: Web3MessageTypes.chains);
    final encryptedKey = await crypto.cryptoMainRequest(
        CryptoRequestEncryptChacha(
            message: message.toCbor().encode(), key: sha256));
    return Web3EncryptedMessage(
        message: encryptedKey.encrypted, nonce: encryptedKey.nonce);
  }

  Future<Web3EncryptedMessage> _getWeb3Permission(Web3ClientInfo info) async {
    final auth = await _getOrCreateAppAuthenticated(info);
    final message = Web3ChainMessage(
        authenticated: auth.createAuth(_appChains.getWeb3NetworkData()),
        type: Web3MessageTypes.chains);
    final encryptedKey = await crypto.cryptoMainRequest(
        CryptoRequestEncryptChacha(
            message: message.toCbor().encode(), key: auth.token));
    return Web3EncryptedMessage(
        message: encryptedKey.encrypted, nonce: encryptedKey.nonce);
  }

  Future<Web3APPAuthentication> _getOrCreateAppAuthenticated(
      Web3ClientInfo info) async {
    try {
      final permission = await _core._readWeb3Permission(
          applicationId: info.applicationId, wallet: _wallet);

      final toPermission = MethodUtils.nullOnException(() {
        return Web3APPAuthentication.deserialize(hex: permission);
      });
      if (toPermission == null) {
        final token = await crypto.generateRandomBytes();
        final applicationKey = await crypto.generateHashString(
            type: CryptoRequestHashingType.md4,
            dataBytes: info.applicationId.codeUnits,
            isolate: false);
        final permission = Web3APPAuthentication.create(
            name: info.name,
            applicationKey: applicationKey,
            applicationId: info.applicationId,
            icon: info.image,
            token: token);
        await _core._savePermission(permission: permission, wallet: _wallet);
        return permission;
      }

      return toPermission;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> _getWalletOwnerResult(Web3Request request) async {
    final push = _core.onWeb3Request(request);
    if (!(push)) {
      throw Web3RequestExceptionConst.internalError;
    }
    return await request.getResponse();
  }

  Future<Web3MessageCore> _handleGlobalRequest(
      {required Web3GlobalRequestParams requestParams,
      required Web3APPAuthentication authenticated,
      required Web3RequestApplicationInformation walletRequest}) async {
    Web3GlobalRequest request = Web3GlobalRequest(
        authenticated: authenticated,
        info: walletRequest,
        params: requestParams);
    List<NetworkType> result;
    switch (requestParams.method) {
      case Web3GlobalRequestMethods.disconnect:
        final disconnect = requestParams.cast<Web3DisconnectApplication>();
        authenticated.disconnectChain(disconnect.chain);
        result = [disconnect.chain];
        break;
      default:
        result = await _getWalletOwnerResult(request);
        break;
    }
    final chains = _appChains.getWeb3NetworkData();
    final auth = authenticated.createAuth(chains, web3Networks: result);
    request.authenticated
        .addActivity(request: request, url: request.info.info.url);
    return Web3GlobalResponseMessage(authenticated: auth);
  }

  List<Chain> _getRequestChains(NetworkType network) {
    if (network.isBitcoin) {
      return _appChains._networks.values
          .where((e) => e.network.type.isBitcoin)
          .toList();
    }
    return _appChains._networks.values
        .where((e) => e.network.type == network)
        .toList();
  }

  Future<Web3MessageCore> _handleChainRequest(
      {required Web3RequestParams requestParams,
      required Web3APPAuthentication authenticated,
      required Web3RequestApplicationInformation walletRequest}) async {
    final request = requestParams.toRequest(
        request: walletRequest,
        chains: _getRequestChains(requestParams.method.network),
        authenticated: authenticated);
    request.verifyPermission();
    final Object? result = await _getWalletOwnerResult(request);
    request.authenticated
        .addActivity(request: request, url: request.info.info.url);

    final walletResponse = request.params.toJsWalletResponse(result);
    Web3APPData? auth;
    if (request.params.method.reloadAuthenticated) {
      final chains = _appChains.getWeb3NetworkData();
      auth = authenticated
          .createAuth(chains, web3Networks: [request.chain.network.type]);
    }
    return Web3WalletResponseMessage(
        result: walletResponse,
        authenticated: auth,
        network: request.params.method.network);
  }

  Future<Web3EncryptedMessage> _web3Request(
      Web3RequestApplicationInformation walletRequest) async {
    final authenticated =
        await _getOrCreateAppAuthenticated(walletRequest.info);
    Web3MessageCore requestParams;
    try {
      final Web3EncryptedMessage encryotedMessage =
          Web3EncryptedMessage.deserialize(bytes: walletRequest.request.data);
      final CryptoDecryptChachaResponse decrypt =
          await crypto.cryptoMainRequest(CryptoRequestDecryptChacha(
              key: authenticated.token,
              nonce: encryotedMessage.nonce,
              message: encryotedMessage.message));
      requestParams = Web3MessageCore.deserialize(bytes: decrypt.decrypted);
    } catch (_) {
      throw Web3RequestExceptionConst.invalidRequest;
    }
    Web3MessageCore response;
    try {
      if (!authenticated.active) {
        throw Web3RequestExceptionConst.bannedHost;
      }
      switch (requestParams.type) {
        case Web3MessageTypes.walletRequest:
          response = await _handleChainRequest(
              authenticated: authenticated,
              requestParams: requestParams.cast<Web3RequestParams>(),
              walletRequest: walletRequest);

          break;
        case Web3MessageTypes.walletGlobalRequest:
          response = await _handleGlobalRequest(
              requestParams: requestParams.cast<Web3GlobalRequestParams>(),
              authenticated: authenticated,
              walletRequest: walletRequest);
          break;
        default:
          throw Web3RequestExceptionConst.invalidRequest;
      }
    } on Web3RejectException catch (_) {
      rethrow;
    } on Web3RequestException catch (e) {
      Web3APPData? auth;
      switch (e) {
        case Web3RequestExceptionConst.missingPermission:
        case Web3RequestExceptionConst.bannedHost:
        case Web3RequestExceptionConst.invalidNetwork:
        case Web3RequestExceptionConst.internalError:
          auth = authenticated.createAuth(_appChains.getWeb3NetworkData());
          break;
        default:
      }
      response = e.toResponseMessage(
          requestId: walletRequest.request.requestId, authenticated: auth);
    } catch (e) {
      const exception = Web3RequestExceptionConst.internalError;
      response = exception.toResponseMessage(
          requestId: walletRequest.request.requestId,
          authenticated:
              authenticated.createAuth(_appChains.getWeb3NetworkData()));
    } finally {
      try {
        await _core._savePermission(wallet: _wallet, permission: authenticated);
      } catch (e) {}
    }
    final CryptoEncryptChachaResponse encryptResponse =
        await crypto.cryptoMainRequest(CryptoRequestEncryptChacha(
            key: authenticated.token, message: response.toCbor().encode()));
    return Web3EncryptedMessage(
        message: encryptResponse.encrypted, nonce: encryptResponse.nonce);
  }

  Future<Web3EncryptedMessage> _updateWeb3Application(
      Web3APPAuthentication application,
      {List<NetworkType>? web3Networks}) async {
    await _core._savePermission(wallet: _wallet, permission: application);
    final message = Web3ChainMessage(
        type: Web3MessageTypes.chains,
        authenticated: application.createAuth(_appChains.getWeb3NetworkData(),
            web3Networks: web3Networks));
    final CryptoEncryptChachaResponse encryptResponse =
        await crypto.cryptoMainRequest(CryptoRequestEncryptChacha(
            key: application.token, message: message.toCbor().encode()));
    return Web3EncryptedMessage(
        message: encryptResponse.encrypted, nonce: encryptResponse.nonce);
  }
}
