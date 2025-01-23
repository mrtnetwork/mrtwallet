import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/app/utils/list/extension.dart';
import 'package:mrt_wallet/crypto/utils/substrate/substrate.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:on_chain/on_chain.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

class _SubstrateChainConst {
  static const List<int> supportedExtrinsicVersions = [4, 5];
  static MetadataTypeInfo? getLookupTypeInfo(
      {required MetadataApi metadata, int? lockupId, String? name}) {
    if (lockupId == null) return null;
    final info = metadata.metadata
        .getLookup(lockupId)
        .typeInfo(metadata.registry, lockupId);
    if (name == null) return info;
    return info.copyWith(name: name);
  }

  static SubstrateKeyAlgorithm? isEthereum(
      {required MetadataApi metadata,
      required TransactionExtrinsicInfo extrinsic}) {
    try {
      metadata.getCallLookupId('ethereum');
      metadata.getCallLookupId('evm');
      metadata.metadata.encodeLookup(
          id: extrinsic.addressType!,
          value: List<int>.filled(ETHAddress.lengthInBytes, 0),
          fromTemplate: false);
      metadata.metadata.encodeLookup(
          id: extrinsic.signatureType!,
          value: List<int>.filled(SubstrateConstant.ecdsaSignatureLength, 0),
          fromTemplate: false);
      return SubstrateKeyAlgorithm.ethereum;
    } catch (_) {
      return null;
    }
  }

  static List<SubstrateKeyAlgorithm> isSubstrate(
      {required MetadataApi metadata,
      required TransactionExtrinsicInfo extrinsic}) {
    try {
      metadata.metadata.encodeLookup(
          id: extrinsic.addressType!,
          value: {
            "Id": List<int>.filled(SubstrateConstant.accountIdLengthInBytes, 0)
          },
          fromTemplate: false);
      final sigType = getLookupTypeInfo(
          metadata: metadata, lockupId: extrinsic.signatureType!);
      if (sigType == null || sigType is! MetadataTypeInfoVariant) return [];
      List<SubstrateKeyAlgorithm> keyAlgorithms = [];
      for (final i in sigType.variants) {
        final SubstrateKeyAlgorithm? keyAlgorithm = SubstrateKeyAlgorithm.values
            .firstWhereOrNull((e) => e.name == i.name);
        if (keyAlgorithm == null ||
            keyAlgorithm == SubstrateKeyAlgorithm.ethereum) {
          continue;
        }
        metadata.metadata.encodeLookup(
            id: extrinsic.signatureType!,
            value: {
              keyAlgorithm.name:
                  List<int>.filled(keyAlgorithm.signatureLength, 0)
            },
            fromTemplate: false);
        keyAlgorithms.add(keyAlgorithm);
      }
      return keyAlgorithms;
    } catch (_) {
      return [];
    }
  }

  static (SubstrateChainType, List<SubstrateKeyAlgorithm>) getAlgorithms(
      {required MetadataApi metadata,
      required TransactionExtrinsicInfo extrinsic}) {
    final eth = isEthereum(metadata: metadata, extrinsic: extrinsic);
    if (eth != null) return (SubstrateChainType.ethereum, [eth]);
    final substrate = isSubstrate(metadata: metadata, extrinsic: extrinsic);
    if (substrate.isEmpty) {
      throw WalletException('unsuported_network_metadata');
    }
    return (SubstrateChainType.substrate, substrate);
  }

  static int ss58Prefix({required MetadataApi metadata}) {
    try {
      return metadata.networkSS58Prefix();
    } catch (_) {
      throw WalletException('unsuported_network_metadata');
    }
  }

  static bool supportAccountTemplate({required MetadataApi metadata}) {
    try {
      final f = metadata.metadata.getStorageOutputId('System', 'account');
      final decode = metadata.decodeLookup(f, List.filled(80, 0));
      SubstrateDefaultAccount.deserializeJson(decode);
      return true;
    } catch (_) {
      return false;
    }
  }

  static bool supportRemark({required MetadataApi metadata}) {
    try {
      metadata.encodeCall(
          palletNameOrIndex: "System",
          value: {
            APPSubstrateConst.systemRemarkVariantName: [0x00]
          },
          fromTemplate: false);
      return true;
    } catch (_) {
      return false;
    }
  }

  static bool supportBatch(
      {required MetadataApi metadata,
      required List<SubstrateTransferType> transferTypes,
      required SubstrateChainType chainType}) {
    if (transferTypes.isEmpty) return false;
    try {
      final transfer = createFakeTx(chainType);
      metadata.encodeCall(
          palletNameOrIndex: APPSubstrateConst.utilityPalletName,
          value: {
            APPSubstrateConst.utilityBatchVariantName: [
              transfer.toJson(method: transferTypes.first, usePallet: true)
            ]
          },
          fromTemplate: false);
      return true;
    } catch (_) {
      return false;
    }
  }

