import 'package:blockchain_utils/helper/helper.dart';
import 'package:blockchain_utils/utils/binary/bytes_tracker.dart';
import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/utils/substrate/substrate.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/network/forms/substrate/core/substrate.dart';
import 'package:mrt_wallet/future/wallet/network/substrate/metadata/forms/metadata.dart';
import 'package:mrt_wallet/future/widgets/widgets/progress_bar/progress.dart';
import 'package:mrt_wallet/wallet/api/api.dart';
import 'package:mrt_wallet/wallet/models/chain/address/networks/substrate/substrate.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/models/networks/networks.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

enum ExtrinsicPage {
  createPayload("create_payload"),
  createExtrinsic("create_extrinsic"),
  showExtrinsic("review_and_broadcast_extrinsic");

  const ExtrinsicPage(this.name);
  final String name;
}

class SubstrateExtersincForm extends SubstrateTransactionForm {
  SubstrateExtersincForm();

  TransactionExtrinsicInfo get extrinsicLookupField =>
      metadata.extrinsic.extrinsicInfo;
  List<MetadataFormValidator> extrinsicValidators = [];
  List<MetadataFormValidator> extrinsicPayloadValidators = [];
  List<MetadataFormValidator> _extrinsicValidators = [];
  List<MetadataFormValidator> _payloadValidators = [];
  late SubstrateClient _client;
  SubstrateChainMetadata get metadata => _client.metadata;
  final GlobalKey<StreamWidgetState> payloadProgressKey = GlobalKey();
  ExtrinsicInfo? _extrinsicInfo;
  ExtrinsicInfo? get extrinsicInfo => _extrinsicInfo;
  ExtrinsicPayloadInfo? _payloadInfo;
  ExtrinsicPayloadInfo get payloadInfo => _payloadInfo!;
  ExtrinsicPage _page = ExtrinsicPage.createPayload;
  ExtrinsicPage get page => _page;
  bool _signedTx = true;
  bool get signedTx => _signedTx;

  void toggleSignedTx(bool? _) {
    _signedTx = !_signedTx;
    _buildPayloadFields();
    onChanged?.call();
  }

  Future<void> createPayload() async {
    payloadProgressKey.process();
    final r = await MethodUtils.call(() async => _createPayload(),
        delay: APPConst.oneSecoundDuration);
    payloadProgressKey.fromMethodResult(r);
    if (r.hasResult) {
      _payloadInfo = r.result;
      _buildExFields();

      _page = ExtrinsicPage.createExtrinsic;
      onChanged?.call();
    }
  }

  (DynamicByteTracker, Map<String, dynamic>) _encodeCallPayload() {
    final byte = DynamicByteTracker();
    final Map<String, dynamic> extrinsicInfo = {};
    final form = extrinsicPayloadValidators[0] as MetadataFormValidatorVariant;
    final callInput = form.getResult();
    int? callLookupId = extrinsicLookupField.callType;
    if (callLookupId != null) {
      final encodeData = metadata.metadata
          .encodeLookup(id: callLookupId, value: callInput, fromTemplate: false)
          .asImmutableBytes;
      final decode = metadata.metadata.decodeLookup(callLookupId, encodeData);
      if (form.info.name != null) {
        extrinsicInfo[form.info.name!] = decode;
      }
      byte.add(encodeData);
    } else {
      callLookupId = form.variant!.fields[0].type;
      List<int> encodeData = metadata.metadata
          .encodeLookup(
              id: callLookupId,
              value: form.validator!.getResult(),
              fromTemplate: false)
          .asImmutableBytes;
      final decode = metadata.metadata.decodeLookup(callLookupId, encodeData);
      if (form.info.name != null) {
        extrinsicInfo[form.info.name!] = {form.variant!.name: decode};
      }
      encodeData = [form.variant!.index, ...encodeData];
      byte.add(encodeData);
    }
    return (byte, extrinsicInfo);
  }

  Future<ExtrinsicPayloadInfo> _createPayload() async {
    final err = validateError();
    if (err != null) {
      throw WalletException(err);
    }
    final callEncode = _encodeCallPayload();
    final byte = callEncode.$1;
    final List extrinsicInfo = [callEncode.$2];
    final List<int> callData = byte.toBytes().asImmutableBytes;
    for (int i = 1; i < extrinsicPayloadValidators.length; i++) {
      final form = extrinsicPayloadValidators[i];
      final input = form.getResult();
      final lookupId = extrinsicLookupField.payloadExtrinsic[i - 1].id;
      final encodeData = metadata.metadata
          .encodeLookup(id: lookupId, value: input, fromTemplate: false)
          .asImmutableBytes;
      final decode = metadata.metadata.decodeLookup(lookupId, encodeData);
      if (form.info.name != null) {
        extrinsicInfo.add({form.info.name: decode});
      } else {
        extrinsicInfo.add(decode);
      }
      byte.add(encodeData);
    }
    final encodeBytes = byte.toBytes().asImmutableBytes;
    return ExtrinsicPayloadInfo(
        serializedExtrinsic: encodeBytes,
        method: callData,
        payloadInfo: extrinsicInfo);
  }

