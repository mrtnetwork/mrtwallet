import 'package:mrt_wallet/app/utils/list/extension.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/validator/live.dart';
import 'package:mrt_wallet/future/wallet/network/forms/ton/forms/core/ton.dart';
import 'package:mrt_wallet/wallet/api/client/client.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/models/networks/ton/ton.dart';
import 'package:mrt_wallet/wallet/web3/networks/ton/ton.dart';
import 'package:ton_dart/ton_dart.dart';

class Web3TonSendTransactionForm extends TonWeb3Form<Web3TonSendTransaction> {
  @override
  OnChangeForm? onChanged;
  Web3TonSendTransactionForm({required this.request});
  late final List<TonWeb3TransactionMessageInfo> _messages;
  late final TonClient _client;
  late final VersionedWalletContract wallet;
  late final int _validUntil;
  late final TonAccountContext _accountContext;

  int? _seqno;
  int get seqno => _seqno!;
  List<TonWeb3TransactionMessageInfo> get messages => _messages;

  BigInt get totalTon {
    return messages.fold(
        BigInt.zero,
        (p, c) =>
            p + (c.amount.balance + (c.payload?.tonAmount ?? BigInt.zero)));
  }

  void init(
      {required List<TonWeb3TransactionMessageInfo> messages,
      required TonClient client,
      required ITonAddress owner,
      required int validUntil}) {
    _messages = messages.imutable;
    _client = client;
    wallet = owner.toWalletContract();
    _validUntil = validUntil;
    _accountContext = owner.context;
  }

  Future<Cell> createMessageBody() async {
    _seqno ??= await wallet.getSeqno(_client.provider);
    final actions = _messages
        .map((e) => OutActionSendMsg(outMessage: e.toMessage()))
        .toList();
    return _accountContext.buildTransaction(
        actions: actions,
        state: wallet.state!,
        seqno: _seqno!,
        chain: wallet.chain,
        timeOut: _validUntil);
  }

  Future<Message> createEstimateMessage() async {
    final fakeSignature = List<int>.unmodifiable(List<int>.filled(64, 0));
    final messageBody = await createMessageBody();
    return _accountContext.toExternalMessage(
        message: messageBody,
        signature: fakeSignature,
        destination: wallet.address,
        state: (seqno == 0 ? wallet.state!.initialState() : null));
  }

  @override
  Web3TonRequest<Web3TonSendTransactionResponse, Web3TonSendTransaction>
      request;
}