  static SubstrateDefaultTransfer createFakeTx(SubstrateChainType chainType) {
    if (chainType.isEthereum) {
      return SubstrateDefaultTransfer(
          address: SubstrateEthereumAddress(
              '0x0000000000000000000000000000000000000000'),
          value: BigInt.zero);
    }
    return SubstrateDefaultTransfer(
        address: SubstrateAddress(
            '5C4hrfjw9DjXZTzV3MwzrrAr9P1MJhSrvWGWqi1eSuyUpnhM'),
        value: BigInt.zero);
  }

  static List<SubstrateTransferType> transferTypes(
      {required MetadataApi metadata, required SubstrateChainType chainType}) {
    SubstrateDefaultTransfer transfer = createFakeTx(chainType);
    return SubstrateTransferType.values
        .map((e) {
          try {
            transfer.encode(metadata: metadata, method: e);
            return e;
          } catch (_) {
            return null;
          }
        })
        .whereType<SubstrateTransferType>()
        .toList();
  }

  static ExtrinsicLookupField buildExtrinsicFields({
    required MetadataApi metadata,
    required TransactionExtrinsicInfo extrinsic,
  }) {
    List<MetadataTypeInfo> payloadTypes = [];
    List<MetadataTypeInfo> extrinsicTypes = [];
    MetadataTypeInfo address = getLookupTypeInfo(
        metadata: metadata, lockupId: extrinsic.addressType!, name: "Address")!;

    MetadataTypeInfo signature = getLookupTypeInfo(
        metadata: metadata, lockupId: extrinsic.addressType!, name: "Address")!;

    MetadataTypeInfo call;
    if (extrinsic.callType == null) {
      final pallets =
          metadata.metadata.pallets.values.where((e) => e.calls != null);
      final variants = pallets.map((e) => Si1Variant(
          name: e.name,
          fields: [
            Si1Field(name: null, type: e.calls!.type, typeName: null, docs: [])
          ],
          index: e.index,
          docs: e.docs ?? []));
      call = MetadataTypeInfoVariant(
          variants: variants.toList(), typeId: -1, name: "Call");
    } else {
      call = getLookupTypeInfo(
          metadata: metadata, lockupId: extrinsic.callType!, name: "Call")!;
    }

    for (final i in extrinsic.payloadExtrinsic) {
      MetadataTypeInfo loockup =
          getLookupTypeInfo(metadata: metadata, lockupId: i.id, name: i.name)!;
      payloadTypes.add(loockup);
    }
    for (final i in extrinsic.extrinsic) {
      MetadataTypeInfo loockup =
          getLookupTypeInfo(metadata: metadata, lockupId: i.id, name: i.name)!;
      extrinsicTypes.add(loockup);
    }
    return ExtrinsicLookupField(
        call: call,
        extrinsicValidators: extrinsicTypes,
        extrinsicPayloadValidators: payloadTypes,
        extrinsicInfo: extrinsic,
        address: address,
        signature: signature);
  }
}

enum SubstrateChainType {
  substrate(value: 0, name: "Substrate"),
  ethereum(value: 1, name: "Ethereum");

  bool get isEthereum => this == ethereum;

  const SubstrateChainType({required this.value, required this.name});
  final int value;
  final String name;

  static SubstrateChainType fromValue(int? value) {
    return values.firstWhere((e) => e.value == value,
        orElse: () => throw WalletExceptionConst.dataVerificationFailed);
  }
}

class SubstrateChainMetadata {
  final MetadataApi metadata;
  final ExtrinsicLookupField extrinsic;
  final String genesis;
  final MetadataInfo metadataInfos;
  final RuntimeVersion runtimeVersion;
  final List<SubstrateTransferType> transferTypes;
  final List<SubstrateKeyAlgorithm> supportedAlgorithms;
  final bool supportAccountTemplate;
  final int ss58Prefix;
  final SubstrateChainType type;
  final bool supportRemarks;
  final bool supportBatch;
  bool get supportNativeTransfer => transferTypes.isNotEmpty;
  int get transactionVersion => runtimeVersion.transactionVersion;
  int get specVersion => runtimeVersion.specVersion;
  bool get supportRuntimeApi => metadata.metadata.supportRuntimeApi;
  List<int> genesisBytes() {
    return BytesUtils.fromHexString(genesis);
  }

