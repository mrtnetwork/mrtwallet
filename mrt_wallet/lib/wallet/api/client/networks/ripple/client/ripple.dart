import 'package:blockchain_utils/exception/exceptions.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/api/client/core/client.dart';
import 'package:mrt_wallet/wallet/api/client/networks/ripple/methods/methods.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/ripple.dart';
import 'package:mrt_wallet/wallet/api/services/service.dart';
import 'package:mrt_wallet/wallet/models/chain/address/address.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/models/networks/ripple/models/account_object_signer_list.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:mrt_wallet/wallet/models/token/token.dart';
import 'package:xrpl_dart/xrpl_dart.dart';

class _RippleApiProviderConst {
  static const int accountNotFound = 19;
}

class RippleClient extends NetworkClient<IXRPAddress, RippleAPIProvider> {
  RippleClient({required this.provider, required this.network});
  final XRPProvider provider;
  @override
  final WalletXRPNetwork network;

  @override
  BaseServiceProtocol<RippleAPIProvider> get service =>
      provider.rpc as BaseServiceProtocol<RippleAPIProvider>;

  @override
  Future<void> updateBalance(
      IXRPAddress address, APPCHAINACCOUNT<IXRPAddress> chain) async {
    final accountInfo = await getAccountInfo(address.address.toAddress);
    if (accountInfo == null) return;
    chain.updateAddressBalance(
        address: address,
        updateBalance: BigintUtils.tryParse(accountInfo.accountData.balance));
    await updateTokens(address);
  }

  Future<void> updateTokens(IXRPAddress address) async {
    if (address.tokens.isNotEmpty) {
      final accountTokens = await provider
          .request(XRPRPCFetchTokens(account: address.address.toAddress));
      for (final i in address.tokens) {
        try {
          final currentUpdate = accountTokens
              .firstWhere((element) => element.issuer.address == i.issuer);
          i.updateBalance(BigRational.parseDecimal(currentUpdate.balance));
        } on StateError {
          i.updateBalance(BigRational.zero);
          continue;
        }
      }
    }
  }

  Future<XRPAccountObjectEntry?> getAccountSignerList(String address) async {
    try {
      return await provider
          .request(XRPRPCSignerAccountObject(account: address));
    } on RPCError catch (e) {
      if (e.errorCode == _RippleApiProviderConst.accountNotFound) {
        return null;
      }
      rethrow;
    }
  }

  Future<AccountInfo?> getAccountInfo(String address) async {
    try {
      return await provider.request(XRPRequestAccountInfo(account: address));
    } on RPCError catch (e) {
      if (e.errorCode == _RippleApiProviderConst.accountNotFound) {
        return null;
      }
      rethrow;
    }
  }

  Future<(String?, XRPAccountObjectEntry?)?> getAccountRegularAndSignerList(
      String address) async {
    final account = await getAccountInfo(address);
    if (account == null) return null;
    final signers = await getAccountSignerList(address);
    if (signers == null && account.accountData.regularKey == null) {
      return null;
    }
    final signerObject =
        (signers?.signerEntries.isEmpty ?? true) ? null : signers!;
    return (account.accountData.regularKey, signerObject);
  }

  Future<List<RippleIssueToken>> accountTokens(IXRPAddress address) async {
    final tokens = await provider
        .request(XRPRPCFetchTokens(account: address.address.toAddress));
    return tokens
        .map((e) => RippleIssueToken.create(
            balance: e.balance,
            token: Token(name: e.symbol, symbol: e.symbol),
            issuer: e.issuer.address))
        .toList();
  }

  Future<ServerInfo> getServerInfo() async {
    return await provider.request(XRPRequestServerInfo());
  }

  @override
  Future<bool> onInit() async {
    final result = await MethodUtils.call(() async {
      return getServerInfo();
    });
    return result.hasResult &&
        result.result.info.networkId == network.coinParam.networkId;
  }
}
