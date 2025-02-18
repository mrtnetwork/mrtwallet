import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/network/forms/aptos/forms/core/aptos.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/models/models.dart';
import 'package:mrt_wallet/wallet/web3/networks/aptos/aptos.dart';
import 'package:on_chain/aptos/aptos.dart';

class Web3AptosSendTransactionForm
    extends AptosWeb3Form<Web3AptosSendTransaction> {
  Web3AptosSendTransactionForm({required this.request});

  @override
  Web3AptosRequest<List<int>, Web3AptosSendTransaction> request;
  final GlobalKey<StreamWidgetState> simulateProgressKey = GlobalKey();
  final Cancelable _cancelable = Cancelable();
  IntegerBalance? _fee;
  IntegerBalance get fee => _fee!;
  String? _simulateTxContent;
  String? get simulateContent => _simulateTxContent;
  AptosRawTransaction get rawTransaction => request.params.transaction;
  String? _transactionType;
  String get transactionType => _transactionType!;
  ReceiptAddress<AptosAddress>? _owner;
  ReceiptAddress<AptosAddress>? get owner => _owner;

  String? _vmStatus;
  String? get vmStatus => _vmStatus;
  bool _simulateSuccess = false;
  bool _hasSecondarySignerAddresses = false;
  bool get hasSecondarySignerAddresses => _hasSecondarySignerAddresses;
  String? _transactionContent;
  String get transactionContent => _transactionContent!;
  ReceiptAddress<AptosAddress>? _feePayer;
  ReceiptAddress<AptosAddress>? get feePayer => _feePayer;
  List<ReceiptAddress<AptosAddress>>? _secondarySignerAddresses;
  List<ReceiptAddress<AptosAddress>>? get secondarySignerAddresses =>
      _secondarySignerAddresses;

  StreamWidgetStatus _status = StreamWidgetStatus.progress;
  StreamWidgetStatus get status => _status;
  Future<void> simulateTx() async {
    if (_simulateSuccess) return;
    _status = StreamWidgetStatus.progress;
    _cancelable.cancel();
    _vmStatus = null;
    simulateProgressKey.process();
    onChanged?.call();
    _simulateSuccess = false;
    try {
      final r = await MethodUtils.call(() async {
        return client.simulateTransaction(
            rawTransaction: request.params.transaction,
            feePayer: request.params.feePayer,
            secondarySignerAddresses: request.params.secondarySignerAddresses);
      }, cancelable: _cancelable);
      if (r.isCancel) return;
      if (r.hasError || !r.result.success) {
        _vmStatus = r.error?.tr ?? r.result.vmStatus;
        if (r.hasResult) {
          _simulateTxContent = StringUtils.fromJson(r.result.toJson(),
              indent: ' ', toStringEncodable: true);
        }
        _status = StreamWidgetStatus.error;
        simulateProgressKey.error();
        return;
      }
      _vmStatus = r.result.vmStatus;
      _simulateTxContent = StringUtils.fromJson(r.result.toJson(),
          indent: ' ', toStringEncodable: true);
      _status = StreamWidgetStatus.idle;
      simulateProgressKey.idle();
      _simulateSuccess = true;
    } finally {
      onChanged?.call();
    }
  }

  ReceiptAddress<AptosAddress>? _getOrCreateReceiptAddress(
      AptosChain account, AptosAddress? address) {
    if (address == null) return null;
    return account.getReceiptAddress(address.address) ??
        ReceiptAddress(view: address.address, networkAddress: address);
  }

  @override
  void initForm(
      {required AptosChain account, required IAptosAddress? address}) {
    super.initForm(account: account, address: address);
    _transactionContent = StringUtils.fromJson(
        request.params.transaction.toJson(),
        indent: ' ',
        toStringEncodable: true);
    if (rawTransaction.sender != address?.networkAddress) {
      _owner = _getOrCreateReceiptAddress(account, rawTransaction.sender);
    }

    _secondarySignerAddresses = request.params.secondarySignerAddresses
        ?.map((e) => _getOrCreateReceiptAddress(account, e)!)
        .toList();
    _feePayer = _getOrCreateReceiptAddress(account, request.params.feePayer);
    _transactionType = rawTransaction.transactionPayload.type.name.camelCase;
    _hasSecondarySignerAddresses =
        _secondarySignerAddresses?.isNotEmpty ?? false;
    _fee = IntegerBalance(
        rawTransaction.maxGasAmount, account.network.coinDecimal);
    MethodUtils.after(() => simulateTx(),
        duration: APPConst.twoSecoundDuration);
  }

  Future<void> sendTransaction(FuncFutureNullableBoolString onSubmit) async {
    if (!_simulateSuccess) {
      final submit = await onSubmit(vmStatus != null
          ? "transaction_simulate_failed_desc".tr
          : "transaction_simulate_not_ready_desc".tr);
      if (submit != true) return;
    }
    onCompleteForm?.call(null);
  }

  @override
  void close() {
    super.close();
    onCompleteForm = null;
    _cancelable.cancel();
    _fee = null;
    _simulateTxContent = null;
    _transactionType = null;
    _owner = null;
    _vmStatus = null;
    _hasSecondarySignerAddresses = false;
    _transactionContent = null;
    _feePayer = null;
    _secondarySignerAddresses = null;
  }
}
