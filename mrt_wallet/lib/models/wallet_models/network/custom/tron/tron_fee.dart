import 'package:mrt_wallet/app/utility/blockchin_utils/tron/tron_utils.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:on_chain/on_chain.dart';

enum TronFeeLimitType {
  def("default"),
  custom("custom");

  final String value;
  const TronFeeLimitType(this.value);
}

class TronFee {
  TronFee._(
      {required this.burnBandwidth,
      required this.burnEnergy,
      required this.consumedBandwidth,
      required this.connsumedEnergy,
      required this.totalBurn,
      required this.burnedForResource,
      required NoneDecimalBalance feeLimit,
      NoneDecimalBalance? custommFee})
      : _feeLimit = feeLimit,
        _customFeeLimit = custommFee;
  final int burnBandwidth;
  final int burnEnergy;

  final int consumedBandwidth;
  final int connsumedEnergy;

  late final int stackedBandWidth = consumedBandwidth - burnBandwidth;
  late final int stackedEnergy = connsumedEnergy - burnEnergy;
  final NoneDecimalBalance burnedForResource;
  final NoneDecimalBalance totalBurn;
  final NoneDecimalBalance _feeLimit;
  final NoneDecimalBalance? _customFeeLimit;
  NoneDecimalBalance get feeLimit => _customFeeLimit ?? _feeLimit;
  late final TronFeeLimitType feeLimitType =
      _customFeeLimit == null ? TronFeeLimitType.def : TronFeeLimitType.custom;
  TronFee setCustomFeeLimit({
    NoneDecimalBalance? customFeeLimit,
  }) {
    return TronFee._(
      burnBandwidth: burnBandwidth,
      burnedForResource: burnedForResource,
      burnEnergy: burnEnergy,
      consumedBandwidth: consumedBandwidth,
      connsumedEnergy: connsumedEnergy,
      totalBurn: totalBurn,
      feeLimit: _feeLimit,
      custommFee: customFeeLimit,
    );
  }

  factory TronFee.calculate(
      {required TransactionRaw raw,
      required TronChainParameters chainParameters,
      required TronAccountResourceInfo resource,
      int signature = 1,
      bool isNewAccount = false,
      int consumedEnergy = 0,
      bool hasMemo = false}) {
    final tr = Transaction(
        rawData: raw,
        signature: List.generate(signature,
            (index) => List<int>.filled(TronUtils.signatureLength, 1)));
    final BigInt transactionFee =
        BigInt.from(chainParameters.getTransactionFee!);
    final size = tr.length + TronUtils.tronFeeRequiredSize;
    BigInt totalBurn = BigInt.zero;
    BigInt energy = BigInt.from(consumedEnergy);
    BigInt bandWidth = BigInt.from(size);
    BigInt burnedForResource = BigInt.zero;
    if (isNewAccount) {
      burnedForResource += BigInt.from(chainParameters.getCreateAccountFee!);
      totalBurn +=
          BigInt.from(chainParameters.getCreateNewAccountFeeInSystemContract!);
    }
    if (hasMemo) {
      totalBurn += BigInt.from(chainParameters.getMemoFee!);
    }
    if (signature > 1) {
      totalBurn += BigInt.from(chainParameters.getMultiSignFee!);
    }
    switch (raw.contract.first.type) {
      case TransactionContractType.assetIssueContract:
        totalBurn += chainParameters.getAssetIssueFee!;
        break;
      case TransactionContractType.accountPermissionUpdateContract:
        totalBurn += chainParameters.getUpdateAccountPermissionFee!;
        break;
      case TransactionContractType.witnessCreateContract:
        totalBurn += chainParameters.getAccountUpgradeCost!;
        break;
      default:
    }
    energy = energy - resource.howManyEnergy;
    if (energy.isNegative) {
      energy = BigInt.zero;
    }

    BigInt consumedBandwidth = bandWidth;
    if (resource.howManyBandwIth > bandWidth) {
      bandWidth = BigInt.zero;
    }
    final totalBandWidth = bandWidth;
    totalBurn += totalBandWidth * transactionFee;
    totalBurn += burnedForResource;
    totalBurn += energy * BigInt.from(chainParameters.getEnergyFee!);
    BigInt feeLimit = TronHelper.toSun("10");
    if (totalBurn > feeLimit) {
      feeLimit = totalBurn;
    }

    return TronFee._(
      burnBandwidth: totalBandWidth.toInt(),
      burnEnergy: energy.toInt(),
      consumedBandwidth: consumedBandwidth.toInt(),
      connsumedEnergy: consumedEnergy,
      totalBurn: NoneDecimalBalance(totalBurn, TronUtils.decimal),
      feeLimit: NoneDecimalBalance(feeLimit, TronUtils.decimal),
      burnedForResource:
          NoneDecimalBalance(burnedForResource, TronUtils.decimal),
    );
  }

  late final bool feeLimitError = feeLimit.balance < totalBurn.balance;
}