  SubstrateChainMetadata._(
      {required this.metadataInfos,
      required this.genesis,
      required this.metadata,
      required this.runtimeVersion,
      required this.extrinsic,
      required this.supportedAlgorithms,
      required this.transferTypes,
      required this.supportAccountTemplate,
      required this.ss58Prefix,
      required this.type,
      required this.supportBatch,
      required this.supportRemarks});
  factory SubstrateChainMetadata(
      {required String genesis, required MetadataApi metadata}) {
    final metadataInfos = metadata.metadata.palletsInfos();
    final metadataExtrinsic = metadataInfos.extrinsic.firstWhere(
        (e) =>
            _SubstrateChainConst.supportedExtrinsicVersions
                .contains(e.version) &&
            e.addressType != null &&
            e.signatureType != null,
        orElse: () => throw WalletException('unsuported_network_metadata'));

    final keyAlgorithms = _SubstrateChainConst.getAlgorithms(
        metadata: metadata, extrinsic: metadataExtrinsic);
    final transferTypes = _SubstrateChainConst.transferTypes(
        metadata: metadata, chainType: keyAlgorithms.$1);
    final extrinsic = _SubstrateChainConst.buildExtrinsicFields(
        metadata: metadata, extrinsic: metadataExtrinsic);
    final fakeExtrinsic = SubstrateDefaultExtrinsic.fake;
    fakeExtrinsic.encode(
        fields: extrinsic.extrinsicPayloadValidators, metadata: metadata);
    fakeExtrinsic.encode(
        fields: extrinsic.extrinsicValidators, metadata: metadata);
    final chainMetadata = SubstrateChainMetadata._(
        metadataInfos: metadataInfos,
        genesis: genesis,
        metadata: metadata,
        runtimeVersion: metadata.runtimeVersion(),
        extrinsic: extrinsic,
        supportedAlgorithms: keyAlgorithms.$2,
        type: keyAlgorithms.$1,
        transferTypes: transferTypes,
        supportAccountTemplate:
            _SubstrateChainConst.supportAccountTemplate(metadata: metadata),
        ss58Prefix: _SubstrateChainConst.ss58Prefix(metadata: metadata),
        supportBatch: _SubstrateChainConst.supportBatch(
            metadata: metadata,
            transferTypes: transferTypes,
            chainType: keyAlgorithms.$1),
        supportRemarks: _SubstrateChainConst.supportRemark(metadata: metadata));
    return chainMetadata;
  }

  List<PalletInfo> constantPallets() {
    return metadataInfos.pallets.where((e) => e.contants != null).toList();
  }

  List<PalletInfo> callPallets() {
    return metadataInfos.pallets.where((e) => e.calls != null).toList();
  }

  List<PalletInfo> storagePallets() {
    return metadataInfos.pallets.where((e) => e.storage != null).toList();
  }

  StorageInfo? getAccountInfoStorageKey() {
    final system = metadataInfos.pallets
        .firstWhereOrNull((e) => e.name.toLowerCase() == "system");
    return system?.storage
        ?.firstWhereOrNull((e) => e.name.toLowerCase() == "account");
  }

  MetadataTypeInfo getTypeInfo(Si1Variant variant) {
    MetadataTypeInfo info = variant.typeInfo(metadata.registry, 0);
    info = info.copyWith(name: info.name ?? variant.name);
    return info;
  }

  MetadataTypeInfo? getLookupTypeInfo(int? lockupId, {String? name}) {
    if (lockupId == null) return null;
    final info = metadata.metadata
        .getLookup(lockupId)
        .typeInfo(metadata.registry, lockupId);
    if (name == null) return info;
    return info.copyWith(name: name);
  }

  List<int> encodeSigner(BaseSubstrateAddress address) {
    switch (type) {
      case SubstrateChainType.ethereum:
        return metadata.metadata.encodeLookup(
            id: extrinsic.extrinsicInfo.addressType!,
            value: address.toBytes(),
            fromTemplate: false);
      default:
        final encode = metadata.metadata.encodeLookup(
            id: extrinsic.extrinsicInfo.addressType!,
            value: {"Id": address.toBytes()},
            fromTemplate: false);
        return encode;
    }
  }

  List<int> encodeSignature({
    required EllipticCurveTypes algorithm,
    required List<int> signature,
  }) {
    switch (type) {
      case SubstrateChainType.ethereum:
        return metadata.metadata.encodeLookup(
            id: extrinsic.extrinsicInfo.signatureType!,
            value: signature,
            fromTemplate: false);
      default:
        final encode = metadata.metadata.encodeLookup(
            id: extrinsic.extrinsicInfo.signatureType!,
            value: SubstrateUtils.buildMultiSignatureTemplate(
                algorithm: algorithm, signature: signature),
            fromTemplate: false);
        return encode;
    }
  }

  ExtrinsicInfo createExtrinsic(
      {required List<int>? signature,
      required BaseSubstrateAddress address,
      required EllipticCurveTypes algorithm,
      required ExtrinsicPayloadInfo payload}) {
    final buffer = DynamicByteTracker();
    List<int>? encodeSignature;
    if (signature != null) {
      final encodedAddress = encodeSigner(address);
      encodeSignature =
          this.encodeSignature(algorithm: algorithm, signature: signature);
      buffer.add(encodedAddress);
      buffer.add(encodeSignature);
    }
    if (payload.extrinsic != null) {
      buffer.add(payload.extrinsic!
          .encode(fields: extrinsic.extrinsicValidators, metadata: metadata));
    }
    final encodeBytes = buffer.toBytes().asImmutableBytes;
    final encodeData = BytesUtils.toHexString(encodeBytes);
    return ExtrinsicInfo(
        payload: payload,
        serializedExtrinsic: encodeData,
        version: extrinsic.extrinsicInfo.version,
        signed: signature != null,
        signature: encodeSignature);
  }
}
