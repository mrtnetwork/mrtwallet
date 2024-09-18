import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/network/ton/transaction/controller/impl/transaction_impl.dart';
import 'package:mrt_wallet/future/widgets/widgets/progress_bar/widgets/progress.dart';
import 'package:mrt_wallet/wallet/models/signing/signing.dart';
import 'package:mrt_wallet/crypto/derivation/derivation/bip32.dart';
import 'package:mrt_wallet/crypto/requets/messages/models/models/signing.dart';
import 'package:ton_dart/ton_dart.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

mixin TonSignerImpl on TonTransactionImpl {
  int? _seqno;

  @override
  Future<Message> buildTransaction({bool fakeSignature = false}) async {
    final wallet = address.toWalletContract();
    _seqno ??= await wallet.getSeqno(apiProvider.provider);
    final actions = validator.validator
        .toMessages(address.networkAddress)
        .map((e) => OutActionSendMsg(outMessage: e))
        .toList();
    if (wallet.type.version == 1 && actions.length > 1) {
      throw WalletException("ton_wallet_validator_desc");
    }
    final transfer = address.context.buildTransaction(
        actions: actions,
        state: wallet.state!,
        seqno: _seqno!,
        chain: network.coinParam.chainType);
    List<int> sig = List<int>.unmodifiable(List<int>.filled(64, 0));

    if (!fakeSignature) {
      final signature = await walletProvider.wallet.signTransaction(
          request: WalletSigningRequest(
        addresses: [address],
        network: network,
        sign: (generateSignature) async {
          final signRequest = GlobalSignRequest.ton(
              digest: transfer.hash(),
              index: address.keyIndex as Bip32AddressIndex);
          final response = await generateSignature(signRequest);
          return response.signature;
        },
      ));
      sig = signature.result;
    }
    return address.context.toExternalMessage(
        message: transfer,
        signature: sig,
        destination: address.networkAddress,
        state: (_seqno == 0 ? wallet.state!.initialState() : null));
  }

  Future<void> signAndSendTransaction() async {
    progressKey.progressText(
        "create_send_transaction".tr.replaceOne(network.coinParam.token.name));
    final result = await MethodUtils.call(() async {
      final exMessage = await buildTransaction();

      return await apiProvider.sendMessage(
          boc: beginCell().store(exMessage).endCell());
    });
    if (result.hasError) {
      progressKey.errorText(result.error!.tr,
          backToIdle: false, showBackButton: true);
    } else {
      progressKey.success(
          progressWidget: SuccessTransactionTextView(
            network: network,
            txId: [result.result.toString()],
          ),
          backToIdle: false);
    }
  }
}
