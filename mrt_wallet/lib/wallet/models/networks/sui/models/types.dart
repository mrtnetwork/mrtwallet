import 'package:blockchain_utils/bip/bip/conf/bip44/bip44_coins.dart';
import 'package:blockchain_utils/bip/ecc/bip_ecc.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/balance/balance.dart';
import 'package:mrt_wallet/wallet/models/network/core/network/network.dart';
import 'package:mrt_wallet/wallet/models/others/models/receipt_address.dart';
import 'package:mrt_wallet/wallet/models/token/chains_tokens/sui.dart';
import 'package:mrt_wallet/wallet/models/token/token/token.dart';
import 'package:on_chain/sui/sui.dart';

enum SuiSupportKeyScheme {
  ed25519(value: 0, name: "ED25519"),
  secp256k1(value: 1, name: "Secp256k1"),
  secp256r1(value: 2, name: "Secp256r1"),
  multisig(value: 3, name: "Multisig");

  final int value;
  final String name;

  const SuiSupportKeyScheme({required this.value, required this.name});
  static SuiSupportKeyScheme fromValue(int? value) {
    return values.firstWhere((e) => e.value == value,
        orElse: () => throw WalletExceptionConst.invalidData(
            messsage: "SuiSupportKeyScheme not found $value"));
  }

  EllipticCurveTypes get curve {
    return switch (this) {
      SuiSupportKeyScheme.secp256k1 => EllipticCurveTypes.secp256k1,
      SuiSupportKeyScheme.secp256r1 => EllipticCurveTypes.nist256p1Hybrid,
      _ => EllipticCurveTypes.ed25519
    };
  }

  SuiKeyAlgorithm get suiKeyAlgorithm {
    return switch (this) {
      SuiSupportKeyScheme.secp256k1 => SuiKeyAlgorithm.secp256k1,
      SuiSupportKeyScheme.secp256r1 => SuiKeyAlgorithm.secp256r1,
      _ => SuiKeyAlgorithm.ed25519
    };
  }

  static SuiSupportKeyScheme fromCoin(Bip44Coins coin) {
    return switch (coin) {
      Bip44Coins.sui => SuiSupportKeyScheme.ed25519,
      Bip44Coins.suiSecp256k1 => SuiSupportKeyScheme.secp256k1,
      Bip44Coins.suiSecp256r1 => SuiSupportKeyScheme.secp256r1,
      _ => throw WalletExceptionConst.invalidData(
          messsage: "Invalid sui drivation coin")
    };
  }
}

class SuiOutputWithBalance with Equatable {
  SuiOutputWithBalance({
    required this.address,
    required Token token,
  }) : balance = IntegerBalance.zero(token.decimal!, allowNegative: false);
  final IntegerBalance balance;
  final ReceiptAddress<SuiAddress> address;
  bool get hasAmount => balance.largerThanZero;
  bool get isReady => hasAmount;

  void updateBalance(BigInt amount) {
    balance.updateBalance(amount);
  }

  @override
  List get variabels => [address];
}

class SuiTransactionFee {
  final bool isSimulate;
  final BigInt gasPrice;
  final BigInt budget;
  final IntegerBalance totalFee;
  final BigInt requiredFee;
  const SuiTransactionFee._(
      {required this.budget,
      required this.gasPrice,
      required this.totalFee,
      required this.isSimulate,
      required this.requiredFee});
  factory SuiTransactionFee.fromBudget({
    required BigInt gasPrice,
    required WalletSuiNetwork network,
    required BigInt budget,
  }) {
    return SuiTransactionFee._(
        budget: budget,
        gasPrice: gasPrice,
        totalFee: IntegerBalance(budget, network.coinDecimal),
        isSimulate: true,
        requiredFee: budget);
  }
  factory SuiTransactionFee(
      {SuiApiGasCostSummary? gasUsed,
      required BigInt gasPrice,
      required WalletSuiNetwork network}) {
    final safeOverHead = SuiTransactionConst.gasSafeOverHead;
    if (gasUsed != null) {
      final baseComputationGasOverHead = gasUsed.computationCost + safeOverHead;
      BigInt gasBudget = baseComputationGasOverHead +
          gasUsed.storageCost -
          gasUsed.storageRebate;
      if (gasBudget < baseComputationGasOverHead) {
        gasBudget = baseComputationGasOverHead;
      }
      return SuiTransactionFee._(
          budget: gasBudget,
          gasPrice: gasPrice,
          totalFee: IntegerBalance(gasBudget, network.coinDecimal),
          isSimulate: true,
          requiredFee: gasBudget);
    }
    return SuiTransactionFee._(
        budget: SuiTransactionConst.minGas,
        gasPrice: gasPrice,
        totalFee:
            IntegerBalance(SuiTransactionConst.minGas, network.coinDecimal),
        isSimulate: false,
        requiredFee: SuiTransactionConst.minGas);
  }
}

class SuiWeb3AccountChangeBalance {
  final IntegerBalance? amount;
  final String amountStr;
  final String coinType;
  final SuiToken? token;
  final ReceiptAddress<SuiAddress>? ownerAddres;
  final String owner;
  const SuiWeb3AccountChangeBalance(
      {required this.coinType,
      required this.amountStr,
      required this.owner,
      this.ownerAddres,
      this.amount,
      this.token});
}
