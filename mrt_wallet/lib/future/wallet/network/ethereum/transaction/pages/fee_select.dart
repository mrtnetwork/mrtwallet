import 'package:blockchain_utils/utils/numbers/rational/big_rational.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/text_field/input_formaters.dart';
import 'package:mrt_wallet/future/wallet/network/ethereum/transaction/controller/impl/fee_impl.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/crypto/utils/ethereum/utils.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';

typedef _OnCustomFee = Future<EthereumFee?> Function(EthereumFee);

class ETHEip1559GasViewSelectView extends StatefulWidget {
  const ETHEip1559GasViewSelectView({super.key, required this.transaction});
  final ETHTransactionFeeImpl transaction;

  @override
  State<ETHEip1559GasViewSelectView> createState() =>
      _ETHEip1559GasViewSelectViewState();
}

class _ETHEip1559GasViewSelectViewState
    extends State<ETHEip1559GasViewSelectView> with SafeState {
  late final Map<EIP1559FeeSpeed, EthereumFee?> fees =
      Map.from(widget.transaction.fees.cast());
  late EIP1559FeeSpeed speed = widget.transaction.feeSpeed;
  void onChanged(EIP1559FeeSpeed? select, _OnCustomFee onCustomFee) async {
    if (select == null) return;
    if (select == EIP1559FeeSpeed.customFee) {
      final customFee = await onCustomFee(fees[speed]!);
      if (customFee != null) {
        fees[select] = customFee;
        speed = select;
        setupFee();
      }
    } else if (speed == select) {
      return;
    } else {
      speed = select;
      setupFee();
    }
  }

  void updateListener() async {
    for (final i in widget.transaction.fees.entries) {
      if (i.key == EIP1559FeeSpeed.customFee) continue;
      fees[i.key] = i.value;
    }
    setState(() {});
  }

  @override
  void dispose() {
    widget.transaction.removeListener(null, updateListener);

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    widget.transaction.addListener(null, updateListener);
  }

  void setupFee() async {
    setState(() {});
    await MethodUtils.wait(milliseconds: 250);
    if (!context.mounted) return;
    // ignore: use_build_context_synchronously
    context.pop((speed, fees[EIP1559FeeSpeed.customFee]));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: APPConst.animationDuraion,
      child: Column(
        key: ValueKey(widget.transaction.updatingGas),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...List.generate(fees.length, (index) {
            final key = fees.keys.elementAt(index);
            return AppRadioListTile(
              value: key,
              groupValue: speed,
              onChanged: (value) {
                onChanged(
                  value,
                  (p0) async {
                    if (!mounted) return null;
                    if (widget.transaction.network.coinParam.supportEIP1559) {
                      return context.openSliverBottomSheet<EthereumFee>(
                          "transaction_fee",
                          child: _ETHEip1559CustomGasViewSelectView(
                            fees: fees,
                            initialFee: speed,
                            networkToken:
                                widget.transaction.network.coinParam.token,
                          ));
                    }
                    return context.openSliverBottomSheet<EthereumFee>(
                        "transaction_fee",
                        child: _ETHLegacyCustomGasViewSelectView(
                          fees: fees,
                          initialFee: speed,
                          networkToken:
                              widget.transaction.network.coinParam.token,
                        ));
                  },
                );
              },
              title: Text(key.value.tr),
              subtitle: fees[key] == null
                  ? null
                  : CoinPriceView(
                      token: widget.transaction.network.coinParam.token,
                      balance: fees[key]!.fee,
                      style: context.textTheme.titleMedium),
            );
          }),
        ],
      ),
    );
  }
}

class _ETHEip1559CustomGasViewSelectView extends StatefulWidget {
  const _ETHEip1559CustomGasViewSelectView({
    required this.fees,
    required this.initialFee,
    required this.networkToken,
  });
  final Map<EIP1559FeeSpeed, EthereumFee?> fees;
  final EIP1559FeeSpeed initialFee;
  final Token networkToken;

  @override
  State<_ETHEip1559CustomGasViewSelectView> createState() =>
      _ETHEip1559CustomGasViewSelectViewState();
}

