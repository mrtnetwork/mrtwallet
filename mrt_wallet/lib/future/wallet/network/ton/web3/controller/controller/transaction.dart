import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/app/utils/method/utiils.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'package:mrt_wallet/crypto/requets/messages/messages.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';
import 'package:mrt_wallet/future/wallet/network/forms/ton/ton.dart';
import 'package:mrt_wallet/future/wallet/network/ton/transaction/controller/impl/fee_impl.dart';
import 'package:mrt_wallet/future/wallet/network/ton/web3/controller/impl/impl.dart';
import 'package:mrt_wallet/future/wallet/web3/pages/page_progress.dart';
import 'package:mrt_wallet/wallet/models/balance/integer/integer.dart';
import 'package:mrt_wallet/wallet/models/networks/ton/ton.dart';
import 'package:mrt_wallet/wallet/models/signing/signing.dart';
import 'package:mrt_wallet/wallet/web3/networks/ton/params/models/transaction.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';
import 'package:ton_dart/ton_dart.dart';

class Web3TonTransactionRequestController
    extends Web3TonImpl<Web3TonSendTransactionResponse, Web3TonSendTransaction>
    with TonFeeImpl {
  Web3TonTransactionRequestController({
    required super.walletProvider,
    required super.request,
  }) : super(account: request.chain);

  @override
  Web3TonSendTransactionForm get form =>
      liveRequest.validator as Web3TonSendTransactionForm;

  late final IntegerBalance total = IntegerBalance.zero(network.coinDecimal);
  late final IntegerBalance remindAmount =
      IntegerBalance.zero(network.coinParam.decimal);

  Future<void> _init() async {
    progressKey.process(text: "transaction_retrieval_requirment".tr);
    final result = await MethodUtils.call(() async {
      List<TonWeb3TransactionMessageInfo> messages = [];
      for (final i in request.params.messages) {
        final msgInfo = await apiProvider.getWeb3TransactionMessageInfo(
            address: address, account: account, message: i);
        messages.add(msgInfo);
      }
      return messages;
    });
    if (result.hasError) {
      progressKey.error(backToIdle: null, text: result.error!.tr);
      return;
    }
    form.init(
        messages: result.result,
        client: apiProvider,
        owner: address,
        validUntil: request.params.validUntil);
    onChange();
    estimateFee();
    progressKey.idle();
  }

  Future<void> sendTransaction() async {
    progressKey.process(
        text: "create_send_transaction"
            .tr
            .replaceOne(network.coinParam.token.name));

    final externalMessage = await MethodUtils.call(() async {
      final messageBody = await form.createMessageBody();
      final signature = await walletProvider.wallet.signTransaction(
          request: WalletSigningRequest(
        addresses: [address],
        network: network,
        sign: (generateSignature) async {
          final signRequest = GlobalSignRequest.ton(
              digest: messageBody.hash(),
              index: address.keyIndex as Bip32AddressIndex);
          final response = await generateSignature(signRequest);
          return response.signature;
        },
      ));
      final extMessage = address.context.toExternalMessage(
          message: messageBody,
          signature: signature.result,
          destination: address.networkAddress,
          state: (form.seqno == 0 ? form.wallet.state!.initialState() : null));
      return beginCell().store(extMessage).endCell();
    });

    if (externalMessage.hasError) {
      progressKey.error(text: externalMessage.error!.tr);
      return;
    }
    final result = await MethodUtils.call(
        () async => await apiProvider.sendMessage(boc: externalMessage.result));
    if (result.hasError) {
      progressKey.error(text: result.error!.tr, backToIdle: null);
      request.error(Web3RequestExceptionConst.fromException(result.exception!));
      return;
    }
    final String txHash = result.result;
    final response = Web3TonSendTransactionResponse(
        boc: externalMessage.result.toBase64(), txHash: txHash);
    request.completeResponse(response);
    progressKey.responseTx(hash: txHash, network: network);
  }

  @override
  Future<Message> buildTransaction({bool fakeSignature = false}) {
    return form.createEstimateMessage();
  }

  @override
  void onChange() {
    total.updateBalance(form.totalTon);
    final remind = address.address.currencyBalance - (form.totalTon + fee);
    remindAmount.updateBalance(remind);
    notify();
  }

  @override
  Future<void> readyWeb3() async {
    await super.readyWeb3();
    _init();
  }
}
