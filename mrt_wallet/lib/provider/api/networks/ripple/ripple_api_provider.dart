import 'package:blockchain_utils/exception/exceptions.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/models/api/api_provider_tracker.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/provider/api/api_provider.dart';

import 'package:xrpl_dart/xrpl_dart.dart';

class _RippleApiProviderConst {
  static const int accountNotFound = 19;
}

class RippleApiProvider implements NetworkApiProvider<IXRPAddress> {
  RippleApiProvider({required this.provider, required this.network});
  final XRPLRpc provider;
  @override
  final AppXRPNetwork network;
  @override
  ApiProviderTracker get serviceProvider =>
      (provider.rpc as BaseProviderProtocol).provider;

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
}
