import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/network/forms/bitcoin/forms/core/bitcoin.dart';
import 'package:mrt_wallet/wallet/models/models.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant.dart';
import 'package:mrt_wallet/wallet/web3/networks/bitcoin/bitcoin.dart';

class Web3BitcoinSignTransactionForm
    extends BitcoinWeb3Form<Web3BitcoinSignTransaction> {
  Web3BitcoinSignTransactionForm({required this.request});
  @override
  Web3BitcoinRequest<String, Web3BitcoinSignTransaction> request;

  List<BitcoinPsbtInputWithAccount> _inputs = [];
  List<BitcoinPsbtInputWithAccount> get inputs => _inputs;
  List<BitcoinPsbtInputWithAccount> _accountInputs = [];
  List<BitcoinPsbtInputWithAccount> get accountInputs => _accountInputs;
  BasedUtxoNetwork get utxoNetwork => network.coinParam.transacationNetwork;
  List<PsbtBitcoinOutputWithBalance> _outputs = [];
  List<PsbtBitcoinOutputWithBalance> get outputs => _outputs;
  Psbt get psbt => request.params.psbt;
  late IntegerBalance _totalOutput = IntegerBalance.zero(network.coinDecimal);
  IntegerBalance get totalOutput => _totalOutput;
  late IntegerBalance _totalInput = IntegerBalance.zero(network.coinDecimal);
  IntegerBalance get totalInput => _totalInput;
  late IntegerBalance _totalAccountInput =
      IntegerBalance.zero(network.coinDecimal);
  IntegerBalance get totalAccountInput => _totalAccountInput;

  late IntegerBalance _fee = IntegerBalance.zero(network.coinDecimal);
  IntegerBalance get fee => _fee;
  late PsbtBuilder _builder;
  PsbtBuilder get builder => _builder;

  ReceiptAddress<BitcoinBaseAddress>? _getReceiptAddress(
      BitcoinBaseAddress? address) {
    if (address == null) return null;
    final addressStr = address.toAddress(utxoNetwork);
    return account.getReceiptAddress(addressStr) ??
        ReceiptAddress(view: addressStr, networkAddress: address);
  }

  int _getInputSigHash(int? sighash, BitcoinBaseAddress address) {
    if (sighash != null) return sighash;
    switch (utxoNetwork) {
      case BitcoinSVNetwork.mainnet:
      case BitcoinSVNetwork.testnet:
      case BitcoinCashNetwork.testnet:
      case BitcoinCashNetwork.mainnet:
        return BitcoinOpCodeConst.sighashAll | BitcoinOpCodeConst.sighashForked;
      default:
        if (address.type.isP2tr) return BitcoinOpCodeConst.sighashDefault;
        return BitcoinOpCodeConst.sighashAll;
    }
  }

  Future<List<BitcoinPsbtInputWithAccount>> _readUtxos(
      List<BitcoinPsbtInputWithAccount> inputs) async {
    List<BitcoinPsbtInputWithAccount> checkedInputs = [];
    Map<String, List<UtxoWithAddress>> utxos0 = {};
    Map<String, BtcTransaction> txs = {};
    for (final i in inputs) {
      if (i.owner != null) {
        if (!utxos0.containsKey(i.address.view)) {
          final utxos = await client.readUtxos(i.owner!);
          utxos0[i.address.view] = utxos;
        }
        final utxo = utxos0[i.address.view]!.firstWhere(
            (e) =>
                e.utxo.txHash == i.input.txId && e.utxo.vout == i.input.txIndex,
            orElse: () => throw Web3BitcoinExceptionConstant.txInputNotFound(
                i.input.txId, i.input.txIndex));
        checkedInputs.add(i.copyWith(value: utxo.utxo.value));
        continue;
      }
      txs[i.input.txId] ??= await client.getTx(i.input.txId);
      final transaction = txs[i.input.txId]!;

      if (i.input.txIndex >= transaction.outputs.length) {
        throw Web3BitcoinExceptionConstant.txInputNotFound(
            i.input.txId, i.input.txIndex);
      }
      final output = transaction.outputs[i.input.txIndex];
      checkedInputs.add(i.copyWith(value: output.amount));
    }
    return checkedInputs;
  }

  @override
  Future<void> initForm(
      {required BitcoinChain account,
      required IBitcoinAddress? address}) async {
    await super.initForm(account: account, address: address);
    final builder = PsbtBuilder.fromPsbt(psbt);
    final activeAccount = request.currentPermission!.activeAccounts;
    final inputLength = psbt.input.length;
    List<BitcoinPsbtInputWithAccount> inputs = [];
    List<PsbtBitcoinOutputWithBalance> outputs = [];
    // final txType = builder.txType();
    final sighashes =
        PsbtUtils.getAllExistsSighashType(psbt.input, builder.txType());
    for (int i = 0; i < inputLength; i++) {
      final signash = sighashes.firstWhereNullable((e) => e.inputIndex == i);

      final psbtInput = builder.psbtInput(i);
      final psbtAddress = psbtInput.address;
      IBitcoinAddress? address;
      final currentAddress =
          this.account.findAddressFromScript(psbtAddress.toScriptPubKey());
      if (currentAddress != null) {
        address =
            this.account.getAddress(currentAddress.toAddress(utxoNetwork));
      }
      final inputSighash = _getInputSigHash(signash?.sighashType, psbtAddress);
      final account = activeAccount.firstWhereOrNull(
          (e) => e.address.toScriptPubKey() == psbtInput.scriptPubKey);
      if (account != null) {
        if (address == null) {
          throw Web3RequestExceptionConst.missingPermission;
        }
      }
      final inputWithAccount = BitcoinPsbtInputWithAccount(
          owner: address?.toUtxoRequest(),
          input: psbtInput.txInput,
          index: i,
          address: _getReceiptAddress(currentAddress)!,
          sighash: inputSighash,
          ownerAddress: address);
      inputs.add(inputWithAccount);
    }
    if (inputs.isEmpty || inputs.every((e) => e.owner == null)) {
      throw Web3BitcoinExceptionConstant.noRelatedInput;
    }
    inputs = await _readUtxos(inputs);
    final outputLength = psbt.output.length;
    for (int i = 0; i < outputLength; i++) {
      final psbtOutput = builder.psbtOutput(i);
      final currentAddress =
          this.account.findAddressFromScript(psbtOutput.scriptPubKey);
      final output = PsbtBitcoinOutputWithBalance(
        address: _getReceiptAddress(currentAddress ?? psbtOutput.address),
        network: network,
        scriptPubKey: psbtOutput.scriptPubKey,
        balance: psbtOutput.amount,
      );
      outputs.add(output);
    }

    final totalAccountInput = inputs.fold<BigInt>(BigInt.zero, (p, c) {
      if (c.owner == null) return p;
      return p + c.balance.balance;
    });
    final totalInput =
        inputs.fold<BigInt>(BigInt.zero, (p, c) => p + c.balance.balance);
    final totalOutput =
        outputs.fold<BigInt>(BigInt.zero, (p, c) => p + c.balance.balance);
    _inputs = inputs.immutable;
    _outputs = outputs.immutable;
    _accountInputs = inputs.where((e) => e.owner != null).toImutableList;
    _totalAccountInput = IntegerBalance(totalAccountInput, network.coinDecimal,
        allowNegative: false, imutable: true);
    _totalInput = IntegerBalance(totalInput, network.coinDecimal,
        allowNegative: false, imutable: true);
    _totalOutput = IntegerBalance(totalOutput, network.coinDecimal,
        allowNegative: false, imutable: true);
    final fee = totalInput - totalOutput;
    _fee = IntegerBalance(fee, network.coinDecimal,
        allowNegative: true, imutable: true);
    _builder = builder;
  }

  void signTransaction() {
    onCompleteForm?.call(null);
  }

  @override
  void close() {
    super.close();
    _inputs = [];
    _outputs = [];
    _accountInputs = [];
    onCompleteForm = null;
  }
}
