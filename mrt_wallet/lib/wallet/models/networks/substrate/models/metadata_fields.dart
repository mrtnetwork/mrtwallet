import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/crypto/utils/substrate/substrate.dart';
import 'package:mrt_wallet/wallet/constant/networks/substrate.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

abstract class LookupField {
  const LookupField();
  T cast<T extends LookupField>() {
    if (this is! T) {
      throw WalletException.invalidArgruments(["$T", runtimeType.toString()]);
    }
    return this as T;
  }
}

class CallLookupField extends LookupField {
  final MetadataTypeInfo type;
  final int lockupId;
  final Si1Variant variant;
  final CallMethodInfo method;
  const CallLookupField(
      {required this.type,
      required this.lockupId,
      required this.variant,
      required this.method});
}

class StorageLookupField extends LookupField {
  final MetadataTypeInfo? form;
  final StorageInfo storage;
  const StorageLookupField({required this.form, required this.storage});
}

class SubstrateStorageQueryParams {
  final StorageInfo storage;
  final Object? input;
  final String pallet;
  const SubstrateStorageQueryParams({
    required this.pallet,
    required this.storage,
    required this.input,
  });
}

class RuntimeMethodLookupField extends LookupField {
  final List<MetadataTypeInfo> validators;
  final RuntimeApiMethodInfo method;
  final String apiName;
  RuntimeMethodLookupField(
      {required List<MetadataTypeInfo> validators,
      required this.method,
      required this.apiName})
      : validators = validators.immutable;
}

class ExtrinsicLookupField extends LookupField {
  final MetadataTypeInfo call;
  final MetadataTypeInfo address;
  final MetadataTypeInfo signature;
  final List<MetadataTypeInfo> extrinsicValidators;
  final List<MetadataTypeInfo> extrinsicPayloadValidators;
  final TransactionExtrinsicInfo extrinsicInfo;
  ExtrinsicLookupField({
    required List<MetadataTypeInfo> extrinsicValidators,
    required List<MetadataTypeInfo> extrinsicPayloadValidators,
    required this.call,
    required this.extrinsicInfo,
    required this.address,
    required this.signature,
  })  : extrinsicValidators = extrinsicValidators.immutable,
        extrinsicPayloadValidators = extrinsicPayloadValidators.immutable;
}

class ExtrinsicPayloadInfo {
  final String payload;
  final List<int> payloadBytes;
  final String serializedExtrinsic;
  final String? payloadInfo;
  final String method;
  final SubstrateDefaultExtrinsic? extrinsic;
  ExtrinsicPayloadInfo._(
      {required this.payload,
      required this.serializedExtrinsic,
      required this.payloadInfo,
      required this.method,
      required this.extrinsic,
      required List<int> payloadBytes})
      : payloadBytes = payloadBytes.toImutableBytes;
  factory ExtrinsicPayloadInfo(
      {required List<int> serializedExtrinsic,
      SubstrateDefaultExtrinsic? extrinsic,
      Object? payloadInfo,
      required List<int> method}) {
    final payload = SubstrateUtils.createPayload(serializedExtrinsic);
    return ExtrinsicPayloadInfo._(
        payload: BytesUtils.toHexString(payload, prefix: "0x"),
        serializedExtrinsic:
            BytesUtils.toHexString(serializedExtrinsic, prefix: "0x"),
        payloadInfo: payloadInfo == null
            ? null
            : StringUtils.fromJson(payloadInfo,
                indent: '', toStringEncodable: true),
        method: BytesUtils.toHexString(method, prefix: "0x"),
        payloadBytes: payload,
        extrinsic: extrinsic);
  }
}

