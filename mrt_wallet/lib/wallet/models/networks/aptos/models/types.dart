import 'package:blockchain_utils/bip/bip/conf/bip44/bip44_coins.dart';
import 'package:blockchain_utils/bip/ecc/bip_ecc.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/balance/balance.dart';
import 'package:mrt_wallet/wallet/models/network/core/network/network.dart';
import 'package:mrt_wallet/wallet/models/others/models/receipt_address.dart';
import 'package:mrt_wallet/wallet/models/token/token/token.dart';
import 'package:on_chain/on_chain.dart';

enum AptosSupportKeyScheme {
  ed25519(value: 0, name: "ED25519"),
  signleKeyEd25519(value: 1, name: "ED25519 SingleKey"),
  signleKeySecp256k1(value: 2, name: "Secp256k1 SingleKey"),
  multiEd25519(value: 3, name: "Multi ED25519"),
  multiKey(value: 4, name: "MultiKey");

  final int value;
  final String name;
  bool get isMultisig => this == multiEd25519 || this == multiKey;

  const AptosSupportKeyScheme({required this.value, required this.name});
  static AptosSupportKeyScheme fromValue(int? value) {
    return values.firstWhere((e) => e.value == value,
        orElse: () => throw WalletExceptionConst.invalidData(
            messsage: "AptosSupportKeyScheme not found $value"));
  }

  AptosSigningScheme get toSigningScheme {
    return switch (this) {
      AptosSupportKeyScheme.ed25519 => AptosSigningScheme.ed25519,
      AptosSupportKeyScheme.signleKeyEd25519 ||
      AptosSupportKeyScheme.signleKeySecp256k1 =>
        AptosSigningScheme.signleKey,
      AptosSupportKeyScheme.multiEd25519 => AptosSigningScheme.multiEd25519,
      AptosSupportKeyScheme.multiKey => AptosSigningScheme.multikey,
    };
  }

  EllipticCurveTypes get curve {
    return switch (this) {
      AptosSupportKeyScheme.signleKeySecp256k1 => EllipticCurveTypes.secp256k1,
      _ => EllipticCurveTypes.ed25519
    };
  }

  static AptosSupportKeyScheme fromCoin(Bip44Coins coin) {
    return switch (coin) {
      Bip44Coins.aptos => AptosSupportKeyScheme.ed25519,
      Bip44Coins.aptosEd25519SingleKey =>
        AptosSupportKeyScheme.signleKeyEd25519,
      Bip44Coins.aptosSecp256k1SingleKey =>
        AptosSupportKeyScheme.signleKeySecp256k1,
      _ => throw WalletExceptionConst.invalidData(
          messsage: "Invalid aptos drivation coin")
    };
  }
}

class AptosTransactionFee {
  final bool isSimulate;
  final BigInt maxGasAmount;
  final BigInt gasUnitPrice;
  final IntegerBalance totalFee;
  final BigInt requiredFee;
  const AptosTransactionFee._(
      {required this.gasUnitPrice,
      required this.maxGasAmount,
      required this.totalFee,
      required this.isSimulate,
      required this.requiredFee});
  factory AptosTransactionFee(
      {BigInt? maxGasAmount,
      required BigInt gasUnitPrice,
      required WalletAptosNetwork network}) {
    final hasFee = gasUnitPrice != BigInt.zero;
    BigInt gasAmount = AptosConstants.defaultMinGasAmount;
    if (maxGasAmount != null) {
      gasAmount = (BigRational(maxGasAmount) * BigRational.parseDecimal("1.5"))
          .toBigInt();
    }
    final totalFee = IntegerBalance(
        hasFee ? gasAmount * gasUnitPrice : gasAmount, network.coinDecimal,
        imutable: true, allowNegative: false);
    return AptosTransactionFee._(
        gasUnitPrice: gasUnitPrice,
        maxGasAmount: gasAmount,
        totalFee: totalFee,
        isSimulate: maxGasAmount != null,
        requiredFee: maxGasAmount != null ? totalFee.balance : gasUnitPrice);
  }
}

class AptosOutputWithBalance with Equatable {
  AptosOutputWithBalance({
    required this.address,
    required Token token,
  }) : balance = IntegerBalance.zero(token.decimal!, allowNegative: false);
  final IntegerBalance balance;
  final ReceiptAddress<AptosAddress> address;
  bool get hasAmount => balance.largerThanZero;
  bool get isReady => hasAmount;

  void updateBalance(BigInt amount) {
    balance.updateBalance(amount);
  }

  @override
  List get variabels => [address];

  AptosTransactionEntryFunction createFTAssetTransfer(String assetType) {
    assert(balance.largerThanZero, "Invalid transfer amount.");
    return AptosTransactionEntryFunction(
        moduleId: AptosConstants.primaryFungibleStoreModule,
        functionName: AptosConstants.transferFunctionName,
        typeArgs: [
          AptosConstants.fungibleAssetMetadataTypeTag
        ],
        args: [
          AptosAddress(assetType),
          address.networkAddress,
          MoveU64(balance.balance)
        ]);
  }

  AptosTransferParams createNativeTransfer() {
    return AptosTransferParams.apt(
        apt: balance.balance, destination: address.networkAddress);
  }
}
