import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:flutter/material.dart';

import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

class SetupNetworkAmount extends StatefulWidget {
  SetupNetworkAmount(
      {super.key,
      required this.token,
      this.subtitle,
      this.subtitleText,
      this.max,
      this.min,
      this.buttonText})
      : assert(token.decimal != null);
  final Widget? subtitle;
  final String? subtitleText;
  final BigInt? max;
  final BigInt? min;
  final Token token;
  final String? buttonText;

  @override
  State<SetupNetworkAmount> createState() => _SetupNetworkAmountState();
}

class _SetupNetworkAmountState extends State<SetupNetworkAmount>
    with SafeState {
  final GlobalKey<FormState> form =
      GlobalKey<FormState>(debugLabel: "SetupNetworkAmount");
  final GlobalKey<AppTextFieldState> textFieldKey = GlobalKey();
  late final String? maxString =
      PriceUtils.tryEncodePrice(widget.max, widget.token.decimal!);
  late final String? minString =
      PriceUtils.tryEncodePrice(widget.min, widget.token.decimal!);
  late final bool enableMin = (widget.min ?? BigInt.zero) > BigInt.zero;
  String? validator(String? v) {
    if (v == null) {
      if (widget.token.decimal! == 0) {
        return "int_validator".tr;
      }
      return "decimal_int_validator".tr;
    }
    final toBigit = PriceUtils.tryDecodePrice(v, widget.token.decimal!);
    if (toBigit == null) {
      if (widget.token.decimal! == 0) {
        return "int_validator".tr;
      }
      return "decimal_int_validator".tr;
    }
    if (widget.max != null && toBigit > widget.max!) {
      return "price_less_than".tr.replaceOne(
          PriceUtils.priceWithCoinName(maxString!, widget.token.symbolView));
    } else if (widget.min != null && toBigit < widget.min!) {
      return "price_greather_than".tr.replaceOne(
          PriceUtils.priceWithCoinName(minString!, widget.token.symbolView));
    }
    return null;
  }

  late String price = widget.token.decimal! > 0 ? "0.0" : "0";
  bool isMax = false;
  bool isMin = false;
  void onChanged(String v) {
    price = v;
    if (widget.max == null && !enableMin) return;
    final toBigit =
        PriceUtils.tryDecodePrice<BigInt?>(price, widget.token.decimal!);
    final equal = toBigit == widget.max;
    if (equal != isMax) {
      setState(() {
        isMax = equal;
      });
    }
    if (enableMin) {
      final equalMin = toBigit == widget.min;
      if (isMin != equalMin) {
        setState(() {
          isMin = equalMin;
        });
      }
    }
  }

  void onTapMax() {
    final p = PriceUtils.tryEncodePrice(widget.max, widget.token.decimal!);
    if (p != null) {
      textFieldKey.currentState?.updateText(p);
    }
  }

  void onTapMin() {
    final p = PriceUtils.tryEncodePrice(widget.min, widget.token.decimal!);
    if (p != null) {
      textFieldKey.currentState?.updateText(p);
    }
  }

  void onSetup() {
    if (!(form.currentState?.validate() ?? false)) return;
    final BigInt? toBigit =
        PriceUtils.tryDecodePrice(price, widget.token.decimal!);
    if (toBigit == null) return;
    if (mounted) {
      context.pop(toBigit);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.subtitle != null || widget.subtitleText != null)
            widget.subtitle ?? Text(widget.subtitleText ?? ""),
          WidgetConstant.height20,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  CircleTokenImgaeView(widget.token, radius: 60),
                  OneLineTextWidget(widget.token.nameView,
                      style: context.textTheme.labelLarge)
                ],
              ),
            ],
          ),
          WidgetConstant.height20,
          Theme(
            data: context.theme.copyWith(
              inputDecorationTheme: InputDecorationTheme(
                  border: OutlineInputBorder(
                borderRadius: WidgetConstant.border25,
              )),
            ),
            child: Align(
              alignment: Alignment.center,
              child: ConstraintsBoxView(
                maxWidth: 350,
                child: Column(
                  children: [
                    AppTextField(
                      key: textFieldKey,
                      style: context.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                      keyboardType: TextInputType.numberWithOptions(
                          decimal: widget.token.decimal! > 0, signed: false),
                      textAlign: TextAlign.center,
                      validator: validator,
                      initialValue: price,
                      onChanged: onChanged,
                      prefixIcon: const SizedBox(width: 40),
                      suffixIcon: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 50,
                            child: OneLineTextWidget(
                              widget.token.symbolView,
                              style: context.textTheme.labelLarge?.copyWith(
                                  color: context.colors.primary,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.max != null || enableMin) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (enableMin) ...[
                            FilledButton(
                              onPressed: onTapMin,
                              style: TextButton.styleFrom(
                                  backgroundColor: isMin
                                      ? context.colors.errorContainer
                                      : Colors.transparent,
                                  foregroundColor: isMin
                                      ? context.colors.onErrorContainer
                                      : context.colors.onBackground,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: WidgetConstant.border8)),
                              child: Text("min".tr),
                            ),
                            if (widget.max != null) WidgetConstant.width8,
                          ],
                          if (widget.max != null)
                            FilledButton(
                              onPressed: onTapMax,
                              style: TextButton.styleFrom(
                                  backgroundColor: isMax
                                      ? context.colors.errorContainer
                                      : Colors.transparent,
                                  foregroundColor: isMax
                                      ? context.colors.onErrorContainer
                                      : context.colors.onBackground,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: WidgetConstant.border8)),
                              child: Text("max".tr),
                            ),
                        ],
                      )
                    ],
                  ],
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FixedElevatedButton(
                  padding: WidgetConstant.paddingVertical20,
                  onPressed: onSetup,
                  child: Text(widget.buttonText ?? "setup_output_amount".tr))
            ],
          )
        ],
      ),
    );
  }
}

