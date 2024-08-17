import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:mrt_wallet/future/wallet/network/bch/transaction/cotnroller/bitcoin_operation.dart';
import 'package:mrt_wallet/future/wallet/network/bitcoin/controller/impl/fee_impl.dart';
import 'package:mrt_wallet/future/wallet/network/bitcoin/controller/impl/transaction.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/app/models/models/typedef.dart';

typedef OnTapBitcoinCashOperation
    = Future<BitcoinCashTransactionTokenOperation?> Function(
        BitcoinCashTransactionTokenOperation);
typedef OnTapBuildNewToken = Future<CreateCashTokenInfo?> Function(
    List<BitcoinUtxoWithBalance> utxos);

class BitcoinCashStateController extends BitcoinTransactionImpl
    with BitcoinTransactionFeeImpl {
  BitcoinCashStateController(
      {required super.chainAccount, required super.walletProvider});

  @override
  WalletBitcoinNetwork get network =>
      chainAccount.network as WalletBitcoinCashNetwork;

  bool _trReady = false;
  bool get trReady => _trReady;
  bool _includeTokenUtxos = false;
  bool get includeTokenUtxos => _includeTokenUtxos;
  List<BitcoinCashTransactionTokenOperation> _tokenOperation = [];
  List<BitcoinCashTransactionTokenOperation> get tokenOperation =>
      _tokenOperation;
  final List<CreateCashTokenInfo> _buildedTokens = [];
  List<CreateCashTokenInfo> get buildedTokens => _buildedTokens;

  void onRemoveBuildedToken(CreateCashTokenInfo token) {
    final re = _buildedTokens.remove(token);
    if (!re) return;
    final operations =
        List<BitcoinCashTransactionTokenOperation>.from(_tokenOperation);
    operations.removeWhere((element) =>
        element.cashToken.cashToken.category == token.token.cashToken.category);
    _tokenOperation =
        List<BitcoinCashTransactionTokenOperation>.unmodifiable(operations);
    onRemoveMemo(token.bcmr);
    buildOutputs();
    calculateFee();
  }

  void onBuildToken(
      OnTapBuildNewToken onBuildToken, DynamicVoid onEmptyVout0) async {
    final List<BitcoinUtxoWithBalance> zeroUtxos = selectedUtxo
        .where((e) =>
            e.utxo.vout == 0 &&
            !_buildedTokens.any(
                (element) => element.token.cashToken.category == e.utxo.txHash))
        .toList();
    if (zeroUtxos.isEmpty) {
      onEmptyVout0();
      return;
    }
    final token = await onBuildToken(zeroUtxos);
    if (token == null) return;
    _buildedTokens.add(token);
    _tokenOperation = List.unmodifiable([
      ..._tokenOperation,
      BitcoinCashTransactionTokenOperation(
          cashToken: token.token.cashToken,
          utxoHash: token.token.cashToken.category)
    ]);

    if (token.bcmr != null) {
      addBCMR(token.bcmr!);
      buildOutputs();
      calculateFee();
      return;
    }

    notify();
  }

  @override
  void buildOutputs([List<BitcoinBaseOutput> extraOutputs = const []]) {
    final List<BitcoinBaseOutput> out = [];
    for (final i in _tokenOperation) {
      if (i.isComplete) {
        out.addAll(i.outputs());
      }
    }
    super.buildOutputs(out);
  }

  void toggleTokenUtxos() {
    _includeTokenUtxos = !_includeTokenUtxos;
    notify();
  }

  void onUpdateOperations(BitcoinCashTransactionTokenOperation operation,
      OnTapBitcoinCashOperation onUpdate) async {
    int index = _tokenOperation.indexOf(operation);
    if (index < 0) return;
    final update = await onUpdate(operation);
    if (update == null) return;
    final updateOperatopm =
        List<BitcoinCashTransactionTokenOperation>.from(_tokenOperation);
    updateOperatopm[index] = update;
    _tokenOperation = updateOperatopm;
    onCalculateAmount();
    calculateFee();
    notify();
  }

  @override
  void onSetupUtxo() {
    _tokenOperation = [];
    final sum = selectedUtxo.fold(BigInt.zero,
        (previousValue, element) => previousValue + element.balance.balance);
    sumOfSelectedUtxo.updateBalance(sum);
    if (sum <= BigInt.zero) return;
    List<(CashToken, String)> cashTokens = selectedUtxo
        .where((element) => element.utxo.token != null)
        .map((e) => (e.utxo.token, e.utxo.txHash))
        .toList()
        .cast();
    if (cashTokens.isNotEmpty) {
      final List<BitcoinCashTransactionTokenOperation> nftTokens = cashTokens
          .where((element) => element.$1.hasNFT)
          .map((e) => BitcoinCashTransactionTokenOperation(
              cashToken: e.$1, utxoHash: e.$2))
          .toList();
      List<CashToken> tokens = cashTokens
          .map((e) => e.$1)
          .where((element) => !element.hasNFT)
          .toList();
      final Map<String, CashToken> ftTokens = {};
      for (final i in tokens) {
        if (ftTokens.containsKey(i.category)) {
          final amount = ftTokens[i.category]!.amount + i.amount;
          ftTokens[i.category] = i.copyWith(amount: amount);
        } else {
          ftTokens[i.category] = i;
        }
      }
      nftTokens.addAll(ftTokens.values.map((e) =>
          BitcoinCashTransactionTokenOperation(cashToken: e, utxoHash: null)));
      _tokenOperation =
          List<BitcoinCashTransactionTokenOperation>.unmodifiable(nftTokens);
    }
    buildInputs();
    onCalculateAmount();
    calculateFee();
  }

  @override
  void fetchUtxos([bool includeTokenUtxos = false]) {
    super.fetchUtxos(_includeTokenUtxos);
  }

  @override
  void onCalculateAmount() {
    BigInt totalAmount = receivers.fold(BigInt.zero,
        (previousValue, element) => previousValue + element.balance.balance);
    totalAmount += _tokenOperation.fold(
        BigInt.zero,
        (previousValue, element) =>
            previousValue + (element.totalAmount.balance));
    setupAmount.updateBalance(totalAmount);
    final remind =
        sumOfSelectedUtxo.balance - totalAmount - transactionFee.balance;
    remindAmount.updateBalance(remind);
    buildOutputs();
    _trReady = _isReady();
  }

  bool _isReady() {
    final zeroOutput = receivers.isEmpty
        ? false
        : receivers.any((element) => !element.hasAmount);
    final operationIsReady =
        _tokenOperation.any((element) => !element.isComplete);
    return (receivers.isNotEmpty || _tokenOperation.isNotEmpty) &&
        !zeroOutput &&
        !operationIsReady &&
        !remindAmount.isNegative &&
        (!setupAmount.isZero);
  }

  @override
  void sendTransaction() {
    if (!trReady) return;
    super.sendTransaction();
  }
}
