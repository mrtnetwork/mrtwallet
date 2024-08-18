import 'package:blockchain_utils/utils/numbers/rational/big_rational.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/network/bch/token/pages/bcmr_validate.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/crypto/utils/bitcoin_cash/bitcoin_cash_utils.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';

enum BCHCashTokenPage { build, utxo, send }

enum BitconCashTokensType {
  fungibleTokens("fungible_tokens"),
  nft("nft");

  final String value;
  const BitconCashTokensType(this.value);
}

class BchCashTokenBuilderView extends StatefulWidget {
  const BchCashTokenBuilderView({
    super.key,
    this.scrollController,
    required this.utxos,
    required this.network,
  });
  final ScrollController? scrollController;
  final List<BitcoinUtxoWithBalance> utxos;
  final WalletBitcoinNetwork network;

  @override
  State<BchCashTokenBuilderView> createState() =>
      __BchCashTokenBuilderViewState();
}

class __BchCashTokenBuilderViewState extends State<BchCashTokenBuilderView>
    with SafeState {
  String? categoryId;

  BitconCashTokensType _type = BitconCashTokensType.fungibleTokens;
  BitconCashTokensType get typeOfToken => _type;

  bool get isFt => _type == BitconCashTokensType.fungibleTokens;
  void onChangeToken(BitconCashTokensType? newType) {
    _type = newType ?? _type;
    setState(() {});
  }

  CashTokenCapability capability = CashTokenCapability.minting;
  void onChangeCapability(CashTokenCapability? newCapability) {
    capability = newCapability ?? capability;
    setState(() {});
  }

  BigRational? totalSupply;
  bool appendAuth = false;
  bool isReady = false;

  void _checkValidate() {
    isReady = categoryId != null &&
        (totalSupply != null || !isFt) &&
        (!appendAuth || (appendAuth && bcmrs.isNotEmpty));
    setState(() {});
  }

  final GlobalKey<FormState> form = GlobalKey();

  void onChangeMetaData(bool? v) {
    appendAuth = !appendAuth;
    _checkValidate();
  }

  void setTotalSupply(BigRational? supply) {
    totalSupply = null;

    if (supply != null) {
      if (supply >= BCHUtils.minimumTokenCashTotalSupply &&
          supply <= BCHUtils.maximumTokenCashTotalSupply) {
        totalSupply = supply;
      }
    }
    _checkValidate();
  }

  String? _bcmrHashError;
  Set<CashTokenBCMR> bcmrs = {};
  void onAddBCMR(CashTokenBCMR? bcmr) {
    if (bcmr == null) return;
    if (bcmrs.contains(bcmr)) {
      context.showAlert("uri_already_exist".tr);
      return;
    }
    _bcmrHashError = null;
    bcmrs.add(bcmr);
    final Set<String> hashes = bcmrs.map((e) => e.hash).toSet();
    if (hashes.length > 1) {
      _bcmrHashError = "bcmr_hash_validate_desc".tr;
    }
    _checkValidate();
  }

  void onRemoveBCMR(CashTokenBCMR? bcmr) {
    if (bcmrs.remove(bcmr)) {
      _bcmrHashError = null;
      _checkValidate();
    }
  }

  void onSetup() {
    if (!isReady) return;
    final token = BCHUtils.createCashToken(
        amount: totalSupply?.toBigInt(),
        capability: isFt ? null : capability,
        commitment: commitment,
        category: categoryId!);
    final createToken =
        CreateCashTokenInfo.withBcmrs(token: token, bcmrs: bcmrs.toList());
    context.pop(createToken);
  }

  String? capabilityForm(CashTokenCapability? capability) {
    if (capability == null) return "capability_required_desc".tr;
    return null;
  }

  String? commitment;
  void onChangeCcommitment(String? updateCommitment) {
    commitment = (updateCommitment?.isEmpty ?? true) ? null : updateCommitment;
    _checkValidate();
  }

  String? commitmentValidate(String? v) {
    if (BCHUtils.commitmentValidate(v)) {
      return null;
    }
    return "commitment_validate_desc".tr;
  }

  String? onValidateTokenId(String? v) {
    if (categoryId == null) return "token_id_validator_desc";
    return null;
  }

  void onChangeTokenId(String? v) {
    if (v == null || v == categoryId) return;
    final exists = widget.utxos.any((element) => element.utxo.txHash == v);
    if (!exists) return;
    categoryId = v;
    setState(() {});
  }

  @override
  void initState() {
    if (widget.utxos.isNotEmpty) {
      categoryId = widget.utxos.first.utxo.txHash;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("create_token".tr),
      ),
      body: ConstraintsBoxView(
        padding: WidgetConstant.paddingHorizontal20,
        child: SingleChildScrollView(
          controller: widget.scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("token_id".tr),
              Text("token_id_choose_desc".tr),
              WidgetConstant.height8,
              AppDropDownBottom(
                isExpanded: true,
                items: {
                  for (final i in widget.utxos)
                    i.utxo.txHash: OneLineTextWidget(i.utxo.txHash)
                },
                itemBuilder: {
                  for (final i in widget.utxos)
                    i.utxo.txHash: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(i.address.address.toAddress(
                            widget.network.coinParam.transacationNetwork)),
                        CoinPriceView(
                            token: widget.network.coinParam.token,
                            balance: i.balance),
                        OneLineTextWidget(i.utxo.txHash,
                            style: context.textTheme.bodySmall),
                      ],
                    )
                },
                label: "token_id".tr,
                value: categoryId,
                onChanged: onChangeTokenId,
                validator: onValidateTokenId,
              ),
              WidgetConstant.height20,
              Text("select_token_type".tr,
                  style: context.textTheme.titleMedium),
              TextAndLinkView(
                  text: "create_token_desc1".tr,
                  url: LinkConst.reviewCashToken),
              WidgetConstant.height8,
              AppDropDownBottom(
                  onChanged: onChangeToken,
                  value: typeOfToken,
                  items: {
                    for (final i in BitconCashTokensType.values)
                      i: Text(i.value.tr)
                  },
                  label: "select_token_type".tr),
              WidgetConstant.height20,
              //
              if (!isFt) ...[
                Text("capability".tr, style: context.textTheme.titleMedium),
                Text("capability_desc".tr),
                WidgetConstant.height8,
                AppDropDownBottom(
                    onChanged: onChangeCapability,
                    value: capability,
                    validator: capabilityForm,
                    items: {
                      for (final i in CashTokenCapability.values)
                        i: Text(i.name.tr)
                    },
                    label: "select_token_type".tr),
                WidgetConstant.height20,
                Text("commitment".tr, style: context.textTheme.titleMedium),
                Text("commitment_desc".tr),
                WidgetConstant.height8,
                ContainerWithBorder(
                  onRemove: () {
                    context
                        .openSliverBottomSheet<String>(
                          "create_tokens".tr,
                          child: StringWriterView(
                            defaultValue: commitment,
                            maxLength: RippleConst.maxDomainLength,
                            customForm: commitmentValidate,
                            title: PageTitleSubtitle(
                                title: "commitment".tr,
                                body: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("commitment_desc".tr),
                                    WidgetConstant.height8,
                                    Text("empty_desc".tr)
                                  ],
                                )),
                            buttonText: "setup_input".tr,
                            label: "commitment".tr,
                          ),
                        )
                        .then(onChangeCcommitment);
                  },
                  onRemoveIcon: commitment != null
                      ? const Icon(Icons.edit)
                      : const Icon(Icons.add),
                  child: Text(commitment?.orEmpty ?? "tap_to_input_value".tr,
                      maxLines: 3),
                ),
                WidgetConstant.height20
              ],

              Text("total_supply".tr, style: context.textTheme.titleMedium),
              Text("input_total_supply".tr),
              WidgetConstant.height8,
              ContainerWithBorder(
                validate: !isFt || totalSupply != null,
                onRemoveIcon: totalSupply != null
                    ? const Icon(Icons.edit)
                    : const Icon(Icons.add),
                onRemove: () {
                  context
                      .openSliverBottomSheet<BigRational>(
                        "create_tokens".tr,
                        child: NumberWriteView(
                          defaultValue: totalSupply ??
                              BCHUtils.minimumTokenCashTotalSupply,
                          allowDecimal: false,
                          max: BCHUtils.maximumTokenCashTotalSupply,
                          min: BCHUtils.minimumTokenCashTotalSupply,
                          allowSign: false,
                          title: PageTitleSubtitle(
                              title: "total_supply".tr,
                              body: Text("input_total_supply".tr)),
                          buttonText: "setup_input".tr,
                          label: "create_tokens".tr,
                        ),
                      )
                      .then(setTotalSupply);
                },
                child: Text(totalSupply?.toString().to3Digits ??
                    "tap_to_input_value".tr),
              ),
              WidgetConstant.height20,
              Text("token_meta_data".tr, style: context.textTheme.titleMedium),
              TextAndLinkView(
                  text: "cash_tokens_metadata_desc1".tr,
                  url: LinkConst.cashTokensPCMRReview),
              Text("cash_token_creation_desc1".tr),
              WidgetConstant.height8,
              AppSwitchListTile(
                value: appendAuth,
                title: Text("add_meta_data".tr),
                onChanged: onChangeMetaData,
              ),
              AnimatedSwitcher(
                duration: APPConst.animationDuraion,
                child: appendAuth
                    ? Column(
                        key: ValueKey(bcmrs.length),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          WidgetConstant.height20,
                          Text("bcmr".tr, style: context.textTheme.titleMedium),
                          Text("bcmr_hash_desc1".tr),
                          WidgetConstant.height8,
                          ...List.generate(bcmrs.length, (index) {
                            final bcmr = bcmrs.elementAt(index);
                            return ContainerWithBorder(
                              onRemove: () {
                                onRemoveBCMR(bcmr);
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("bcm_uri".tr,
                                      style: context.textTheme.labelLarge),
                                  OneLineTextWidget(bcmr.uri.toString()),
                                  WidgetConstant.height8,
                                  Text("bcmr_hash".tr,
                                      style: context.textTheme.labelLarge),
                                  OneLineTextWidget(bcmr.hash),
                                ],
                              ),
                            );
                          }),
                          ContainerWithBorder(
                            onRemoveWidget: const Icon(Icons.add_box),
                            onRemove: () {
                              context
                                  .openSliverBottomSheet<CashTokenBCMR>(
                                      "token_meta_data".tr,
                                      child: const BCMRUriValidateView())
                                  .then(onAddBCMR);
                            },
                            child: Text("tap_to_add_bcmr".tr),
                          )
                        ],
                      )
                    : WidgetConstant.sizedBox,
              ),
              ErrorTextContainer(
                  error: _bcmrHashError,
                  margin: WidgetConstant.paddingVertical20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FixedElevatedButton(
                      padding: WidgetConstant.paddingVertical20,
                      onPressed: isReady ? onSetup : null,
                      child: Text("continue".tr)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