class ExtrinsicInfo {
  final int version;
  final ExtrinsicPayloadInfo payload;
  final String serializedExtrinsic;
  final List<int>? signature;
  ExtrinsicInfo._({
    required this.payload,
    required this.serializedExtrinsic,
    required this.version,
    required List<int>? signature,
  }) : signature = signature?.asImmutableBytes;
  factory ExtrinsicInfo({
    required int version,
    required ExtrinsicPayloadInfo payload,
    required String serializedExtrinsic,
    required bool signed,
    required List<int>? signature,
  }) {
    return ExtrinsicInfo._(
        payload: payload,
        serializedExtrinsic: serialize_(
            serializedExtrinsic: serializedExtrinsic,
            methodData: payload.method,
            extrinsicVersion: version,
            signed: signed),
        version: version,
        signature: signature);
  }
  static String serialize_(
      {required String serializedExtrinsic,
      required String methodData,
      required int extrinsicVersion,
      bool signed = true}) {
    final extrinsicBytes = BytesUtils.fromHexString(serializedExtrinsic);
    final callData = BytesUtils.fromHexString(methodData);
    final version = (extrinsicVersion |
        (signed ? SubstrateConstant.bitSigned : SubstrateConstant.bitUnsigned));
    final encode = [version, ...extrinsicBytes, ...callData];
    return BytesUtils.toHexString(encode, prefix: "0x");
  }

  List<int> serialize({bool encodeLength = true}) {
    final extrinsicBytes = BytesUtils.fromHexString(serializedExtrinsic);
    if (encodeLength) {
      final length = LayoutSerializationUtils.encodeLength(extrinsicBytes);
      return [...length, ...extrinsicBytes];
    }
    return extrinsicBytes;
  }
}

class SubstrateDefaultExtrinsic {
  final MortalEra era;
  final int nonce;
  final int specVersion;
  final int transactionVersion;
  final List<int> genesis;
  final List<int> mortality;
  final List<int>? metadataHash;
  final int? mode;
  final BigInt? tip;
  final List<int>? assetId;

  static final SubstrateDefaultExtrinsic fake = SubstrateDefaultExtrinsic(
      era: MortalEra(index: 189, era: 1),
      nonce: 0,
      specVersion: 0,
      transactionVersion: 0,
      genesis: List<int>.filled(32, 0),
      mortality: List<int>.filled(32, 0));
  SubstrateDefaultExtrinsic(
      {required this.era,
      required this.nonce,
      required this.specVersion,
      required this.transactionVersion,
      required List<int> genesis,
      required List<int> mortality,
      List<int>? assetId,
      this.metadataHash,
      this.mode,
      this.tip})
      : genesis = genesis.asImmutableBytes,
        mortality = mortality.asImmutableBytes,
        assetId = assetId?.asImmutableBytes;

  static bool hasField<E extends MetadataTypeInfo>(
      List<MetadataTypeInfo<dynamic>> ext, String name) {
    for (final i in ext) {
      final type = i.findType<E>(name);
      if (type != null) {
        return true;
      }
    }
    return false;
  }

  void _encodeField(
      {required int lookupId,
      required Object? input,
      required MetadataApi metadata,
      required DynamicByteTracker buffer}) {
    final encode =
        metadata.encodeLookup(id: lookupId, value: input, fromTemplate: false);
    buffer.add(encode);
  }