  Future<void> updateFinalizBlock() async {
    _blockWithEra = await _client.finalizeBlockWithEra();
    _filledEra();
  }

  E? _getPayloadField<E extends MetadataFormValidator>(String name) {
    try {
      for (final i in extrinsicPayloadValidators) {
        final field = i.findField<E>(name);
        if (field != null) return field;
      }
    } catch (_) {}
    return null;
  }

  E? _getExtrinsicField<E extends MetadataFormValidator>(String name) {
    try {
      for (final i in extrinsicValidators) {
        final field = i.findField<E>(name);
        if (field != null) return field;
      }
    } catch (_) {}
    return null;
  }

  void _filedExtrinsicFields() {
    final nonce = _getNoncePayloadField()?.value.value;
    final exNonce =
        _getExtrinsicField<MetadataFormValidatorNumeric>("CheckNonce");
    if (nonce != null) {
      exNonce?.setDefaultvalue(nonce);
    }
    final tip =
        _getPayloadField<MetadataFormValidatorBigInt>("tip")?.value.value;
    final exTip = _getExtrinsicField<MetadataFormValidatorBigInt>("tip");
    if (tip != null) {
      exTip?.setDefaultvalue(tip);
    }
    final era = _getPayloadField<MetadataFormValidatorVariant>("Era") ??
        _getPayloadField<MetadataFormValidatorVariant>("CheckMortality");
    final exEra =
        _getExtrinsicField<MetadataFormValidatorVariant>("CheckMortality");
    if (era != null && exEra != null) {
      final eraVariant = exEra.info.variants
          .firstWhereNullable((e) => e.name == era.variant?.name);
      if (eraVariant != null) {
        final indexType = metadata.getTypeInfo(eraVariant);
        exEra.setVariant(variant: eraVariant, type: indexType);
        MethodUtils.nullOnException(() {
          exEra.validator?.cast<MetadataFormValidatorNumeric>().setDefaultvalue(
              era.validator!.cast<MetadataFormValidatorNumeric>().value.value!);
        });
      }
    }

    final mode = _getPayloadField<MetadataFormValidatorVariant>("mode");
    _getExtrinsicField<MetadataFormValidatorVariant>("mode")
        ?.mybeSetVariant(name: mode?.variant?.name, metadata: metadata);
  }

  SubstrateBlockWithEra? _blockWithEra;
  void _filledEra() {
    final finalizedBlock = _blockWithEra;
    if (finalizedBlock == null) return;
    _getPayloadField<MetadataFormValidatorBytes>("CheckMortality")
        ?.setDefaultValue(finalizedBlock.block);
    final era = _getPayloadField<MetadataFormValidatorVariant>("Era") ??
        _getPayloadField<MetadataFormValidatorVariant>("CheckMortality");
    final eraVariant = era?.info.variants
        .firstWhereNullable((e) => e.name == finalizedBlock.eraIndex);
    if (eraVariant != null) {
      final indexType = metadata.getTypeInfo(eraVariant);
      era?.setVariant(variant: eraVariant, type: indexType);
      MethodUtils.nullOnException(() => era?.validator
          ?.cast<MetadataFormValidatorNumeric>()
          .setDefaultIntvalue(finalizedBlock.eraValue));
    }
  }

  Future<void> _filedAccountNonce(ISubstrateAddress address) async {
    final nonce = await _client.getAccountNonce(address);
    final form = _getNoncePayloadField();
    form?.setDefaultIntvalue(nonce);
  }

  MetadataFormValidatorNumeric? _getNoncePayloadField() {
    return _getPayloadField<MetadataFormValidatorNumeric>("T::Nonce") ??
        _getPayloadField<MetadataFormValidatorNumeric>("CheckNonce") ??
        _getPayloadField<MetadataFormValidatorNumeric>("nonce");
  }

  Future<void> _filedPayloadFields(ISubstrateAddress address) async {
    await updateFinalizBlock();
    await _filedAccountNonce(address);
    _getPayloadField<MetadataFormValidatorNumeric>("CheckTxVersion")
        ?.setDefaultIntvalue(metadata.runtimeVersion.transactionVersion);
    _getPayloadField<MetadataFormValidatorNumeric>("CheckSpecVersion")
        ?.setDefaultIntvalue(metadata.runtimeVersion.specVersion);
    _getPayloadField<MetadataFormValidatorBytes>("CheckGenesis")
        ?.setDefaultValue(_client.genesisBlock);
    _getPayloadField<MetadataFormValidatorNumeric>("ChargeTransactionPayment")
        ?.setDefaultIntvalue(0);
    _getPayloadField<MetadataFormValidatorVariant>("CheckMetadataHash")
        ?.mybeSetVariant(name: "None", metadata: metadata);
    _getPayloadField<MetadataFormValidatorNumeric>("BalanceOf<T>")
        ?.setDefaultIntvalue(0);
    _getPayloadField<MetadataFormValidatorVariant>("mode")
        ?.mybeSetVariant(name: "Disabled", metadata: metadata);
  }