class _ETHEip1559CustomGasViewSelectViewState
    extends State<_ETHEip1559CustomGasViewSelectView> with SafeState {
  final GlobalKey<FormState> formKey = GlobalKey();
  late EthereumFee initialFee = widget.fees[widget.initialFee]!;
  late final BigRational initialMaxFee =
      EthereumUtils.weiToGwei(initialFee.maxFeePerGas!);
  late final BigRational initialMaxPriority =
      EthereumUtils.weiToGwei(initialFee.maxPriorityFeePerGas!);
  late final int initialGasLimit = initialFee.gasLimit;

  /// low
  late final BigRational lowMaxFee =
      EthereumUtils.weiToGwei(widget.fees[EIP1559FeeSpeed.slow]!.maxFeePerGas!);
  late final BigRational lowProrityFee = EthereumUtils.weiToGwei(
      widget.fees[EIP1559FeeSpeed.slow]!.maxPriorityFeePerGas!);

  /// hight
  late final BigRational highMaxFee =
      EthereumUtils.weiToGwei(widget.fees[EIP1559FeeSpeed.high]!.maxFeePerGas!);
  late final BigRational highProrityFee = EthereumUtils.weiToGwei(
      widget.fees[EIP1559FeeSpeed.high]!.maxPriorityFeePerGas!);

  BigRational? priorityFee;
  BigRational? maxGasFee;
  int? gasLimit;

  ///
  String? gasLimitHelper;
  String? gasPriceHelper;
  String? gasProrityHelper;
  void onChangeGasLimit(String v) {
    final valid = validateGasLimit(v);
    if (valid != null) {
      gasLimit = null;
      return;
    }
    final val = int.parse(v);
    if (val < widget.fees[EIP1559FeeSpeed.slow]!.gasLimit) {
      gasLimitHelper = "gas_limit_helper".tr;
    } else {
      gasLimitHelper = null;
    }
    gasLimit = val;
    onChangeFee();
  }

  void onChangeGasPrice(String v) {
    final valid = validatorBaseGass(v);
    if (valid != null) {
      maxGasFee = null;
      return;
    }
    final val = BigRational.parseDecimal(v);
    if (val < lowMaxFee) {
      gasPriceHelper = "max_base_fee_helper1".tr;
    } else if (val > highMaxFee) {
      gasPriceHelper = "max_base_fee_helper2".tr;
    } else {
      gasPriceHelper = null;
    }
    maxGasFee = val;
    onChangeFee();
  }

  void onChangeProrityFee(String v) {
    final valid = validateProrityFee(v);
    if (valid != null) {
      priorityFee = null;
      return;
    }
    final val = BigRational.parseDecimal(v);

    if (val < lowProrityFee) {
      gasProrityHelper = "max_priority_helper1".tr;
    } else if (val > highProrityFee) {
      gasProrityHelper = "max_priority_helper2".tr;
    } else {
      gasProrityHelper = null;
    }
    priorityFee = val;
    onChangeFee();
  }

  String? validateGasLimit(String? v) {
    final val = int.tryParse(v ?? "");
    if (val == null || val <= 0) {
      return "gas_limit_validator".tr;
    }
    return null;
  }

  String? validateProrityFee(String? v) {
    final val = BigRational.tryParseDecimaal(v ?? "");

    if (val?.isNegative ?? true) {
      return "prority_fee_validator".tr;
    }
    return null;
  }

  String? validatorBaseGass(String? v) {
    final val = BigRational.tryParseDecimaal(v ?? "");
    if (val?.isNegative ?? true) {
      return "max_base_fee_validator".tr;
    }
    return null;
  }

  void onChangeFee() {
    final maxPriorityFeePerGas = priorityFee == null
        ? initialFee.maxPriorityFeePerGas!
        : EthereumUtils.gWeiDeciamlToWei(priorityFee!);
    final maxBaseFee = maxGasFee == null
        ? initialFee.maxFeePerGas!
        : EthereumUtils.gWeiDeciamlToWei(maxGasFee!);
    initialFee = EthereumFee.eip1559(
        gasLimit ?? initialGasLimit, maxPriorityFeePerGas, maxBaseFee);
    setState(() {});
  }

  void setupFee() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    context.pop(initialFee);
  }

  ///

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageTitleSubtitle(
              title: "eip_1559_gas_fee".tr, body: Text("eth_fee_desc".tr)),
          Text("transaction_fee".tr),
          WidgetConstant.height8,
          ContainerWithBorder(
            onRemoveWidget: WidgetConstant.sizedBox,
            onRemove: () {},
            child: CoinPriceView(
                token: widget.networkToken,
                balance: initialFee.fee,
                style: context.textTheme.titleLarge),
          ),
          WidgetConstant.height20,
          Text("max_base_fee".tr, style: context.textTheme.titleMedium),
          Text("what_is_max_fee".tr, style: context.textTheme.bodyMedium),
          WidgetConstant.height8,
          AppTextField(
            label: "max_base_fee".tr,
            minlines: 1,
            maxLines: 2,
            initialValue: initialMaxFee.toDecimal(),
            keyboardType: const TextInputType.numberWithOptions(
                decimal: true, signed: false),
            inputFormatters: [
              BigRetionalRangeTextInputFormatter(
                max: null,
                min: BigRational.zero,
                allowDecimal: true,
              ),
            ],
            textAlign: TextAlign.center,
            validator: validatorBaseGass,
            onChanged: onChangeGasPrice,
            helperText: gasPriceHelper,
            helperStyle: context.textTheme.bodyMedium
                ?.copyWith(color: context.colors.orange),
            suffixIcon: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: WidgetConstant.padding20,
                  child: Text(
                    "gwei".tr,
                    style: context.textTheme.labelLarge?.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),
          WidgetConstant.height20,
          Text("max_priority".tr, style: context.textTheme.titleMedium),
          Text("what_is_prority_fee".tr, style: context.textTheme.bodyMedium),
          WidgetConstant.height8,
          AppTextField(
            label: "max_priority".tr,
            minlines: 1,
            maxLines: 2,
            initialValue: initialMaxPriority.toDecimal(),
            keyboardType: const TextInputType.numberWithOptions(
                decimal: true, signed: false),
            inputFormatters: [
              BigRetionalRangeTextInputFormatter(
                max: null,
                min: BigRational.zero,
                allowDecimal: true,
              ),
            ],
            textAlign: TextAlign.center,
            validator: validateProrityFee,
            onChanged: onChangeProrityFee,
            helperText: gasProrityHelper,
            helperStyle: context.textTheme.bodyMedium
                ?.copyWith(color: context.colors.orange),
            suffixIcon: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: WidgetConstant.padding20,
                  child: Text(
                    "gwei".tr,
                    style: context.textTheme.labelLarge?.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),
          WidgetConstant.height20,
          Text("gas_limit".tr, style: context.textTheme.titleMedium),
          Text("gas_limit_desc".tr),
          WidgetConstant.height8,
          AppTextField(
            label: "gas_limit".tr,
            minlines: 1,
            helperStyle: context.textTheme.bodyMedium
                ?.copyWith(color: context.colors.orange),
            maxLines: 2,
            initialValue: initialGasLimit.toString(),
            validator: validateGasLimit,
            onChanged: onChangeGasLimit,
            keyboardType: const TextInputType.numberWithOptions(
                decimal: true, signed: false),
            helperText: gasLimitHelper,
            inputFormatters: [
              BigRetionalRangeTextInputFormatter(
                max: null,
                min: BigRational.zero,
                allowDecimal: false,
              ),
            ],
            textAlign: TextAlign.center,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FixedElevatedButton(
                padding: WidgetConstant.paddingVertical20,
                onPressed: setupFee,
                child: Text("setup_custom_fee".tr),
              )
            ],
          )
        ],
      ),
    );
  }
}

