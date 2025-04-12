import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/global/global.dart';
import 'package:mrt_wallet/future/wallet/network/cardano/transaction/controller/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/network/cardano/transaction/pages/asset_info.dart';
import 'package:mrt_wallet/future/wallet/network/cardano/transaction/pages/mint_token_view.dart';
import 'package:mrt_wallet/future/wallet/network/cardano/transaction/pages/transaction_asset_selector.dart';
import 'package:mrt_wallet/future/wallet/network/cardano/transaction/pages/memo_write_view.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:on_chain/on_chain.dart';
import 'transaction_certificate_view.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

class CardanoBuildTransactionView extends StatelessWidget {
  const CardanoBuildTransactionView({super.key, required this.controller});
  final CardanoTransactionStateController controller;
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("spendable_amount".tr, style: context.textTheme.titleMedium),
          WidgetConstant.height8,
          ContainerWithBorder(
            child: AnimatedSwitcher(
              duration: APPConst.animationDuraion,
              child: Row(
                key: ValueKey(controller.sumOfSelectedUtxo.price),
                children: [
                  Expanded(
                    child: CoinPriceView(
                        balance: controller.sumOfSelectedUtxo,
                        token: controller.network.coinParam.token,
                        style: context.onPrimaryTextTheme.titleMedium,
                        symbolColor: context.onPrimaryContainer),
                  ),
                ],
              ),
            ),
          ),
          WidgetConstant.height20,
          Text("mint".tr, style: context.textTheme.titleMedium),
          Text("create_a_new_token".tr),
          WidgetConstant.height8,
          ...List.generate(controller.mints.length, (index) {
            final assets = controller.mints[index].toUtxoAssets;
            return Column(
              children: List.generate(assets.assets.length, (pos) {
                final assetName = assets.assets.keys.toList()[pos];
                final balance = assets.assets[assetName]!;
                final toToken =
                    Token(name: assetName.name, symbol: assetName.name);
                return ContainerWithBorder(
                    onRemoveIcon: Icon(Icons.remove_circle,
                        color: context.onPrimaryContainer),
                    onRemove: () =>
                        controller.removeMint(controller.mints[index]),
                    child: CoinPriceView(
                        token: toToken,
                        balance: balance,
                        style: context.onPrimaryTextTheme.titleMedium,
                        symbolColor: context.onPrimaryContainer));
              }),
            );
          }),
          ContainerWithBorder(
            onRemoveIcon: Icon(Icons.edit, color: context.onPrimaryContainer),
            child: Text("tap_to_create_token".tr,
                style: context.onPrimaryTextTheme.bodyMedium),
            onRemove: () {
              context
                  .openSliverBottomSheet<ADAMintInfo>(
                    "mint".tr,
                    child: CardanoMintTokenView(controller.chainAccount),
                  )
                  .then(controller.setupMint);
            },
          ),
          WidgetConstant.height20,
          Text("certificates".tr, style: context.textTheme.titleMedium),
          Text("add_certificate_to_transaction".tr),
          WidgetConstant.height8,
          ...List.generate(controller.certificates.length, (index) {
            final certificate = controller.certificates[index];
            return ContainerWithBorder(
                onRemoveIcon: Icon(Icons.remove_circle,
                    color: context.onPrimaryContainer),
                onRemove: () {
                  controller.removeCertificate(certificate);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ADD
                    Text(certificate.type.viewName.tr,
                        style: context.onPrimaryTextTheme.titleMedium),
                    Divider(
                      color: context.onPrimaryContainer,
                    ),
                    ReceiptAddressDetailsView(
                      address: certificate.rewardAccount,
                      color: context.onPrimaryContainer,
                    )
                  ],
                ));
          }),
          ContainerWithBorder(
            onRemoveIcon: Icon(Icons.edit, color: context.onPrimaryContainer),
            child: Text("tap_to_add_certificate".tr,
                style: context.onPrimaryTextTheme.bodyMedium),
            onRemove: () {
              context
                  .openSliverBottomSheet<ADATransactionCertificate>(
                    "certificate".tr,
                    child: CardanoTransactionCertificateView(
                        controller.chainAccount),
                  )
                  .then(controller.addCertificate);
            },
          ),
          WidgetConstant.height20,
          Text("list_of_recipients".tr, style: context.textTheme.titleMedium),
          Text("amount_for_each_output".tr),
          WidgetConstant.height8,
          Column(
            children: List.generate(controller.receivers.length, (index) {
              final CardanoOutputWithBalance receiver =
                  controller.receivers[index];
              return ContainerWithBorder(
                iconAlginment: CrossAxisAlignment.start,
                onRemoveIcon: Icon(Icons.remove_circle,
                    color: context.onPrimaryContainer),
                validate: receiver.hasAmount,
                onRemove: () {
                  controller.removeReceiver(receiver.address);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ContainerWithBorder(
                        backgroundColor: context.onPrimaryContainer,
                        validate: !receiver.isRewardAddress,
                        validateText: "cannot_send_ada_to_stake_address".tr,
                        child: ReceiptAddressDetailsView(
                            address: receiver.address,
                            color: context.primaryContainer)),
                    ContainerWithBorder(
                      onRemove: () {
                        context
                            .openSliverBottomSheet<BigInt>(
                          "setup_output_amount".tr,
                          child: SetupNetworkAmount(
                            token: controller.network.coinParam.token,
                            max: controller.remindAmount.balance +
                                receiver.balance.balance,
                            min: receiver.minValue,
                            subtitle: PageTitleSubtitle(
                                title: "receiver".tr,
                                body: ContainerWithBorder(
                                    child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CopyableTextWidget(
                                        text: receiver.address.view,
                                        color: context.onPrimaryContainer)
                                  ],
                                ))),
                          ),
                        )
                            .then((amount) {
                          controller.setupAccountAmount(
                              receiver.address.networkAddress.address, amount);
                        });
                      },
                      validate: receiver.hasAmount,
                      onRemoveIcon:
                          Icon(Icons.edit, color: context.primaryContainer),
                      backgroundColor: context.onPrimaryContainer,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CoinPriceView(
                            balance: receiver.balance,
                            token: controller.network.coinParam.token,
                            style: context.primaryTextTheme.titleMedium,
                            symbolColor: context.primaryContainer,
                            showTokenImage: true,
                          ),
                          if (receiver.minAdaRequired)
                            ErrorTextContainer(
                                showErrorIcon: false,
                                error: "amount_must_exceed".tr.replaceOne(
                                    PriceUtils.priceWithCoinName(
                                        receiver.minAdaValue.price,
                                        controller
                                            .network.coinParam.token.symbol)))
                        ],
                      ),
                    ),
                    if (controller.hasAsset)
                      ContainerWithBorder(
                        onRemove: () {
                          context
                              .openSliverBottomSheet<UtxoMultiAsset>(
                            "setup_output_amount".tr,
                            bodyBuilder: (scrollController) =>
                                CardanoTransactionAssetSelectorView(
                                    remindAsset:
                                        controller.changeAssetOutput.asset,
                                    totalAssets: controller.totalAssets,
                                    receiver: receiver,
                                    controller: scrollController),
                          )
                              .then((asset) {
                            controller.setupAccountAsset(
                                receiver.address.view, asset);
                          });
                        },
                        onRemoveIcon: Icon(Icons.add_box,
                            color: context.primaryContainer),
                        backgroundColor: context.onPrimaryContainer,
                        child: !receiver.hasAssets
                            ? Text("tap_to_add_assets_for_recipient".tr,
                                style: context.primaryTextTheme.bodyMedium)
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "n_asset".tr.replaceOne(
                                        receiver.asset.totalAssets.toString()),
                                    style: context.primaryTextTheme.bodyMedium,
                                  ),
                                  IconButton(
                                      onPressed: () {
                                        context.openSliverDialog(
                                            (p0) => CardanoAssetsInfoView(
                                                asset: receiver.asset),
                                            "assets".tr);
                                      },
                                      icon: Icon(Icons.remove_red_eye,
                                          color: context.primaryContainer))
                                ],
                              ),
                      )
                  ],
                ),
              );
            }),
          ),
          ContainerWithBorder(
            onRemove: () {
              controller.onAddRecever(
                onSelectAddresses: (
                    {required account,
                    onFilterAccount,
                    required selectedAddresses}) {
                  return context
                      .openSliverBottomSheet<List<ReceiptAddress<ADAAddress>>>(
                    "receiver_address".tr,
                    bodyBuilder: (scrollController) =>
                        SelectRecipientAccountView<ADAAddress>(
                      account: account,
                      scrollController: scrollController,
                      multipleSelect: true,
                      onFilterAccount: onFilterAccount,
                      selectedAddresses: selectedAddresses,
                    ),
                  );
                },
                onAccountExists: (err) {
                  context.showAlert(err.tr);
                },
              );
            },
            onRemoveIcon: Icon(
              Icons.add_box,
              color: context.onPrimaryContainer,
            ),
            child: Text("tap_to_add_new_receipment".tr,
                style: context.onPrimaryTextTheme.bodyMedium),
          ),
          WidgetConstant.height20,
          Text("remaining_amount".tr, style: context.textTheme.titleMedium),
          Text("remaining_amount_and_receiver".tr),
          WidgetConstant.height8,
          ContainerWithBorder(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ContainerWithBorder(
                  // validate: !controller.remindAmount.isNegative,
                  onRemoveIcon:
                      Icon(Icons.edit, color: context.primaryContainer),
                  validate: !controller.changeADAOutput.isRewardAddress,
                  backgroundColor: context.colors.onPrimaryContainer,
                  validateText: "cannot_send_ada_to_stake_address".tr,
                  onRemove: () {
                    context
                        .openSliverBottomSheet<ICardanoAddress>(
                          "select_account".tr,
                          child: SwitchOrSelectAccountView(
                            account: controller.chainAccount,
                            showMultiSig: true,
                          ),
                          centerContent: false,
                        )
                        .then(controller.changeOutputAddress);
                  },
                  child: ReceiptAddressDetailsView(
                    address: controller.changeADAOutput.address,
                    color: context.primaryContainer,
                  )),
              ContainerWithBorder(
                  validate: !controller.remindAmount.isNegative,
                  validateText: "transaction_Insufficient_balance".tr,
                  backgroundColor: context.onPrimaryContainer,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CoinPriceView(
                        balance: controller.remindAmount,
                        token: controller.network.coinParam.token,
                        symbolColor: context.colors.primaryContainer,
                        style: context.primaryTextTheme.titleMedium,
                      ),
                      if (controller.changeADAOutput.minAdaRequired)
                        ErrorTextContainer(
                            showErrorIcon: false,
                            error: "amount_must_exceed".tr.replaceOne(
                                PriceUtils.priceWithCoinName(
                                    controller
                                        .changeADAOutput.minAdaValue.price,
                                    controller.network.coinParam.token.symbol)))
                    ],
                  )),
            ],
          )),
          if (controller.hasAsset) ...[
            APPAnimatedSize(
              duration: APPConst.animationDuraion,
              alignment: Alignment.topCenter,
              isActive: controller.changeAssetOutput.hasAssets,
              onDeactive: (context) => WidgetConstant.sizedBox,
              onActive: (context) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WidgetConstant.height20,
                  Text("remaining_asset_amount".tr,
                      style: context.textTheme.titleMedium),
                  Text("remaining_asset_amount_and_receiver".tr),
                  WidgetConstant.height8,
                  ContainerWithBorder(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ContainerWithBorder(
                          validate:
                              !controller.changeAssetOutput.isRewardAddress,
                          validateText: "cannot_send_ada_to_stake_address".tr,
                          onRemoveIcon:
                              Icon(Icons.edit, color: context.primaryContainer),
                          backgroundColor: context.onPrimaryContainer,
                          onRemove: () {
                            context
                                .openSliverBottomSheet<ICardanoAddress>(
                                  "select_account".tr,
                                  child: SwitchOrSelectAccountView(
                                    account: controller.chainAccount,
                                    showMultiSig: true,
                                  ),
                                  centerContent: false,
                                )
                                .then(controller.changeAssetOutputAddress);
                          },
                          child: ReceiptAddressDetailsView(
                            address: controller.changeAssetOutput.address,
                            color: context.primaryContainer,
                          )),
                      ContainerWithBorder(
                          backgroundColor: context.onPrimaryContainer,
                          validate: controller.changeAssetOutput.hasAmount,
                          onRemoveIcon:
                              Icon(Icons.edit, color: context.primaryContainer),
                          onRemove: () {
                            context
                                .openSliverBottomSheet<BigInt>(
                              "setup_output_amount".tr,
                              child: SetupNetworkAmount(
                                token: controller.network.coinParam.token,
                                max: controller.remindAmount.balance +
                                    controller
                                        .changeAssetOutput.balance.balance,
                                min: controller.changeAssetOutput.minValue,
                                subtitle: PageTitleSubtitle(
                                    title: "receiver".tr,
                                    body: ReceiptAddressView(
                                        title: null,
                                        address: controller
                                            .changeAssetOutput.address)),
                              ),
                            )
                                .then((amount) {
                              controller.changeAssetAdaAmount(amount);
                            });
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CoinPriceView(
                                balance: controller.changeAssetOutput.balance,
                                token: controller.network.coinParam.token,
                                symbolColor: context.primaryContainer,
                                style: context.primaryTextTheme.titleMedium,
                              ),
                              if (controller.changeAssetOutput.minAdaRequired)
                                ErrorTextContainer(
                                    showErrorIcon: false,
                                    error: "amount_must_exceed".tr.replaceOne(
                                        PriceUtils.priceWithCoinName(
                                            controller.changeAssetOutput
                                                .minAdaValue.price,
                                            controller.network.coinParam.token
                                                .symbol)))
                            ],
                          )),
                      ContainerWithBorder(
                          backgroundColor: context.onPrimaryContainer,
                          onRemove: () {
                            context.openSliverDialog(
                                (p0) => CardanoAssetsInfoView(
                                    asset: controller.changeAssetOutput.asset),
                                "assets".tr);
                          },
                          onRemoveIcon: Icon(Icons.remove_red_eye,
                              color: context.primaryContainer),
                          child: Text(
                              "n_asset".tr.replaceOne(controller
                                  .changeAssetOutput.asset.totalAssets
                                  .toString()),
                              style: context.primaryTextTheme.bodyMedium)),
                    ],
                  ))
                ],
              ),
            ),
          ],
          WidgetConstant.height20,
          Text("setup_memo".tr, style: context.textTheme.titleMedium),
          Text("memo_desc2".tr),
          WidgetConstant.height8,
          ...List.generate(controller.metadatas.length, (index) {
            final keys = controller.metadatas.keys.toList();
            final memo = controller.metadatas[keys[index]]!;
            return ContainerWithBorder(
                onRemove: () {
                  controller.onRemoveMemo(keys[index]);
                },
                onRemoveIcon: Icon(Icons.remove_circle,
                    color: context.onPrimaryContainer),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(keys[index].toString(),
                        style: context.onPrimaryTextTheme.labelLarge),
                    Text(memo.value,
                        style: context.onPrimaryTextTheme.bodyMedium),
                  ],
                ));
          }),
          ContainerWithBorder(
              onRemoveIcon:
                  Icon(Icons.add_box, color: context.onPrimaryContainer),
              onRemove: () {
                controller.addMetaData(
                  (ids, v) async {
                    final result =
                        await context.openSliverBottomSheet<(String, BigInt)>(
                      "transaction_memo".tr,
                      child: CardanoTransactionMemoWriteView(
                        labeles: ids,
                        defaultValue: v,
                        title: PageTitleSubtitle(
                            title: "setup_memo".tr,
                            body: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("memo_desc1".tr),
                                WidgetConstant.height8,
                                Text("empty_desc".tr),
                              ],
                            )),
                        buttonText: "setup_memo".tr,
                        label: "memo".tr,
                      ),
                    );
                    return result;
                  },
                );
              },
              child: Text("tap_to_add_memo".tr,
                  style: context.onPrimaryTextTheme.bodyMedium)),

          /// deposit
          APPAnimatedSize(
            duration: APPConst.animationDuraion,
            alignment: Alignment.topCenter,
            isActive: controller.hasDeposit,
            onDeactive: (context) => WidgetConstant.sizedBox,
            onActive: (context) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WidgetConstant.height20,
                Text("deposit".tr, style: context.textTheme.titleMedium),
                Text("transaction_deposits_list".tr),
                WidgetConstant.height8,
                ...List.generate(controller.deposits.length, (index) {
                  final deposit = controller.deposits[index];
                  return ContainerWithBorder(
                      child: CoinPriceView(
                    token: controller.network.coinParam.token,
                    balance: deposit.fee,
                    style: context.onPrimaryTextTheme.titleMedium,
                    symbolColor: context.onPrimaryContainer,
                  ));
                }),
              ],
            ),
          ),

          /// deposit
          APPAnimatedSize(
            duration: APPConst.animationDuraion,
            alignment: Alignment.topCenter,
            isActive: controller.hasRefundDeposit,
            onDeactive: (context) => WidgetConstant.sizedBox,
            onActive: (context) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WidgetConstant.height20,
                Text("refund_deposit".tr, style: context.textTheme.titleMedium),
                Text("transaction_deposits_list".tr),
                WidgetConstant.height8,
                ...List.generate(controller.refundDeposit.length, (index) {
                  final deposit = controller.refundDeposit[index];
                  return ContainerWithBorder(
                      child: CoinPriceView(
                    token: controller.network.coinParam.token,
                    balance: deposit.fee,
                    style: context.onPrimaryTextTheme.titleMedium,
                    symbolColor: context.onPrimaryContainer,
                  ));
                }),
              ],
            ),
          ),

          WidgetConstant.height20,
          Text("transaction_fee".tr, style: context.textTheme.titleMedium),
          Text("cost_for_transaction".tr),
          WidgetConstant.height8,
          ContainerWithBorder(
            validateText: controller.feeError?.tr,
            validate: controller.feeError == null,
            onRemove: () {
              context
                  .openSliverBottomSheet<BigInt>(
                    "setup_custom_fee".tr,
                    child: SetupNetworkAmount(
                      token: controller.network.coinParam.token,
                      max: controller.spendableAmount.balance,
                      min: BigInt.zero,
                      subtitle: PageTitleSubtitle(
                          title: "transaction_fee".tr,
                          body: Column(
                            children: [
                              Text("transaction_fee_desc3".tr),
                              WidgetConstant.height8,
                              ContainerWithBorder(
                                  child: CoinPriceView(
                                balance: controller.transactionFee,
                                token: controller.network.coinParam.token,
                                style: context.onPrimaryTextTheme.titleMedium,
                                symbolColor: context.onPrimaryContainer,
                              )),
                            ],
                          )),
                    ),
                  )
                  .then(controller.setupFee);
            },
            onRemoveIcon: Icon(Icons.edit, color: context.onPrimaryContainer),
            child: CoinPriceView(
                balance: controller.transactionFee,
                token: controller.network.coinParam.token,
                style: context.onPrimaryTextTheme.titleMedium,
                symbolColor: context.onPrimaryContainer),
          ),
          WidgetConstant.height20,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FixedElevatedButton(
                  padding: WidgetConstant.paddingVertical40,
                  onPressed: controller.trReady
                      ? controller.buildAndBroadcastTransaction
                      : null,
                  child: Text("send_transaction".tr)),
            ],
          )
        ],
      ),
    );
  }
}
