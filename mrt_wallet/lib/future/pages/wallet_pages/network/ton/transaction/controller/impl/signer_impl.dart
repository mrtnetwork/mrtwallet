import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/ton/transaction/controller/impl/transaction_impl.dart';
import 'package:mrt_wallet/future/widgets/progress_bar/progress.dart';
import 'package:mrt_wallet/models/wallet_models/signing_request/signing_reguest.dart';
import 'package:ton_dart/ton_dart.dart';

mixin TonSignerImpl on TonTransactionImpl {
  int? _seqno;

  Cell _buildMessage({required WalletContract wallet, required int seqno}) {
    final messages = validator.validator.toMessages(address.networkAddress);
    return wallet.createTransfer(messages: messages, accountSeqno: seqno);
  }

  Future<Cell> _buildBody(
      {required int seqno,
      required WalletContract wallet,
      bool fakeSignature = false}) async {
    final transfer = _buildMessage(wallet: wallet, seqno: seqno);
    List<int> sig;
    if (fakeSignature) {
      sig = List<int>.unmodifiable(List<int>.filled(64, 0));
    } else {
      final signature = await walletProvider.signTransaction(
          request: TonSigningRequest(
              addresses: [address], network: network, digest: transfer.hash()));
      sig = signature.result;
    }
    return beginCell()
        .storeBuffer(sig)
        .storeSlice(transfer.beginParse())
        .endCell();
  }

  @override
  Future<Message> buildTransaction({bool fakeSignature = false}) async {
    final wallet = address.toWalletContract();
    _seqno ??= await wallet.getSeqno(apiProvider.provider);
    final body = await _buildBody(
        seqno: _seqno!, wallet: wallet, fakeSignature: fakeSignature);
    return Message(
        init: (_seqno == 0 ? wallet.state : null),
        info: CommonMessageInfoExternalIn(
            dest: wallet.address, importFee: BigInt.zero),
        body: body);
  }

  Future<void> signAndSendTransaction() async {
    progressKey.progressText(
        "create_send_transaction".tr.replaceOne(network.coinParam.token.name));
    final result = await MethodCaller.call(() async {
      final exMessage = await buildTransaction();

      return await apiProvider.sendMessage(exMessage);
    });
    if (result.hasError) {
      progressKey.errorText(result.error!.tr);
    } else {
      progressKey.success(
          progressWidget: SuccessTransactionTextView(
            network: network,
            txId: result.result.toString(),
          ),
          backToIdle: false);
    }
  }
}