class _ETHLegacyCustomGasViewSelectView extends StatefulWidget {
  const _ETHLegacyCustomGasViewSelectView({
    required this.fees,
    required this.initialFee,
    required this.networkToken,
  });
  final Map<EIP1559FeeSpeed, EthereumFee?> fees;
  final EIP1559FeeSpeed initialFee;
  final Token networkToken;

  @override
  State<_ETHLegacyCustomGasViewSelectView> createState() =>
      __ETHLegacyCustomGasViewSelectViewState();
}

class __ETHLegacyCustomGasViewSelectViewState
    extends State<_ETHLegacyCustomGasViewSelectView> with SafeState {
  final GlobalKey<FormState> formKey = GlobalKey();
  late EthereumFee initialFee = widget.fees[widget.initialFee]!;
  late final BigRational initialGasPrice =
      EthereumUtils.weiToGwei(initialFee.gasPrice!);
  late final int initialGasLimit = initialFee.gasLimit;

  /// low
  late final BigRational lowGasPrice =
      EthereumUtils.weiToGwei(widget.fees[EIP1559FeeSpeed.normal]!.gasPrice!);

  /// hight
  late final BigRational hightGasPrice =
      EthereumUtils.weiToGwei(widget.fees[EIP1559FeeSpeed.normal]!.gasPrice!);

  BigRational? gasPrice;
  int? gasLimit;

  ///
  String? gasLimitHelper;
  String? gasPriceHelper;
  String? gasProrityHelper;
  void onChangeGasLimit(String v) {
    final valid = validateGasLimit(v);
    if (valid != null) {
      gasLimit = null;
      return;
    }
    final val = int.parse(v);
    if (val < widget.fees[EIP1559FeeSpeed.normal]!.gasLimit) {
      gasLimitHelper = "gas_limit_helper".tr;
    } else {
      gasLimitHelper = null;
    }
    gasLimit = val;
    onChangeFee();
  }

  void onChangeGasPrice(String v) {
    final valid = validatorBaseGass(v);
    if (valid != null) {
      gasPrice = null;
      return;
    }
    final val = BigRational.parseDecimal(v);
    if (val < lowGasPrice) {
      gasPriceHelper = "gas_price_fee_helper1".tr;
    } else if (val > hightGasPrice) {
      gasPriceHelper = "gas_price_fee_helper2".tr;
    } else {
      gasPriceHelper = null;
    }
    gasPrice = val;
    onChangeFee();
  }

  String? validateGasLimit(String? v) {
    final val = int.tryParse(v ?? "");
    if (val == null || val <= 0) {
      return "gas_limit_validator".tr;
    }
    return null;
  }

  String? validatorBaseGass(String? v) {
    final val = BigRational.tryParseDecimaal(v ?? "");
    if (val?.isNegative ?? true) {
      return "gas_price_fee_validator".tr;
    }
    return null;
  }

  void onChangeFee() {
    final gPrice = gasPrice == null
        ? initialFee.gasPrice!
        : EthereumUtils.gWeiDeciamlToWei(gasPrice!);
    initialFee = EthereumFee.legacy(gasLimit ?? initialGasLimit, gPrice);
    setState(() {});
  }

  void setupFee() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    context.pop(initialFee);
  }

  ///

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageTitleSubtitle(
              title: "legacy_gas_fee".tr, body: Text("eth_legacy_fee_desc".tr)),
          Text("transaction_fee".tr),
          WidgetConstant.height8,
          ContainerWithBorder(
            onRemoveWidget: WidgetConstant.sizedBox,
            onRemove: () {},
            child: CoinPriceView(
                token: widget.networkToken,
                balance: initialFee.fee,
                style: context.textTheme.titleLarge),
          ),
          WidgetConstant.height20,
          Text("gas_price".tr, style: context.textTheme.titleMedium),
          WidgetConstant.height8,
          AppTextField(
            label: "gas_price".tr,
            minlines: 1,
            maxLines: 2,
            initialValue: initialGasPrice.toDecimal(),
            keyboardType: const TextInputType.numberWithOptions(
                decimal: true, signed: false),
            inputFormatters: [
              BigRetionalRangeTextInputFormatter(
                max: null,
                min: BigRational.zero,
                allowDecimal: true,
              ),
            ],
            textAlign: TextAlign.center,
            validator: validatorBaseGass,
            onChanged: onChangeGasPrice,
            helperText: gasPriceHelper,
            helperStyle: context.textTheme.bodyMedium
                ?.copyWith(color: context.colors.orange),
            suffixIcon: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: WidgetConstant.padding20,
                  child: Text(
                    "gwei".tr,
                    style: context.textTheme.labelLarge?.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),
          WidgetConstant.height20,
          Text("gas_limit".tr, style: context.textTheme.titleMedium),
          Text("gas_limit_desc".tr),
          WidgetConstant.height8,
          AppTextField(
            label: "gas_limit".tr,
            minlines: 1,
            helperStyle: context.textTheme.bodyMedium
                ?.copyWith(color: context.colors.orange),
            maxLines: 2,
            initialValue: initialGasLimit.toString(),
            validator: validateGasLimit,
            onChanged: onChangeGasLimit,
            keyboardType: const TextInputType.numberWithOptions(
                decimal: true, signed: false),
            helperText: gasLimitHelper,
            inputFormatters: [
              BigRetionalRangeTextInputFormatter(
                max: null,
                min: BigRational.zero,
                allowDecimal: false,
              ),
            ],
            textAlign: TextAlign.center,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FixedElevatedButton(
                padding: WidgetConstant.paddingVertical20,
                onPressed: setupFee,
                child: Text("setup_custom_fee".tr),
              )
            ],
          )
        ],
      ),
    );
  }
}