class SetupDecimalTokenAmountView extends StatefulWidget {
  const SetupDecimalTokenAmountView(
      {super.key,
      required this.token,
      this.subtitle,
      this.subtitleText,
      this.max,
      this.min,
      this.buttonText});
  final Widget? subtitle;
  final String? subtitleText;
  final BigRational? max;
  final BigRational? min;
  final String? buttonText;
  final Token token;

  @override
  State<SetupDecimalTokenAmountView> createState() =>
      _SetupDecimalTokenAmountViewState();
}

class _SetupDecimalTokenAmountViewState
    extends State<SetupDecimalTokenAmountView> with SafeState {
  final GlobalKey<FormState> form =
      GlobalKey<FormState>(debugLabel: "SetupNetworkAmount");
  late final String? maxString = widget.max?.toDecimal();
  late final String? minString = widget.min?.toDecimal();
  String? validator(String? v) {
    if (v == null) return "decimal_int_validator".tr;
    final rational = BigRational.tryParseDecimaal(v);
    if (rational == null) {
      return "decimal_int_validator".tr;
    }
    if (widget.max != null && rational > widget.max!) {
      return "price_less_than".tr.replaceOne(
          PriceUtils.priceWithCoinName(maxString!, widget.token.symbol));
    } else if (widget.min != null && rational < widget.min!) {
      return "price_greather_than".tr.replaceOne(
          PriceUtils.priceWithCoinName(minString!, widget.token.symbol));
    }
    return null;
  }

  String price = "0.0";
  void onChaanged(String v) {
    price = v;
  }

  void onSetup() {
    if (!(form.currentState?.validate() ?? false)) return;
    final rational = BigRational.tryParseDecimaal(price);
    if (rational == null) return;
    if (mounted) {
      context.pop(rational);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.subtitle != null || widget.subtitleText != null)
            widget.subtitle ?? Text(widget.subtitleText ?? ""),
          WidgetConstant.height20,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  CircleTokenImgaeView(widget.token, radius: 60),
                  Row(
                    children: [
                      Flexible(
                          flex: 3,
                          child: Text(widget.token.name,
                              style: context.textTheme.labelLarge)),
                    ],
                  )
                ],
              ),
            ],
          ),
          WidgetConstant.height20,
          Theme(
            data: context.theme.copyWith(
              inputDecorationTheme: InputDecorationTheme(
                  border: OutlineInputBorder(
                borderRadius: WidgetConstant.border25,
              )),
            ),
            child: Align(
              alignment: Alignment.center,
              child: ConstraintsBoxView(
                maxWidth: 350,
                child: AppTextField(
                  style: context.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true, signed: false),
                  textAlign: TextAlign.center,
                  inputFormatters: [
                    BigRetionalRangeTextInputFormatter(
                        min: widget.min,
                        max: null,
                        allowSign: false,
                        allowDecimal: true),
                  ],
                  validator: validator,
                  initialValue: price,
                  onChanged: onChaanged,
                  suffixIcon: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: WidgetConstant.padding20,
                        child: Text(
                          widget.token.symbol,
                          style: context.textTheme.labelLarge?.copyWith(
                              color: context.colors.primary,
                              fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FixedElevatedButton(
                  padding: WidgetConstant.paddingVertical20,
                  onPressed: onSetup,
                  child: Text(widget.buttonText ?? "setup_output_amount".tr))
            ],
          )
        ],
      ),
    );
  }
}
