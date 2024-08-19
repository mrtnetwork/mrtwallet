import 'package:blockchain_utils/exception/exceptions.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/utils/method/utiils.dart';
import 'package:mrt_wallet/wallet/api/client/core/client.dart';
import 'package:mrt_wallet/wallet/api/client/networks/ripple/methods/methods.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/ripple.dart';
import 'package:mrt_wallet/wallet/api/services/service.dart';
import 'package:mrt_wallet/wallet/models/chain/address/address.dart';
import 'package:mrt_wallet/wallet/models/networks/ripple/models/account_object_signer_list.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:xrpl_dart/xrpl_dart.dart';

class _RippleApiProviderConst {
  static const int accountNotFound = 19;
}

class RippleClient extends NetworkClient<IXRPAddress, RippleAPIProvider> {
  RippleClient({required this.provider, required this.network});
  final XRPLRpc provider;
  @override
  final WalletXRPNetwork network;

  @override
  BaseServiceProtocol<RippleAPIProvider> get service =>
      provider.rpc as BaseServiceProtocol<RippleAPIProvider>;

  @override
  Future<void> updateBalance(IXRPAddress account) async {
    final accountInfo = await getAccountInfo(account.address.toAddress);
    if (accountInfo == null) return;
    account.address
        .updateBalance(BigInt.parse(accountInfo.accountData.balance));
    await updateTokens(account);
  }

  Future<void> updateTokens(IXRPAddress address) async {
    if (address.tokens.isNotEmpty) {
      final accountTokens = await provider
          .request(XRPRPCFetchTokens(account: address.address.toAddress));
      for (final i in address.tokens) {
        try {
          final currentUpdate =
              accountTokens.firstWhere((element) => element.issuer == i.issuer);
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
      return await provider.request(RPCAccountInfo(account: address));
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

  @override
  Future<bool> onInit() async {
    final result = await MethodUtils.call(() async {
      return await provider.request(RPCServerState());
    });
    return result.hasResult;
  }
}