  Future<ExtrinsicInfo> createExtrinsic(ISubstrateAddress address) async {
    _extrinsicInfo = await _buildAndSignTransaction(address: address);

    _page = ExtrinsicPage.showExtrinsic;
    return _extrinsicInfo!;
  }

  ExtrinsicInfo _createExtrinsic(
      {required ISubstrateAddress address, required List<int>? signature}) {
    final buffer = DynamicByteTracker();
    if (signature != null) {
      final encodedAddress = metadata.encodeSigner(address.networkAddress);
      final encodeSignature = metadata.encodeSignature(
          algorithm: address.keyIndex.currencyCoin.conf.type,
          signature: signature);
      buffer.add(encodedAddress);
      buffer.add(encodeSignature);
    }
    final Map<String, dynamic> extrinsicInfo = {};
    final lookupids = [
      ...extrinsicLookupField.extrinsic.map((e) => e.id),
    ];
    for (int i = 0; i < extrinsicValidators.length; i++) {
      final form = extrinsicValidators[i];
      final lookupId = lookupids[i];
      final input = form.getResult();

      final encodeData = metadata.metadata
          .encodeLookup(id: lookupId, value: input, fromTemplate: false)
          .asImmutableBytes;
      final decode = metadata.metadata.decodeLookup(lookupId, encodeData);
      if (form.info.name != null) {
        extrinsicInfo[form.info.name!] = decode;
      }
      buffer.add(encodeData);
    }
    final encodeBytes = buffer.toBytes().asImmutableBytes;
    final encodeData = BytesUtils.toHexString(encodeBytes);
    return ExtrinsicInfo(
        payload: payloadInfo,
        serializedExtrinsic: encodeData,
        version: extrinsicLookupField.version,
        signed: signedTx,
        signature: null);
  }

  void _buildPayloadFields() {
    if (signedTx) {
      extrinsicPayloadValidators = _payloadValidators;
    } else {
      extrinsicPayloadValidators = [_payloadValidators[0]];
    }
  }

  void _buildExFields() {
    if (signedTx) {
      extrinsicValidators = _extrinsicValidators;
      _filedExtrinsicFields();
    } else {
      extrinsicValidators = [];
    }
  }

  @override
  Future<void> init(
      {required SubstrateChain chain,
      required ISubstrateAddress address}) async {
    _client = chain.client;
    final fields = metadata.extrinsic;
    _extrinsicValidators = [
      ...fields.extrinsicValidators
          .map((e) => MetadataFormValidator.fromType(e))
    ];
    _payloadValidators = [
      MetadataFormValidator.fromType(fields.call),
      ...fields.extrinsicPayloadValidators
          .map((e) => MetadataFormValidator.fromType(e))
    ];
    _buildPayloadFields();
    await _filedPayloadFields(address);
  }

  @override
  void calculateNativeValue() {}

  void editPayload() {
    _page = ExtrinsicPage.createPayload;
    _payloadInfo = null;
    onChanged?.call();
  }

  @override
  BigInt get callValue => BigInt.zero;

  @override
  String get name => 'create_extrinsic'.tr;

  @override
  String? validateError({ISubstrateAddress? account}) {
    switch (_page) {
      case ExtrinsicPage.createPayload:
        for (final i in extrinsicPayloadValidators) {
          final err = i.error;
          if (err != null) return err;
        }
        return null;
      case ExtrinsicPage.createExtrinsic:
        for (final i in extrinsicValidators) {
          final err = i.error;
          if (err != null) return err;
        }
        return null;
      default:
    }
    return null;
  }

  Future<ExtrinsicInfo> _buildAndSignTransaction({
    ONSUBSTRATEREQUESTSIGNATURE? onGenerateSignature,
    required ISubstrateAddress address,
  }) async {
    if (!signedTx) {
      return _createExtrinsic(address: address, signature: null);
    }
    List<int> signature;
    if (onGenerateSignature == null) {
      signature = SubstrateUtils.createFakeSignature(address.coin.conf.type);
    } else {
      signature = await onGenerateSignature(payloadInfo.payloadBytes);
    }
    return _createExtrinsic(address: address, signature: signature);
  }

  @override
  Future<ExtrinsicInfo> buildAndSignTransaction({
    ONSUBSTRATEREQUESTSIGNATURE? onGenerateSignature,
    required ISubstrateAddress address,
    List<String> memos = const [],
  }) async {
    assert(memos.isEmpty, "Memo must be empty.");
    final extrinsic = await _buildAndSignTransaction(
      onGenerateSignature: onGenerateSignature,
      address: address,
    );
    return extrinsic;
  }

  @override
  void close() {
    for (final i in extrinsicValidators) {
      i.dispose();
    }
    for (final i in extrinsicPayloadValidators) {
      i.dispose();
    }
    for (final i in _extrinsicValidators) {
      i.dispose();
    }
    for (final i in _payloadValidators) {
      i.dispose();
    }
    _extrinsicInfo = null;
    _payloadInfo = null;
    extrinsicValidators = [];
    extrinsicPayloadValidators = [];
    _extrinsicValidators = [];
    _payloadValidators = [];
    _page = ExtrinsicPage.createPayload;
    _signedTx = true;
  }
}
