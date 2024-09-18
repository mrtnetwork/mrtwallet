import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:ton_dart/ton_dart.dart';

enum TonAccountContextType {
  legacy(CborTagsConst.tonAddressLegacy),
  subwallet(CborTagsConst.tonAddressSubWallet),
  v5(CborTagsConst.tonAddressV5),
  v5SubWallet(CborTagsConst.tonAddressV5SubWallet);

  final List<int> tag;
  const TonAccountContextType(this.tag);
  static TonAccountContextType fromTag(List<int>? tag) {
    return values.firstWhere((e) => BytesUtils.bytesEqual(e.tag, tag),
        orElse: () => throw WalletExceptionConst.invalidAccountDetails);
  }
}

abstract class TonAccountContext with CborSerializable, Equatable {
  final TonAccountContextType type;
  final WalletVersion version;
  final bool bouncable;
  const TonAccountContext(
      {required this.type, required this.version, required this.bouncable});
  VersionedWalletContract toWalletContract(
      {required List<int> publicKey, required TonChain chain});
  Cell buildTransaction(
      {required List<OutActionSendMsg> actions,
      required VersionedWalletState state,
      required int seqno,
      required TonChain chain,
      int? timeOut}) {
    return TonSerializationUtils.serializeMessage(
        actions: actions, state: state, seqno: seqno, timeOut: timeOut);
  }

  Message toExternalMessage(
      {required Cell message,
      required List<int> signature,
      required TonAddress destination,
      StateInit? state}) {
    final body = beginCell()
        .storeBuffer(signature)
        .storeSlice(message.beginParse())
        .endCell();
    return Message(
        init: state,
        info: CommonMessageInfoExternalIn(
            dest: destination, importFee: BigInt.zero),
        body: body);
  }

  factory TonAccountContext.deserialize(
      {List<int>? bytes, String? hex, CborObject? object}) {
    final CborTagValue decode =
        CborSerializable.decode(cborBytes: bytes, hex: hex, object: object);
    final type = TonAccountContextType.fromTag(decode.tags);
    final list = decode.getList;
    final WalletVersion version =
        WalletVersion.fromValue(list.elemetAs<String>(0));
    final bool bouncable = list.elementAt(1);
    switch (type) {
      case TonAccountContextType.legacy:
        return TonAccountLegacyContext(version: version, bouncable: bouncable);
      case TonAccountContextType.subwallet:
        return TonAccountSubWalletContext(
            version: version,
            bouncable: bouncable,
            subwalletId: list.elemetAs<int>(2));
      case TonAccountContextType.v5:
        return TonAccountV5CustomContext(
            version: version,
            bouncable: bouncable,
            contextId: list.elemetAs<int>(2));
      case TonAccountContextType.v5SubWallet:
        return TonAccountV5SubWalletContext(
            version: version,
            bouncable: bouncable,
            subwalletId: list.elemetAs<int>(2));
      default:
        throw WalletExceptionConst.invalidAccountDetails;
    }
  }
  factory TonAccountContext.merge(
      {required WalletVersion version,
      required bool bouncable,
      int? subwalletId}) {
    switch (version) {
      case WalletVersion.v1R1:
      case WalletVersion.v1R2:
      case WalletVersion.v1R3:
      case WalletVersion.v2R1:
      case WalletVersion.v2R2:
        if (subwalletId == null) {
          return TonAccountLegacyContext(
              version: version, bouncable: bouncable);
        }
        break;
      case WalletVersion.v3R1:
      case WalletVersion.v3R2:
      case WalletVersion.v4:
        if (subwalletId != null) {
          return TonAccountSubWalletContext(
              subwalletId: subwalletId, version: version, bouncable: bouncable);
        }
        break;
      default:
        break;
    }
    throw WalletExceptionConst.invalidAccountDetails;
  }
}

class TonAccountLegacyContext extends TonAccountContext {
  TonAccountLegacyContext._(
      {required WalletVersion version, required bool bouncable})
      : super(
            type: TonAccountContextType.legacy,
            version: version,
            bouncable: bouncable);
  factory TonAccountLegacyContext(
      {required WalletVersion version, required bool bouncable}) {
    if (version.version > 2) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
    return TonAccountLegacyContext._(version: version, bouncable: bouncable);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          version.name,
          bouncable,
        ]),
        type.tag);
  }

  @override
  VersionedWalletContract<VersionedWalletState,
          WalletContractTransferParams<OutAction>>
      toWalletContract(
          {required List<int> publicKey, required TonChain chain}) {
    return switch (version) {
      WalletVersion.v1R1 => WalletV1R1.create(
          chain: chain, publicKey: publicKey, bounceableAddress: bouncable),
      WalletVersion.v1R2 => WalletV1R2.create(
          chain: chain, publicKey: publicKey, bounceableAddress: bouncable),
      WalletVersion.v1R3 => WalletV1R3.create(
          chain: chain, publicKey: publicKey, bounceableAddress: bouncable),
      WalletVersion.v2R1 => WalletV2R1.create(
          chain: chain, publicKey: publicKey, bounceableAddress: bouncable),
      WalletVersion.v2R2 => WalletV2R2.create(
          chain: chain, publicKey: publicKey, bounceableAddress: bouncable),
      _ => throw WalletExceptionConst.invalidAccountDetails
    };
  }

  @override
  List get variabels => [version.name];
}

