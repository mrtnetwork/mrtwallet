part of 'package:mrt_wallet/wallet/provider/wallet_provider.dart';

mixin Web3Impl
    on
        WalletManager,
        Web3EthereumImpl,
        Web3TonImpl,
        Web3SubstrateImpl,
        Web3StellarImpl,
        Web3SolanaImpl,
        Web3TronImpl {
  Chain _getWeb3ChainId(
      {required Web3RequestParams param,
      required Web3APPAuthentication authenticated}) {
    switch (param.method.network) {
      case NetworkType.ethereum:
        final web3Chain = authenticated
            .getChainFromNetworkType<Web3EthereumChain>(param.method.network);
        if (web3Chain == null) {
          throw Web3RequestExceptionConst.bannedHost;
        }
        final chains =
            _appChains._networks.values.whereType<EthereumChain>().toList();
        return web3Chain.getCurrentPermissionChain(chains);
      case NetworkType.tron:
        final web3Chain = authenticated
            .getChainFromNetworkType<Web3TronChain>(param.method.network);
        if (web3Chain == null) {
          throw Web3RequestExceptionConst.bannedHost;
        }
        final chains =
            _appChains._networks.values.whereType<TronChain>().toList();
        return web3Chain.getCurrentPermissionChain(chains);
      case NetworkType.solana:
        final web3Chain = authenticated
            .getChainFromNetworkType<Web3SolanaChain>(param.method.network);
        if (web3Chain == null) {
          throw Web3RequestExceptionConst.bannedHost;
        }
        final chains =
            _appChains._networks.values.whereType<SolanaChain>().toList();
        return web3Chain.getCurrentPermissionChain(chains);
      case NetworkType.ton:
        final web3Chain = authenticated
            .getChainFromNetworkType<Web3TonChain>(param.method.network);
        if (web3Chain == null) {
          throw Web3RequestExceptionConst.bannedHost;
        }
        final chains = _appChains._networks.values
            .whereType<TheOpenNetworkChain>()
            .toList();
        return web3Chain.getCurrentPermissionChain(chains);
      case NetworkType.stellar:
        final web3Chain = authenticated
            .getChainFromNetworkType<Web3StellarChain>(param.method.network);
        if (web3Chain == null) {
          throw Web3RequestExceptionConst.missingPermission;
        }
        final chains =
            _appChains._networks.values.whereType<StellarChain>().toList();
        return web3Chain.getCurrentPermissionChain(chains);
      case NetworkType.substrate:
        final web3Chain = authenticated
            .getChainFromNetworkType<Web3SubstrateChain>(param.method.network);
        if (web3Chain == null) {
          throw Web3RequestExceptionConst.missingPermission;
        }
        final chains =
            _appChains._networks.values.whereType<SubstrateChain>().toList();
        return web3Chain.getCurrentPermissionChain(chains);
      default:
        throw Web3RequestExceptionConst.networkNotSupported;
    }
  }

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
      final permission = Web3APPAuthentication(
          name: info.name,
          applicationKey: applicationKey,
          applicationId: info.applicationId,
          icon: info.image,
          token: token);
      await _core._savePermission(permission: permission, wallet: _wallet);
      return permission;
    }

    return toPermission;
  }

  @override
  Future<dynamic> _getWalletOwnerResult(Web3Request request) async {
    final push = _core.onWeb3Request(request);
    if (!(push)) {
      throw Web3RequestExceptionConst.internalError;
    }
    return await request.getResponse();
  }

  Future<dynamic> _getWeb3Result({required Web3Request request}) async {
    if (request.isPermissionRequest && request.hasAnyPermission) {
      return request.currentPermission!;
    }
    switch (request.chain.network.type) {
      case NetworkType.ethereum:
        return await _getEthereumWeb3Result(request as Web3EthereumRequest);
      case NetworkType.tron:
        return await _getTronWeb3Result(request as Web3TronRequest);
      case NetworkType.solana:
        return await _getSolanaWeb3Result(request as Web3SolanaRequest);
      case NetworkType.ton:
        return await _getTonWeb3Result(request as Web3TonRequest);
      case NetworkType.stellar:
        return await _getStellarWeb3Result(request as Web3StellarRequest);
      case NetworkType.substrate:
        return await _getSubstrateWeb3Result(request as Web3SubstrateRequest);
      default:
        throw Web3RequestExceptionConst.networkNotSupported;
    }
  }

  Future<Web3MessageCore> _handleGlobalRequest(
      {required Web3GlobalRequestParams requestParams,
      required Web3APPAuthentication authenticated,
      required Web3RequestApplicationInformation walletRequest}) async {
    try {
      switch (requestParams.method) {
        case Web3GlobalRequestMethods.disconnect:
          final disconnect = requestParams.cast<Web3DisconnectApplication>();
          authenticated.disconnectChain(disconnect.chain);
          return Web3WalletResponseMessage(
              result: true,
              authenticated:
                  authenticated.createAuth(_appChains.getWeb3NetworkData()),
              network: disconnect.chain);
        default:
      }
      throw UnimplementedError();
    } finally {
      await _core._savePermission(wallet: _wallet, permission: authenticated);
    }
  }

  Future<Web3MessageCore> _handleChainRequest(
      {required Web3RequestParams requestParams,
      required Web3APPAuthentication authenticated,
      required Web3RequestApplicationInformation walletRequest}) async {
    try {
      final chain =
          _getWeb3ChainId(authenticated: authenticated, param: requestParams);
      final request = requestParams.toRequest(
          request: walletRequest, chain: chain, authenticated: authenticated);
      request.verifyPermission();
      final Object? result = await _getWeb3Result(request: request);
      request.authenticated
          .addActivity(param: request.params, url: request.info.info.url);

      final walletResponse = request.params.toJsWalletResponse(result);
      Web3APPData? auth;
      if (requestParams.isPermissionRequest ||
          request.params.method.reloadAuthenticated) {
        auth = authenticated.createAuth(_appChains.getWeb3NetworkData(),
            web3Networks: [request.chain.network.type]);
      }
      return Web3WalletResponseMessage(
          result: walletResponse,
          authenticated: auth,
          network: chain.network.type);
    } finally {
      await _core._savePermission(wallet: _wallet, permission: authenticated);
    }
  }

  Future<Web3EncryptedMessage> _web3Request(
      Web3RequestApplicationInformation walletRequest) async {
    final authenticated =
        await _getOrCreateAppAuthenticated(walletRequest.info);
    if (!authenticated.active) {
      throw Web3RequestExceptionConst.bannedHost;
    }
    final Web3EncryptedMessage encryotedMessage =
        Web3EncryptedMessage.deserialize(bytes: walletRequest.request.data);
    final CryptoDecryptChachaResponse decrypt = await crypto
        .cryptoMainRequest(CryptoRequestDecryptChacha(
            key: authenticated.token,
            nonce: encryotedMessage.nonce,
            message: encryotedMessage.message))
        .catchError((e) {
      throw Web3RequestExceptionConst.invalidRequest;
    });
    Web3MessageCore response;
    try {
      final requestParams =
          Web3MessageCore.deserialize(bytes: decrypt.decrypted);
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
    } on Web3RejectException {
      rethrow;
    } on Web3RequestException catch (e) {
      Web3APPData? auth;
      switch (e) {
        case Web3RequestExceptionConst.missingPermission:
        case Web3RequestExceptionConst.invalidNetwork:
          auth = authenticated.createAuth(_appChains.getWeb3NetworkData());
          break;
        default:
      }
      response = e.toResponseMessage(
          requestId: walletRequest.request.requestId, authenticated: auth);
    } catch (e) {
      const exception = Web3RequestExceptionConst.internalError;
      response = exception.toResponseMessage(
          requestId: walletRequest.request.requestId);
    }
    final CryptoEncryptChachaResponse encryptResponse =
        await crypto.cryptoMainRequest(CryptoRequestEncryptChacha(
            key: authenticated.token, message: response.toCbor().encode()));
    return Web3EncryptedMessage(
        message: encryptResponse.encrypted, nonce: encryptResponse.nonce);
  }

  Future<Web3EncryptedMessage> _updateWeb3Application(
      Web3APPAuthentication application) async {
    await _core._savePermission(wallet: _wallet, permission: application);
    final message = Web3ChainMessage(
        type: Web3MessageTypes.chains,
        authenticated: application.createAuth(_appChains.getWeb3NetworkData()));
    final CryptoEncryptChachaResponse encryptResponse =
        await crypto.cryptoMainRequest(CryptoRequestEncryptChacha(
            key: application.token, message: message.toCbor().encode()));
    return Web3EncryptedMessage(
        message: encryptResponse.encrypted, nonce: encryptResponse.nonce);
  }
}
