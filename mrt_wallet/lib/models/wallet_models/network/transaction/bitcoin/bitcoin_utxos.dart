import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

class BItcoinAccountUtxos {
  BItcoinAccountUtxos._(
      {required this.address,
      required this.utxoAddressDetails,
      this.utxosWithBalance,
      this.sumOfUtxos});
  factory BItcoinAccountUtxos(
      {required String address,
      required UtxoAddressDetails addressDetails,
      List<UtxoWithAddress>? utxos,
      required AppBitcoinNetwork network}) {
    if (utxos != null) {
      List<BitcoinUtxoWithBalance> utxosWithBalance = utxos
          .map((e) => BitcoinUtxoWithBalance(e.utxo, e.ownerDetails, network))
          .toList();
      final NoneDecimalBalance sumOfUtxos = NoneDecimalBalance(
          utxos.fold(BigInt.zero,
              (previousValue, element) => previousValue + element.utxo.value),
          network.coinParam.decimal);
      return BItcoinAccountUtxos._(
          address: address,
          sumOfUtxos: sumOfUtxos,
          // utxos: utxos,
          utxosWithBalance: utxosWithBalance,
          utxoAddressDetails: addressDetails);
    }
    return BItcoinAccountUtxos._(
        address: address, utxoAddressDetails: addressDetails);
  }
  final String address;
  final UtxoAddressDetails utxoAddressDetails;
  final List<BitcoinUtxoWithBalance>? utxosWithBalance;
  final NoneDecimalBalance? sumOfUtxos;

  bool get hasUtxo => utxosWithBalance != null;
}

class BitcoinUtxoWithBalance {
  BitcoinUtxoWithBalance(this.utxo, this.address, AppBitcoinNetwork network)
      : balance = NoneDecimalBalance(utxo.value, network.coinParam.decimal);

  final BitcoinUtxo utxo;
  late final NoneDecimalBalance balance;
  final UtxoAddressDetails address;
}

class BitcoinOutputWithBalance {
  BitcoinOutputWithBalance._({
    required this.viewAddress,
    required this.balance,
    required this.address,
    required this.token,
    required this.tokenBalance,
  });
  BitcoinOutputWithBalance(
      {required this.address, required AppBitcoinNetwork network, this.token})
      : assert(() {
          if (token != null && network is! AppBitcoinCashNetwork) {
            return false;
          }
          return true;
        }(),
            "${network.coinParam.token.name} does not support cashTokens feature"),
        viewAddress = address.networkAddress
            .toAddress(network.coinParam.transacationNetwork),
        balance = NoneDecimalBalance.zero(network.coinParam.decimal),
        tokenBalance = token == null || !token.hasAmount
            ? null
            : NoneDecimalBalance.zero(0);

  final String viewAddress;
  final NoneDecimalBalance balance;
  final ReceiptAddress<BitcoinBaseAddress> address;
  final CashToken? token;
  final NoneDecimalBalance? tokenBalance;
  bool get hasAmount => !balance.isZero;
  bool get hasTokenAmount => !(tokenBalance?.isZero ?? true);
  bool get isReady =>
      hasAmount && (token == null || !token!.hasAmount || hasTokenAmount);
  BitcoinBaseOutput toOutput({String? utxoHash}) {
    if (token != null) {
      return BitcoinTokenOutput(
          address: address.networkAddress,
          value: balance.balance,
          token: token!.copyWith(amount: tokenBalance?.balance),
          utxoHash: utxoHash);
    }
    return BitcoinOutput(
        address: address.networkAddress, value: balance.balance);
  }

  BitcoinOutputWithBalance copyWith(
      {String? viewAddress,
      NoneDecimalBalance? balance,
      ReceiptAddress<BitcoinBaseAddress>? address,
      CashToken? token,
      NoneDecimalBalance? tokenBalance}) {
    return BitcoinOutputWithBalance._(
        viewAddress: viewAddress ?? this.viewAddress,
        balance: balance ??
            NoneDecimalBalance(
                this.balance.balance, this.balance.currencyDecimal),
        address: address ?? this.address,
        token: token ?? this.token,
        tokenBalance: tokenBalance ??
            (this.tokenBalance == null
                ? null
                : NoneDecimalBalance(this.tokenBalance!.balance,
                    this.tokenBalance!.currencyDecimal)));
  }
}

class BitcoinBurnableUtxoWithBalance implements BitcoinOutputWithBalance {
  BitcoinBurnableUtxoWithBalance._({
    required this.token,
    required this.tokenBalance,
    required this.categoryId,
  });
  BitcoinBurnableUtxoWithBalance(
      {required this.token, required this.categoryId})
      : tokenBalance = !token.hasAmount ? null : NoneDecimalBalance.zero(0);

  @override
  String get viewAddress => "unknown";
  @override
  NoneDecimalBalance get balance => throw UnimplementedError();
  @override
  ReceiptAddress<BitcoinBaseAddress> get address => throw UnimplementedError();
  @override
  final CashToken token;
  @override
  final NoneDecimalBalance? tokenBalance;
  @override
  bool get hasAmount => !balance.isZero;
  @override
  bool get hasTokenAmount => !(tokenBalance?.isZero ?? true);
  @override
  bool get isReady => token.hasAmount == hasTokenAmount;
  final String categoryId;
  @override
  BitcoinBaseOutput toOutput({String? utxoHash}) {
    return BitcoinBurnableOutput(
        value: tokenBalance?.balance,
        utxoHash: token.hasAmount ? null : utxoHash,
        categoryID: categoryId);
  }

  @override
  BitcoinBurnableUtxoWithBalance copyWith(
      {String? viewAddress,
      NoneDecimalBalance? balance,
      ReceiptAddress<BitcoinBaseAddress>? address,
      CashToken? token,
      NoneDecimalBalance? tokenBalance,
      String? categoryId}) {
    return BitcoinBurnableUtxoWithBalance._(
        token: token ?? this.token,
        categoryId: categoryId ?? this.categoryId,
        tokenBalance: tokenBalance ??
            (this.tokenBalance == null
                ? null
                : NoneDecimalBalance(this.tokenBalance!.balance,
                    this.tokenBalance!.currencyDecimal)));
  }
}