class TonAccountSubWalletContext extends TonAccountContext {
  final int subwalletId;
  const TonAccountSubWalletContext._(
      {required WalletVersion version,
      required this.subwalletId,
      required bool bouncable})
      : super(
            type: TonAccountContextType.subwallet,
            version: version,
            bouncable: bouncable);

  factory TonAccountSubWalletContext(
      {required WalletVersion version,
      required int subwalletId,
      required bool bouncable}) {
    if (version.version < 3 || version.version > 4) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
    return TonAccountSubWalletContext._(
        version: version, subwalletId: subwalletId, bouncable: bouncable);
  }
  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([version.name, bouncable, subwalletId]),
        type.tag);
  }

  @override
  VersionedWalletContract<VersionedWalletState,
          WalletContractTransferParams<OutAction>>
      toWalletContract(
          {required List<int> publicKey, required TonChain chain}) {
    return switch (version) {
      WalletVersion.v3R1 => WalletV3R1.create(
          chain: chain,
          publicKey: publicKey,
          bounceableAddress: bouncable,
          subWalletId: subwalletId),
      WalletVersion.v3R2 => WalletV3R2.create(
          chain: chain,
          publicKey: publicKey,
          bounceableAddress: bouncable,
          subWalletId: subwalletId),
      WalletVersion.v4 => WalletV4.create(
          chain: chain,
          publicKey: publicKey,
          bounceableAddress: bouncable,
          subWalletId: subwalletId),
      _ => throw WalletExceptionConst.invalidAccountDetails
    };
  }

  @override
  List get variabels => [version.name, subwalletId];
}

class TonAccountV5CustomContext extends TonAccountContext {
  final int walletId;
  const TonAccountV5CustomContext._(
      {required this.walletId, required bool bouncable})
      : super(
            type: TonAccountContextType.v5,
            version: WalletVersion.v5R1,
            bouncable: bouncable);
  factory TonAccountV5CustomContext(
      {required WalletVersion version,
      required int contextId,
      required bool bouncable}) {
    if (version != WalletVersion.v5R1) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
    return TonAccountV5CustomContext._(
        bouncable: bouncable, walletId: contextId);
  }
  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([version.name, bouncable, walletId]),
        type.tag);
  }

  @override
  WalletV5R1 toWalletContract(
      {required List<int> publicKey, required TonChain chain}) {
    return WalletV5R1.create(
        chain: chain,
        publicKey: publicKey,
        bounceableAddress: bouncable,
        context: V5R1CustomContext(context: walletId, chain: chain));
  }

  @override
  Cell buildTransaction(
      {required List<OutActionSendMsg> actions,
      required VersionedWalletState state,
      required int seqno,
      required TonChain chain,
      int? timeOut}) {
    return TonSerializationUtils.sseralizeV5(
        accountSeqno: seqno,
        actions: OutActionsV5(actions: actions),
        type: WalletV5AuthType.external,
        timeout: timeOut,
        context: V5R1CustomContext(context: walletId, chain: chain));
  }

  @override
  Message toExternalMessage(
      {required Cell message,
      required List<int> signature,
      required TonAddress destination,
      StateInit? state}) {
    final body = beginCell()
        .storeSlice(message.beginParse())
        .storeBuffer(signature)
        .endCell();
    return Message(
        init: state,
        info: CommonMessageInfoExternalIn(
            dest: destination, importFee: BigInt.zero),
        body: body);
  }

  @override
  List get variabels => [version.name, walletId];
}

class TonAccountV5SubWalletContext extends TonAccountContext {
  final int subwalletId;
  const TonAccountV5SubWalletContext._(
      {required this.subwalletId, required bool bouncable})
      : super(
            type: TonAccountContextType.v5SubWallet,
            version: WalletVersion.v5R1,
            bouncable: bouncable);

  factory TonAccountV5SubWalletContext(
      {required WalletVersion version,
      required int subwalletId,
      required bool bouncable}) {
    if (version != WalletVersion.v5R1) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
    return TonAccountV5SubWalletContext._(
        subwalletId: subwalletId, bouncable: bouncable);
  }
  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([version.name, bouncable, subwalletId]),
        type.tag);
  }

  @override
  WalletV5R1 toWalletContract(
      {required List<int> publicKey, required TonChain chain}) {
    return WalletV5R1.create(
        chain: chain,
        publicKey: publicKey,
        bounceableAddress: bouncable,
        context: V5R1ClientContext(subwalletNumber: subwalletId, chain: chain));
  }

  @override
  Cell buildTransaction({
    required List<OutActionSendMsg> actions,
    required VersionedWalletState state,
    required int seqno,
    required TonChain chain,
    int? timeOut,
  }) {
    return TonSerializationUtils.sseralizeV5(
        accountSeqno: seqno,
        actions: OutActionsV5(actions: actions),
        type: WalletV5AuthType.external,
        timeout: timeOut,
        context: V5R1ClientContext(subwalletNumber: subwalletId, chain: chain));
  }

  @override
  Message toExternalMessage(
      {required Cell message,
      required List<int> signature,
      required TonAddress destination,
      StateInit? state}) {
    final body = beginCell()
        .storeSlice(message.beginParse())
        .storeBuffer(signature)
        .endCell();
    return Message(
        init: state,
        info: CommonMessageInfoExternalIn(
            dest: destination, importFee: BigInt.zero),
        body: body);
  }

  @override
  List get variabels => [version.name, subwalletId];
}
