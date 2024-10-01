import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:stellar_dart/stellar_dart.dart';
import 'package:mrt_wallet/app/utils/list/extension.dart';

enum StellarFeeMode {
  slow("slow"),
  normal("normal"),
  high("high"),
  costom("custom_fee");

  const StellarFeeMode(this.translate);

  final String translate;
  static StellarFeeMode? fromName(String? name) {
    return values.firstWhereOrNull((e) => e.name == name);
  }
}

class StellarPickedIssueAsset {
  final StellarAsset asset;
  final Token token;
  final String? issuer;
  final StellarIssueToken? issueToken;
  StellarPickedIssueAsset._({
    required this.asset,
    required this.token,
    this.issuer,
    this.issueToken,
    IntegerBalance? tokenBalance,
  }) : tokenBalance = tokenBalance ?? issueToken?.balance.value;
  Token get currentToken => issueToken?.token ?? token;
  final IntegerBalance? tokenBalance;

  factory StellarPickedIssueAsset(
      {required StellarAsset asset,
      required WalletStellarNetwork network,
      required StellarIssueToken? issueToken,
      IntegerBalance? tokenBalance}) {
    switch (asset.type) {
      case AssetType.creditAlphanum4:
        final assetCode4 = asset.cast<StellarAssetCreditAlphanum4>();
        return StellarPickedIssueAsset._(
            asset: asset,
            token: Token(
                name: assetCode4.code,
                symbol: assetCode4.code,
                decimal: network.coinParam.decimal),
            issuer: assetCode4.issuer.toAddress().toString(),
            tokenBalance: tokenBalance);
      case AssetType.creditAlphanum12:
        final assetCode12 = asset.cast<StellarAssetCreditAlphanum12>();
        return StellarPickedIssueAsset._(
            asset: asset,
            token: Token(
                name: assetCode12.code,
                symbol: assetCode12.code,
                decimal: network.coinParam.decimal),
            issuer: assetCode12.issuer.toAddress().baseAddress,
            issueToken: issueToken,
            tokenBalance: tokenBalance);
      case AssetType.poolShare:
        final pool = asset.cast<StellarAssetPoolShare>();
        final poolId = BytesUtils.toHexString(pool.poolID);
        return StellarPickedIssueAsset._(
            asset: asset,
            token: Token(
                name: poolId,
                symbol: poolId,
                decimal: network.coinParam.decimal),
            issuer: poolId,
            issueToken: issueToken,
            tokenBalance: tokenBalance);
      case AssetType.native:
        return StellarPickedIssueAsset._(
            asset: asset,
            token: network.coinParam.token,
            issueToken: issueToken,
            tokenBalance: tokenBalance);
      default:
        throw WalletExceptionConst.unsuportedFeature;
    }
  }
}

enum AccountReceivementStatus {
  idle,
  pending,
  active,
  error,
  inactive;

  bool get canTry => this == idle || this == error;
  bool get canUpdateStatus => this != active && this != inactive;
  bool get isInactive => this == inactive;
  bool get isActive => this == active;
  bool get isError => this == error;
}

class StellarReceiptWithActivityStatus {
  StellarReceiptWithActivityStatus(this.address);
  AccountReceivementStatus _status = AccountReceivementStatus.idle;
  AccountReceivementStatus get status => _status;
  String? _error;
  String? get error => _error;
  bool get hasError => _error != null;

  void setError(String? err) {
    _error = err;
  }

  void setStatus(AccountReceivementStatus status) {
    if (!this.status.canUpdateStatus) return;
    _status = status;
  }

  void setPending() {
    if (!status.canTry) return;
    _status = AccountReceivementStatus.pending;
  }

  final ReceiptAddress<StellarAddress> address;
}

class StellarMemoDetils {
  final StellarMemo memo;
  final String? val;
  const StellarMemoDetils._(this.memo, this.val);
  factory StellarMemoDetils(StellarMemo memo) {
    String? val;
    switch (memo.type) {
      case MemoType.text:
        val = (memo.cast<StellarMemoText>()).text;
        break;
      case MemoType.hash:
        val = BytesUtils.toHexString((memo.cast<StellarMemoHash>()).hash,
            prefix: "0x");
        break;
      case MemoType.returnHash:
        val = BytesUtils.toHexString((memo.cast<StellarMemoReturnHash>()).hash,
            prefix: "0x");
        break;
      case MemoType.id:
        val = (memo.cast<StellarMemoID>()).id.toString();
        break;
      default:
    }
    return StellarMemoDetils._(memo, val);
  }
}

enum TransactiomTimeBoundType {
  manual,
  auto,
  none;

  bool get isManual => this == manual;
}

class TransactionTimeBound {
  final TransactiomTimeBoundType type;
  final DateTime? time;
  const TransactionTimeBound._({required this.type, this.time});
  const TransactionTimeBound.auto()
      : type = TransactiomTimeBoundType.auto,
        time = null;
  factory TransactionTimeBound(
      {required TransactiomTimeBoundType type, DateTime? time}) {
    if (type.isManual && time == null) {
      throw WalletExceptionConst.dataVerificationFailed;
    }
    if (!type.isManual && time != null) {
      throw WalletExceptionConst.dataVerificationFailed;
    }
    return TransactionTimeBound._(type: type, time: time);
  }

  bool get isExpired {
    if (!type.isManual) return false;
    return time!.isBefore(DateTime.now().toLocal());
  }

  Preconditions condition() {
    final DateTime time = this.time?.toUtc() ??
        DateTime.now().toUtc().add(StellarConst.defaultTimeBound);
    final secondsEpoch = time.microsecondsSinceEpoch ~/ 1000;
    return switch (type) {
      TransactiomTimeBoundType.none => const PrecondNone(),
      _ => PrecondTime(
          TimeBounds(minTime: BigInt.zero, maxTime: BigInt.from(secondsEpoch))),
    };
  }
}
