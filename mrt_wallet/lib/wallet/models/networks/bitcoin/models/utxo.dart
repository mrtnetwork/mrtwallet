import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:mrt_wallet/wallet/models/balance/balance.dart';
import 'package:mrt_wallet/wallet/models/others/models/receipt_address.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';

class BitcoinAccountUtxos {
  BitcoinAccountUtxos._(
      {required this.address,
      required this.utxoAddressDetails,
      this.utxosWithBalance,
      this.sumOfUtxos});
  factory BitcoinAccountUtxos(
      {required String address,
      required UtxoAddressDetails addressDetails,
      List<UtxoWithAddress>? utxos,
      required WalletBitcoinNetwork network}) {
    if (utxos != null) {
      List<BitcoinUtxoWithBalance> utxosWithBalance = utxos
          .map((e) => BitcoinUtxoWithBalance(e.utxo, e.ownerDetails, network))
          .toList();
      final IntegerBalance sumOfUtxos = IntegerBalance(
          utxos.fold(BigInt.zero,
              (previousValue, element) => previousValue + element.utxo.value),
          network.coinParam.decimal);
      return BitcoinAccountUtxos._(
          address: address,
          sumOfUtxos: sumOfUtxos,
          // utxos: utxos,
          utxosWithBalance: utxosWithBalance,
          utxoAddressDetails: addressDetails);
    }
    return BitcoinAccountUtxos._(
        address: address, utxoAddressDetails: addressDetails);
  }
  final String address;
  final UtxoAddressDetails utxoAddressDetails;
  final List<BitcoinUtxoWithBalance>? utxosWithBalance;
  final IntegerBalance? sumOfUtxos;

  bool get hasUtxo => utxosWithBalance != null;
}

class BitcoinUtxoWithBalance {
  BitcoinUtxoWithBalance(this.utxo, this.address, WalletBitcoinNetwork network)
      : balance = IntegerBalance(utxo.value, network.coinParam.decimal);

  final BitcoinUtxo utxo;
  late final IntegerBalance balance;
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
      {required this.address,
      required WalletBitcoinNetwork network,
      this.token})
      : assert(() {
          if (token != null && network.type != NetworkType.bitcoinCash) {
            return false;
          }
          return true;
        }(),
            "${network.coinParam.token.name} does not support cashTokens feature"),
        viewAddress = address.networkAddress
            .toAddress(network.coinParam.transacationNetwork),
        balance = IntegerBalance.zero(network.coinParam.decimal),
        tokenBalance =
            token == null || !token.hasAmount ? null : IntegerBalance.zero(0);

  final String viewAddress;
  final IntegerBalance balance;
  final ReceiptAddress<BitcoinBaseAddress> address;
  final CashToken? token;
  final IntegerBalance? tokenBalance;
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
      IntegerBalance? balance,
      ReceiptAddress<BitcoinBaseAddress>? address,
      CashToken? token,
      IntegerBalance? tokenBalance}) {
    return BitcoinOutputWithBalance._(
        viewAddress: viewAddress ?? this.viewAddress,
        balance: balance ??
            IntegerBalance(this.balance.balance, this.balance.currencyDecimal),
        address: address ?? this.address,
        token: token ?? this.token,
        tokenBalance: tokenBalance ??
            (this.tokenBalance == null
                ? null
                : IntegerBalance(this.tokenBalance!.balance,
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
      : tokenBalance = !token.hasAmount ? null : IntegerBalance.zero(0);

  @override
  String get viewAddress => "unknown";
  @override
  IntegerBalance get balance => throw UnimplementedError();
  @override
  ReceiptAddress<BitcoinBaseAddress> get address => throw UnimplementedError();
  @override
  final CashToken token;
  @override
  final IntegerBalance? tokenBalance;
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
      IntegerBalance? balance,
      ReceiptAddress<BitcoinBaseAddress>? address,
      CashToken? token,
      IntegerBalance? tokenBalance,
      String? categoryId}) {
    return BitcoinBurnableUtxoWithBalance._(
        token: token ?? this.token,
        categoryId: categoryId ?? this.categoryId,
        tokenBalance: tokenBalance ??
            (this.tokenBalance == null
                ? null
                : IntegerBalance(this.tokenBalance!.balance,
                    this.tokenBalance!.currencyDecimal)));
  }
}
