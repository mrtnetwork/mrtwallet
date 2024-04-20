import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/cardano_pages/transaction/controller/controller.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/cardano_pages/transaction/pages/cardano_transaction_asset_selector.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/cardano_pages/transaction/pages/memo_write_view.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/wallet_pages.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/wallet_models/address/network_address/cardano/cardano.dart';
import 'package:mrt_wallet/models/wallet_models/network/custom/cardano/cardano.dart';
import 'package:mrt_wallet/models/wallet_models/network/custom/cardano/utxo_multi_asset.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:on_chain/on_chain.dart';

class CardanoBuildTransactionView extends StatelessWidget {
  const CardanoBuildTransactionView({super.key, required this.controller});
  final CardanoTransactionStateController controller;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("spendable_amount".tr, style: context.textTheme.titleMedium),
        WidgetConstant.height8,
        ContainerWithBorder(
          child: AnimatedSwitcher(
            duration: AppGlobalConst.animationDuraion,
            child: Row(
              key: ValueKey(controller.sumOfSelectedUtxo.price),
              children: [
                Expanded(
                  child: CoinPriceView(
                      balance: controller.sumOfSelectedUtxo,
                      token: controller.network.coinParam.token,
                      style: context.textTheme.titleLarge),
                ),
              ],
            ),
          ),
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
              onRemoveIcon: const Icon(Icons.remove_circle),
              validate: receiver.hasAmount,
              onRemove: () {
                controller.removeReceiver(receiver.address);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ContainerWithBorder(
                      backgroundColor: context.colors.secondary,
                      child: ReceiptAddressDetailsView(
                        address: receiver.address,
                        color: context.colors.onSecondary,
                      )),
                  ContainerWithBorder(
                    onRemove: () {
                      context
                          .openSliverBottomSheet<BigInt>(
                        "setup_output_amount".tr,
                        child: SetupNetworkAmount(
                          token: controller.network.coinParam.token,
                          max: controller.remindAmount.balance +
                              receiver.balance.balance,
                          min: BigInt.zero,
                          subtitle: PageTitleSubtitle(
                              title: "receiver".tr,
                              body: ContainerWithBorder(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      receiver.address.networkAddress
                                          .addressType.name,
                                      style: context.textTheme.labelLarge),
                                  OneLineTextWidget(receiver.address.view)
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
                        Icon(Icons.edit, color: context.colors.onSecondary),
                    backgroundColor: context.colors.secondary,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CoinPriceView(
                          balance: receiver.balance,
                          token: controller.network.coinParam.token,
                          style: context.textTheme.titleLarge
                              ?.copyWith(color: context.colors.onSecondary),
                          symbolColor: context.colors.onSecondary,
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
                          bodyBuilder: (c) =>
                              CardanoTransactionAssetSelectorView(
                                  remindAsset:
                                      controller.changeAssetOutput.asset,
                                  totalAssets: controller.totalAssets,
                                  receiver: receiver,
                                  controller: c),
                        )
                            .then((asset) {
                          controller.setupAccountAsset(
                              receiver.address.view, asset);
                        });
                      },
                      onRemoveIcon: Icon(Icons.add_box,
                          color: context.colors.onSecondary),
                      backgroundColor: context.colors.secondary,
                      child: !receiver.hasAssets
                          ? Text("tap_to_add_assets_for_recipient".tr,
                              style: context.textTheme.bodyMedium
                                  ?.copyWith(color: context.colors.onSecondary))
                          : Text(
                              "n_asset".tr.replaceOne(
                                  receiver.asset.totalAssets.toString()),
                              style: context.textTheme.bodyMedium
                                  ?.copyWith(color: context.colors.onSecondary),
                            ),
                    )
                ],
              ),
            );
          }),
        ),
        ContainerWithBorder(
          validate: controller.receivers.isNotEmpty,
          onRemove: () {
            context
                .openSliverBottomSheet<ReceiptAddress<ADAAddress>>(
                    "receiver_address".tr,
                    bodyBuilder: (c) => SelectRecipientAccountView(
                        account: controller.account, scrollController: c),
                    maxExtend: 1,
                    minExtent: 0.8,
                    initialExtend: 0.9)
                .then(
              (value) {
                controller.onAddRecever(value, () {
                  context.showAlert("address_already_exist".tr);
                });
              },
            );
          },
          onRemoveIcon: const Icon(Icons.add_box),
          child: Text("tap_to_add_new_receipment".tr),
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
              validate: !controller.remindAmount.isNegative,
              onRemoveIcon: Icon(Icons.edit, color: context.colors.onSecondary),
              backgroundColor: context.colors.secondary,
              validateText: "transaction_Insufficient_balance".tr,
              onRemove: () {
                context
                    .openSliverBottomSheet<ICardanoAddress>(
                      "select_account".tr,
                      child: SwitchOrSelectAccountView(
                        account: controller.account,
                        showMultiSig: true,
                      ),
                      minExtent: 0.5,
                      maxExtend: 0.9,
                      initialExtend: 0.7,
                      centerContent: false,
                    )
                    .then(controller.changeOutputAddress);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(controller.changeADAOutput.address.type ?? "",
                      style: context.textTheme.labelLarge
                          ?.copyWith(color: context.colors.onSecondary)),
                  OneLineTextWidget(
                    controller.changeADAOutput.address.view,
                    style: context.textTheme.bodyMedium
                        ?.copyWith(color: context.colors.onSecondary),
                  )
                ],
              ),
            ),
            ContainerWithBorder(
                backgroundColor: context.colors.secondary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CoinPriceView(
                      balance: controller.remindAmount,
                      token: controller.network.coinParam.token,
                      symbolColor: context.colors.onSecondary,
                      style: context.textTheme.titleLarge
                          ?.copyWith(color: context.colors.onSecondary),
                    ),
                    if (controller.changeADAOutput.minAdaRequired)
                      ErrorTextContainer(
                          showErrorIcon: false,
                          error: "amount_must_exceed".tr.replaceOne(
                              PriceUtils.priceWithCoinName(
                                  controller.changeADAOutput.minAdaValue.price,
                                  controller.network.coinParam.token.symbol)))
                  ],
                )),
          ],
        )),
        if (controller.hasAsset) ...[
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
                validate: !controller.remindAmount.isNegative,
                onRemoveIcon:
                    Icon(Icons.edit, color: context.colors.onSecondary),
                backgroundColor: context.colors.secondary,
                validateText: "transaction_Insufficient_balance".tr,
                onRemove: () {
                  context
                      .openSliverBottomSheet<ICardanoAddress>(
                        "select_account".tr,
                        child: SwitchOrSelectAccountView(
                          account: controller.account,
                          showMultiSig: true,
                        ),
                        minExtent: 0.5,
                        maxExtend: 0.9,
                        initialExtend: 0.7,
                        centerContent: false,
                      )
                      .then(controller.changeAssetOutputAddress);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(controller.changeAssetOutput.address.type ?? "",
                        style: context.textTheme.labelLarge
                            ?.copyWith(color: context.colors.onSecondary)),
                    OneLineTextWidget(
                      controller.changeAssetOutput.address.view,
                      style: context.textTheme.bodyMedium
                          ?.copyWith(color: context.colors.onSecondary),
                    )
                  ],
                ),
              ),
              ContainerWithBorder(
                  backgroundColor: context.colors.secondary,
                  validate: controller.changeAssetOutput.hasAmount,
                  onRemoveIcon:
                      Icon(Icons.edit, color: context.colors.onSecondary),
                  onRemove: () {
                    context
                        .openSliverBottomSheet<BigInt>(
                      "setup_output_amount".tr,
                      child: SetupNetworkAmount(
                        token: controller.network.coinParam.token,
                        max: controller.remindAmount.balance +
                            controller.changeAssetOutput.balance.balance,
                        min: BigInt.zero,
                        subtitle: PageTitleSubtitle(
                            title: "receiver".tr,
                            body: ContainerWithBorder(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    controller.changeAssetOutput.address
                                        .networkAddress.addressType.name,
                                    style: context.textTheme.labelLarge),
                                OneLineTextWidget(
                                    controller.changeAssetOutput.address.view)
                              ],
                            ))),
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
                        symbolColor: context.colors.onSecondary,
                        style: context.textTheme.titleLarge
                            ?.copyWith(color: context.colors.onSecondary),
                      ),
                      if (controller.changeAssetOutput.minAdaRequired)
                        ErrorTextContainer(
                            showErrorIcon: false,
                            error: "amount_must_exceed".tr.replaceOne(
                                PriceUtils.priceWithCoinName(
                                    controller
                                        .changeAssetOutput.minAdaValue.price,
                                    controller.network.coinParam.token.symbol)))
                    ],
                  )),
              ContainerWithBorder(
                  backgroundColor: context.colors.secondary,
                  onRemove: () {
                    context.openSliverDialog(
                        (p0) => Column(
                              children: List.generate(
                                  controller.changeAssetOutput.asset.assets
                                      .length, (index) {
                                final pl = controller
                                    .changeAssetOutput.asset.assets.keys
                                    .toList()[index];
                                final assets = controller
                                    .changeAssetOutput.asset.assets[pl]!;
                                return Column(
                                  children: [
                                    Text(pl.toHex(), maxLines: 1),
                                    const Divider(),
                                    ...List.generate(assets.assets.length,
                                        (pos) {
                                      final assetName =
                                          assets.assets.keys.toList()[pos];
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            assetName.name(),
                                            style: context.textTheme.labelLarge,
                                          ),
                                          Flexible(
                                              child: CoinPriceView(
                                            token: Token(
                                                name: assetName.name(),
                                                symbol: assetName.name()),
                                            balance: assets.assets[assetName],
                                          ))
                                        ],
                                      );
                                    })
                                  ],
                                );
                              }),
                            ),
                        "assets".tr);
                  },
                  onRemoveIcon:
                      Icon(Icons.help, color: context.colors.onSecondary),
                  child: Text(
                    "n_asset".tr.replaceOne(controller
                        .changeAssetOutput.asset.totalAssets
                        .toString()),
                    style: context.textTheme.bodyMedium
                        ?.copyWith(color: context.colors.onSecondary),
                  )),
            ],
          )),
        ],
        WidgetConstant.height20,
        Text("setup_memo".tr, style: context.textTheme.titleMedium),
        Text("memo_desc2"
            .tr
            .replaceOne(controller.network.coinParam.token.name)),
        WidgetConstant.height8,
        ...List.generate(controller.metadatas.length, (index) {
          final keys = controller.metadatas.keys.toList();
          final memo = controller.metadatas[keys[index]]!;
          return ContainerWithBorder(
              onRemove: () {
                controller.onRemoveMemo(keys[index]);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(keys[index].toString(),
                      style: context.textTheme.labelLarge),
                  Text(memo.value),
                ],
              ));
        }),
        ContainerWithBorder(
            onRemoveIcon: const Icon(Icons.add_box),
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
                      buttomText: "setup_memo".tr,
                      label: "memo".tr,
                    ),
                  );
                  return result;
                },
              );
            },
            child: Text("tap_to_add_memo".tr,
                style: context.textTheme.labelLarge)),
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
                              style: context.textTheme.titleLarge,
                            )),
                          ],
                        )),
                  ),
                )
                .then(controller.setupFee);
          },
          onRemoveIcon: const Icon(Icons.edit),
          child: CoinPriceView(
            balance: controller.transactionFee,
            token: controller.network.coinParam.token,
            style: context.textTheme.titleLarge,
          ),
        ),
        WidgetConstant.height20,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FixedElevatedButton(
                onPressed:
                    controller.trReady ? controller.sendTransaction : null,
                child: Text("send_transaction".tr)),
          ],
        )
      ],
    );
  }
}
