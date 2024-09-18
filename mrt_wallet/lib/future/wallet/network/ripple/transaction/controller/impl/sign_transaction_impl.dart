import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/network/ripple/transaction/controller/impl/transaction_impl.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/crypto/utils/ripple/ripple.dart';
import 'package:xrpl_dart/xrpl_dart.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

mixin RippleSignTransactionImpl on RippleTransactionImpl {
  Future<void> signAndSendTransaction(
      WalletSigningRequest<XRPTransaction> request,
      XRPTransaction transaction) async {
    progressKey.progressText(
        "create_send_transaction".tr.replaceOne(network.coinParam.token.name));
    final result = await MethodUtils.call(() async {
      await XRPHelper.autoFill(apiProvider.provider, transaction,
          calculateFee: false);
      final signature =
          await walletProvider.wallet.signTransaction(request: request);
      if (signature.hasError) {
        throw signature.exception!;
      }
      final trBlob = signature.result.toBlob(forSigning: false);
      final send =
          await apiProvider.provider.request(RPCSubmitOnly(txBlob: trBlob));
      return send;
    });
    if (result.hasError) {
      progressKey.errorText(result.error!.tr,
          showBackButton: true, backToIdle: false);
    } else {
      if (!result.result.isSuccess) {
        progressKey.errorText(result.result.engineResultMessage,
            backToIdle: false, showBackButton: true);
      } else {
        progressKey.success(
            progressWidget: SuccessTransactionTextView(
              network: network,
              txId: [result.result.txJson.hash],
            ),
            backToIdle: false);
      }
    }
  }

  Future<bool?> canSignTransaction() async {
    final info =
        await apiProvider.getAccountInfo(address.networkAddress.toString());
    if (info == null) return null;
    final String? regularKey = info.accountData.regularKey;
    if (info.accountFlags.disableMasterKey) {
      if (!address.multiSigAccount) return false;
      return _checkMultiSigAccsess(regularKey);
    } else {
      if (address.multiSigAccount) return _checkMultiSigAccsess(regularKey);
      return true;
    }
  }

  Future<bool> _checkMultiSigAccsess(String? regularKey) async {
    final multiSignatureAccount =
        (address as IXRPMultisigAddress).multiSignatureAccount;
    if (multiSignatureAccount.isRegular) {
      final multisigRegularAddress = RippleUtils.strPublicKeyToRippleAddress(
          multiSignatureAccount.signers.first.publicKey);
      return multisigRegularAddress.address == regularKey;
    } else {
      final accountSigners = await apiProvider
          .getAccountSignerList(address.networkAddress.address);
      if (accountSigners?.signerEntries.isEmpty ?? true) return false;
      int threshHold = 0;
      final List<String> addressSigners = multiSignatureAccount.signers
          .map((e) =>
              RippleUtils.strPublicKeyToRippleAddress(e.publicKey).address)
          .toList();
      for (final i in addressSigners) {
        final inSignerList = MethodUtils.nullOnException(() => accountSigners!
            .signerEntries
            .firstWhere((element) => element.account == i));
        if (inSignerList == null) continue;
        threshHold += inSignerList.signerWeight;
      }
      return threshHold >= multiSignatureAccount.threshold;
    }
  }
}