  List<int> encode(
      {required List<MetadataTypeInfo<dynamic>> fields,
      required MetadataApi metadata}) {
    final buffer = DynamicByteTracker();
    for (final i in fields) {
      final names = i.getTypeNames();
      if (names.isEmpty) continue;
      for (final n in names) {
        final typeId = i.findType(n)!.typeId;
        try {
          switch (n) {
            case "Era":
              _encodeField(
                  lookupId: typeId,
                  buffer: buffer,
                  input: era.scaleJsonSerialize(),
                  metadata: metadata);
              break;
            case "T::Nonce":
            case "CheckNonce":
            case "nonce":
              _encodeField(
                  lookupId: typeId,
                  buffer: buffer,
                  input: nonce,
                  metadata: metadata);
              break;
            case "BalanceOf<T>":
            case "PalletBalanceOf<T>":
            case "ChargeTransactionPayment":
            case "ChargeTransactionPayment<T>":
              _encodeField(
                  lookupId: typeId,
                  buffer: buffer,
                  input: BigInt.zero,
                  metadata: metadata);
              break;
            case "tip":
              _encodeField(
                  lookupId: typeId,
                  buffer: buffer,
                  input: tip ?? BigInt.zero,
                  metadata: metadata);
              break;
            case "CheckSpecVersion":
              _encodeField(
                  lookupId: typeId,
                  buffer: buffer,
                  input: specVersion,
                  metadata: metadata);
              break;
            case "CheckTxVersion":
              _encodeField(
                  lookupId: typeId,
                  buffer: buffer,
                  input: transactionVersion,
                  metadata: metadata);
              break;
            case "CheckGenesis":
              _encodeField(
                  lookupId: typeId,
                  buffer: buffer,
                  input: genesis,
                  metadata: metadata);
              break;
            case "CheckMortality":
              if (i.typeName == MetadataTypes.variant) {
                _encodeField(
                    lookupId: typeId,
                    buffer: buffer,
                    input: era.scaleJsonSerialize(),
                    metadata: metadata);
              } else {
                _encodeField(
                    lookupId: typeId,
                    buffer: buffer,
                    input: mortality,
                    metadata: metadata);
              }
              break;
            case "mode":
              if (mode == 1) {
                _encodeField(
                    lookupId: typeId,
                    buffer: buffer,
                    input: {"Enabled": null},
                    metadata: metadata);
              } else {
                _encodeField(
                    lookupId: typeId,
                    buffer: buffer,
                    input: {"Disabled": null},
                    metadata: metadata);
              }

              break;
            case "CheckMetadataHash":
              if (metadataHash != null) {
                buffer.add(metadataHash!);
              } else {
                _encodeField(
                    lookupId: typeId,
                    buffer: buffer,
                    input: {"None": null},
                    metadata: metadata);
              }

              break;
            case "asset_id":
              if (assetId != null) {
                buffer.add(assetId!);
              } else {
                _encodeField(
                    lookupId: typeId,
                    buffer: buffer,
                    input: {"None": null},
                    metadata: metadata);
              }

              break;
            default:
              throw UnimplementedError("field not found ${i.name} $n");
          }
        } catch (e) {
          throw WalletException('extrinsic_encoding_failed');
        }
      }
    }
    return buffer.toBytes();
  }
}

enum SubstrateTransferType {
  transferKeepAlive("transfer_keep_alive"),
  transferAllowDeath("transfer_allow_death");

  final String methodName;
  const SubstrateTransferType(this.methodName);
}

class SubstrateDefaultTransfer {
  final BaseSubstrateAddress address;
  final BigInt value;
  SubstrateDefaultTransfer({required this.address, required this.value});
  Object _getDest() {
    return switch (address.runtimeType) {
      const (SubstrateAddress) => {"Id": address.toBytes()},
      const (SubstrateEthereumAddress) => address.toBytes(),
      _ => throw UnsupportedError("Unknow substrate address type")
    };
  }

  Map<String, dynamic> toJson({
    SubstrateTransferType method = SubstrateTransferType.transferAllowDeath,
    bool usePallet = false,
  }) {
    final toJson = {
      method.methodName: {"dest": _getDest(), "value": value}
    };
    if (!usePallet) return toJson;
    return {APPSubstrateConst.balancePalletName: toJson};
  }

  List<int> encode(
      {required MetadataApi metadata,
      SubstrateTransferType method =
          SubstrateTransferType.transferAllowDeath}) {
    final Map<String, dynamic> input = {
      method.methodName: {"dest": _getDest(), "value": value}
    };
    return metadata.encodeCall(
        palletNameOrIndex: "balances", value: input, fromTemplate: false);
  }
}
