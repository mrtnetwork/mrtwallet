import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/utils/substrate/substrate.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/core.dart';
import 'package:mrt_wallet/future/wallet/network/forms/substrate/core/substrate.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:polkadot_dart/polkadot_dart.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

class SubstrateTransferForm extends SubstrateTransactionForm {
  SubstrateTransferForm({required this.network});
  BigInt _callValue = BigInt.zero;
  @override
  BigInt get callValue => _callValue;
  final WalletSubstrateNetwork network;
  late SubstrateClient _client;
  SubstrateClient get client => _client;
  SubstrateChainMetadata get metadata => client.metadata;
  SubstrateTransferType _method = SubstrateTransferType.transferAllowDeath;
  SubstrateTransferType get method => _method;
  final TransactionListFormField<SubstrateOutputWithBalance> destination =
      TransactionListFormField(
          name: "destination",
          optional: false,
          onChangeForm: (p0) {
            return p0;
          });
  bool _enableDestinationField = true;
  bool get enableDestinationField => _enableDestinationField;

  @override
  String get name => "transfer";

  bool _isReady = false;

  bool get isReady => _isReady;

  BigInt _calcNativeValue() {
    final balances =
        destination.value.fold(BigInt.zero, (p, c) => p + c.balance.balance);
    return balances + fee;
  }

  void onChangeTransferMethod(SubstrateTransferType? method) {
    _method = method ?? _method;
    onChanged?.call();
  }

  void _checkDestination() {
    if (destination.isEmpty || metadata.supportBatch) {
      _enableDestinationField = true;
    } else {
      _enableDestinationField = false;
    }
  }

  BigInt maxTransfer(
      {required ChainAccount account,
      required SubstrateOutputWithBalance receiver}) {
    return (account.address.currencyBalance - callValue) +
        receiver.balance.balance;
  }

  void _check() {
    calculateNativeValue();
    _isReady = destination.isNotEmpty &&
        destination.value.every((element) => element.hasAmount);
    onChanged?.call();
    if (isReady) {
      onReadyField?.call();
    }
  }

  @override
  void calculateNativeValue() {
    _callValue = _calcNativeValue();
  }

  bool _setReceiver(ReceiptAddress<BaseSubstrateAddress> address) {
    final bool exists =
        destination.value.any((element) => element.address == address);
    if (exists) {
      return false;
    }
    destination.addValue(
        SubstrateOutputWithBalance(address: address, network: network));
    return true;
  }

  void setReceiver(
      {required List<ReceiptAddress<BaseSubstrateAddress>>? addresses,
      required DynamicVoid onExists}) {
    if (addresses == null || addresses.isEmpty) return;
    bool allAdded = true;
    for (final i in addresses) {
      allAdded &= _setReceiver(i);
    }
    if (!allAdded) {
      onExists.call();
    }
    _checkDestination();
    _check();
  }

  void onRemoveReceiver(SubstrateOutputWithBalance output) {
    destination.removeValue(output);
    _checkDestination();
    _check();
  }

  void setBalance(
      {required SubstrateOutputWithBalance address, BigInt? balance}) {
    if (balance == null) return;
    address.updateBalance(balance);
    _check();
  }

  @override
  String? validateError({ISubstrateAddress? account}) {
    if (!destination.hasValue) {
      return "add_least_one_receipt".tr;
    }
    for (final i in destination.value) {
      if (!i.hasAmount) {
        return "the_amount_is_unspecified".tr;
      }
    }

    return null;
  }

  List<Map<String, dynamic>> _toCalls({List<String> memos = const []}) {
    final remarks = SubstrateUtils.buildRemarks(memos);
    final bool batch = destination.length + memos.length > 1;
    final messages = destination.value
        .map((e) => e.toMessage().toJson(usePallet: batch, method: _method))
        .toList();
    return [...messages, ...remarks];
  }

  Future<ExtrinsicPayloadInfo> _buildTransaction(
      {required ISubstrateAddress address,
      required bool isFakeTx,
      List<String> memos = const []}) async {
    int nonce = 0;
    //await client.getAccountNonce(address);
    final blockInfo = await client.finalizeBlockWithEra();
    final List<int> genesis = metadata.genesisBytes();
    if (!isFakeTx) {
      nonce = await client.getAccountNonce(address);
    }

    final calls = SubstrateUtils.buildMethod(_toCalls(memos: memos));
    final bool batch = destination.length + memos.length > 1;

    final List<int> messageBytes = switch (batch) {
      false => metadata.metadata.encodeCall(
          palletNameOrIndex: APPSubstrateConst.balancePalletName,
          value: calls,
          fromTemplate: false),
      _ => metadata.metadata.encodeCall(
          palletNameOrIndex: APPSubstrateConst.utilityPalletName,
          value: calls,
          fromTemplate: false)
    };
    final extrinsic = SubstrateDefaultExtrinsic(
        era: blockInfo.era,
        nonce: nonce,
        specVersion: metadata.runtimeVersion.specVersion,
        transactionVersion: metadata.runtimeVersion.transactionVersion,
        genesis: genesis,
        mortality: blockInfo.blockHashBytes);
    final extrinsicTypes = metadata.extrinsic;
    final extraFields = extrinsic.encode(
        fields: extrinsicTypes.extrinsicPayloadValidators,
        metadata: metadata.metadata);
    final List<int> encodeBytes =
        [...messageBytes, ...extraFields].asImmutableBytes;
    final extrinsicInfo = ExtrinsicPayloadInfo(
        serializedExtrinsic: encodeBytes,
        method: messageBytes,
        extrinsic: extrinsic);
    return extrinsicInfo;
  }

  @override
  Future<ExtrinsicInfo> buildAndSignTransaction({
    ONSUBSTRATEREQUESTSIGNATURE? onGenerateSignature,
    required ISubstrateAddress address,
    List<String> memos = const [],
  }) async {
    final extrinsic = await _buildAndSignTransaction(
        address: address,
        onGenerateSignature: onGenerateSignature,
        memos: memos);
    return extrinsic;
  }

  Future<ExtrinsicInfo> _buildAndSignTransaction({
    ONSUBSTRATEREQUESTSIGNATURE? onGenerateSignature,
    required ISubstrateAddress address,
    List<String> memos = const [],
  }) async {
    final payloadInfo = await _buildTransaction(
        address: address, memos: memos, isFakeTx: onGenerateSignature == null);
    List<int> signature;
    if (onGenerateSignature == null) {
      signature = SubstrateUtils.createFakeSignature(address.coin.conf.type);
    } else {
      signature = await onGenerateSignature(payloadInfo.payloadBytes);
    }
    return metadata.createExtrinsic(
        signature: signature,
        address: address.networkAddress,
        algorithm: address.keyIndex.currencyCoin.conf.type,
        payload: payloadInfo);
  }

  @override
  Future<void> init(
      {required SubstrateChain chain, required ISubstrateAddress address}) {
    _client = chain.client;
    final client = chain.client;
    if (!client.metadata.supportNativeTransfer) {
      throw WalletException("substrate_disable_transfer_option_desc");
    }
    _method = metadata.transferTypes.first;

    return super.init(chain: chain, address: address);
  }

  @override
  void close() {
    _enableDestinationField = true;
    destination.clear();
  }
}
