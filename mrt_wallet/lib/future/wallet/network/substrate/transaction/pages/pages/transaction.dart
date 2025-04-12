import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/account/pages/account_controller.dart';
import 'package:mrt_wallet/future/wallet/global/global.dart';
import 'package:mrt_wallet/future/wallet/network/substrate/metadata/fields/fields.dart';
import 'package:mrt_wallet/future/wallet/network/substrate/metadata/forms/metadata.dart';
import 'package:mrt_wallet/future/wallet/network/substrate/transaction/controller/controller/controller.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/network/forms/forms.dart';
import 'package:polkadot_dart/polkadot_dart.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';

import 'fee_info.dart';
import 'memo.dart';

class SubstrateTransactionFieldsView extends StatelessWidget {
  const SubstrateTransactionFieldsView({super.key, this.field});
  final LiveTransactionForm<SubstrateTransactionForm>? field;
  @override
  Widget build(BuildContext context) {
    final LiveTransactionForm<SubstrateTransactionForm> validator =
        field ?? context.getArgruments();
    return NetworkAccountControllerView<SubstrateChain>(
      title: validator.validator.name.tr,
      childBulder: (wallet, chain, switchAccount) =>
          MrtViewBuilder<SubstrateTransactionStateController>(
              repositoryId: StateConst.substrate,
              controller: () => SubstrateTransactionStateController(
                  walletProvider: wallet, account: chain, validator: validator),
              builder: (controller) {
                return PageProgress(
                  key: controller.progressKey,
                  backToIdle: APPConst.oneSecoundDuration,
                  initialStatus: StreamWidgetStatus.progress,
                  initialWidget: ProgressWithTextView(
                      text: 'retrieving_network_condition'.tr),
                  child: (c) => UnfocusableChild(
                    child: CustomScrollView(
                      slivers: [
                        SliverConstraintsBoxView(
                            padding: WidgetConstant.padding20,
                            sliver: SliverMainAxisGroup(slivers: [
                              SliverToBoxAdapter(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("account".tr,
                                        style: context.textTheme.titleMedium),
                                    WidgetConstant.height8,
                                    ContainerWithBorder(
                                      onRemoveIcon: Icon(Icons.edit,
                                          color: context.onPrimaryContainer),
                                      child: AddressDetailsView(
                                          address: controller.address,
                                          color: context.onPrimaryContainer,
                                          key: ValueKey<ISubstrateAddress?>(
                                              controller.address)),
                                      onRemove: () {
                                        context
                                            .openSliverBottomSheet<
                                                ISubstrateAddress>(
                                              "switch_account".tr,
                                              child: SwitchOrSelectAccountView(
                                                account: controller.account,
                                                showMultiSig: true,
                                              ),
                                              centerContent: false,
                                            )
                                            .then(switchAccount);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              _SubstrateTransactionsFields(
                                  controller: controller,
                                  validator: controller.validator),
                              // _AdditonalFields(controller)
                            ])),
                      ],
                    ),
                  ),
                );
              }),
    );
  }
}

class _AdditonalFields extends StatelessWidget {
  final SubstrateTransactionStateController controller;
  final bool showMemo;
  final bool showFee;
  const _AdditonalFields(this.controller,
      {this.showMemo = true, this.showFee = true});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (showMemo) ...[
          WidgetConstant.height20,
          SubstrateTransactionMemoView(controller)
        ],
        if (showFee) ...[
          WidgetConstant.height20,
          SubstrateTransactionFeeView(controller),
        ],
        WidgetConstant.height20,
        ErrorTextContainer(error: controller.error),
        InsufficientBalanceErrorView(
            verticalMargin: WidgetConstant.paddingVertical10,
            balance: controller.remindAmount,
            token: controller.network.coinParam.token),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FixedElevatedButton(
                padding: WidgetConstant.paddingVertical40,
                onPressed:
                    controller.trIsReady ? controller.sendTransaction : null,
                child: Text("submit_extrinsic".tr))
          ],
        )
      ]),
    );
  }
}

class _SubstrateTransactionsFields extends StatelessWidget {
  const _SubstrateTransactionsFields(
      {required this.validator, required this.controller});
  final LiveTransactionForm<SubstrateTransactionForm> validator;
  final SubstrateTransactionStateController controller;

  @override
  Widget build(BuildContext context) {
    return LiveWidget(() {
      final field = validator.value;
      return switch (field.runtimeType) {
        const (SubstrateTransferForm) => _SubstrateTransactionTransferFields(
            controller: controller, field: field),
        const (SubstrateExtersincForm) => _SubstrateTransactionExtersincFields(
            controller: controller, field: field),
        _ => const SizedBox()
      };
    });
  }
}

class _SubstrateTransactionExtersincFields extends StatelessWidget {
  const _SubstrateTransactionExtersincFields(
      {required this.field, required this.controller});
  final SubstrateExtersincForm field;
  final SubstrateTransactionStateController controller;

  @override
  Widget build(BuildContext context) {
    return APPSliverAnimatedSwitcher<ExtrinsicPage>(
        enable: field.page,
        widgets: {
          ExtrinsicPage.createPayload: (context) =>
              _CreatePayload(field: field, controller: controller),
          ExtrinsicPage.createExtrinsic: (context) =>
              _CreateExtrinsic(controller: controller, field: field),
          ExtrinsicPage.showExtrinsic: (context) =>
              _ShowFinalExtrinsic(field: field, controller: controller)
        });
  }
}

class _ShowFinalExtrinsic extends StatelessWidget {
  ExtrinsicInfo? get payload => field.extrinsicInfo;
  final SubstrateExtersincForm field;
  final SubstrateTransactionStateController controller;
  const _ShowFinalExtrinsic({required this.field, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (payload == null) return WidgetConstant.sliverSizedBox;
    return SliverMainAxisGroup(slivers: [
      SubstrateShowPayloadInfoView(
          payload: payload!.payload, onEditPayload: field.editPayload),
      SliverToBoxAdapter(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WidgetConstant.height20,
          Text("extrinsic".tr, style: context.textTheme.titleMedium),
          if (field.signedTx) Text("fake_extrinsic_signature_desc".tr),
          WidgetConstant.height8,
          ContainerWithBorder(
              child: CopyableTextWidget(
                  text: payload!.serializedExtrinsic,
                  color: context.onPrimaryContainer,
                  widget: SelectableText(payload!.serializedExtrinsic,
                      maxLines: 2,
                      minLines: 1,
                      style: context.onPrimaryTextTheme.bodyMedium),
                  maxLines: 2)),
        ],
      )),
      _AdditonalFields(controller, showMemo: false, showFee: field.signedTx),
    ]);
  }
}

class _CreateExtrinsic extends StatelessWidget {
  ExtrinsicPayloadInfo get payload => field.payloadInfo;
  List<MetadataFormValidator>? get forms => field.extrinsicValidators;
  final SubstrateExtersincForm field;
  final SubstrateTransactionStateController controller;
  const _CreateExtrinsic({required this.controller, required this.field});

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(slivers: [
      SubstrateShowPayloadInfoView(
          payload: payload, onEditPayload: field.editPayload),
      if (forms != null)
        ...forms!.map((i) => FormField(validator: (value) {
              return i.error;
            }, builder: (context) {
              return SubstrateMetadataValidatorView(
                  validator: i, account: controller.account);
            })),
      SliverToBoxAdapter(
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        FixedElevatedButton(
            padding: WidgetConstant.paddingVertical40,
            onPressed: () {
              controller.createMetadataExtrinsic();
            },
            child: Text("create_extrinsic".tr))
      ]))
    ]);
  }
}

class SubstrateShowPayloadInfoWidget extends StatelessWidget {
  final ExtrinsicPayloadInfo payload;
  final Color? color;
  final Color? primaryColor;
  const SubstrateShowPayloadInfoWidget(
      {super.key, required this.payload, this.color, this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("payload_info".tr, style: context.textTheme.titleMedium),
        WidgetConstant.height8,
        ContainerWithBorder(
            child: CopyableTextWidget(
                text: payload.payloadInfo!,
                color: context.onPrimaryContainer,
                widget: SelectableText(payload.payloadInfo!,
                    maxLines: 10,
                    magnifierConfiguration: TextMagnifierConfiguration(),
                    minLines: 1,
                    style: context.onPrimaryTextTheme.bodyMedium),
                maxLines: 10)),
        WidgetConstant.height20,
        Text("serialized_call".tr, style: context.textTheme.titleMedium),
        WidgetConstant.height8,
        ContainerWithBorder(
            // backgroundColor: context.onPrimaryContainer,
            child: CopyableTextWidget(
                text: payload.method,
                color: context.onPrimaryContainer,
                widget: Text(payload.method,
                    maxLines: 2,
                    // minLines: 1,
                    style: context.onPrimaryTextTheme.bodyMedium),
                maxLines: 2)),
        WidgetConstant.height20,
        Text("serialized_data".tr, style: context.textTheme.titleMedium),
        WidgetConstant.height8,
        ContainerWithBorder(
            // backgroundColor: context.onPrimaryContainer,
            child: CopyableTextWidget(
                text: payload.serializedExtrinsic,
                color: context.onPrimaryContainer,
                widget: SelectableText(payload.serializedExtrinsic,
                    maxLines: 2,
                    minLines: 1,
                    style: context.onPrimaryTextTheme.bodyMedium),
                maxLines: 2)),
        WidgetConstant.height20,
        ConditionalWidget(
            enable: payload.payload != payload.serializedExtrinsic,
            onActive: (context) =>
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("payload".tr, style: context.textTheme.titleMedium),
                  Text("serialized_data_hash".tr),
                  WidgetConstant.height8,
                  ContainerWithBorder(
                      // backgroundColor: context.onPrimaryContainer,
                      child: CopyableTextWidget(
                          text: payload.payload,
                          color: context.onPrimaryContainer,
                          widget: Text(payload.payload,
                              maxLines: 2,
                              style: context.onPrimaryTextTheme.bodyMedium),
                          maxLines: 2)),
                  WidgetConstant.height20,
                ])),
      ],
    );
  }
}

class SubstrateShowPayloadInfoView extends StatelessWidget {
  final ExtrinsicPayloadInfo payload;
  final DynamicVoid? onEditPayload;
  const SubstrateShowPayloadInfoView(
      {super.key, required this.payload, required this.onEditPayload});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WidgetConstant.height20,
          Text("payload".tr, style: context.textTheme.titleMedium),
          WidgetConstant.height8,
          ContainerWithBorder(
            iconAlginment: CrossAxisAlignment.start,
            onRemove: onEditPayload,
            onRemoveIcon: Icon(Icons.edit, color: context.onPrimaryContainer),
            child: APPExpansionListTile(
              title: Text("payload_info".tr,
                  style: context.onPrimaryTextTheme.bodyMedium),
              tilePadding: EdgeInsets.zero,
              children: [
                ContainerWithBorder(
                  backgroundColor: context.colors.surface,
                  child: SubstrateShowPayloadInfoWidget(payload: payload),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CreatePayload extends StatelessWidget {
  List<MetadataFormValidator> get forms => field.extrinsicPayloadValidators;
  final SubstrateExtersincForm field;
  const _CreatePayload({required this.field, required this.controller});
  final SubstrateTransactionStateController controller;
  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(slivers: [
      SliverToBoxAdapter(
        child: Column(
          children: [
            AppCheckListTile(
                contentPadding: EdgeInsets.zero,
                title: Text("unsigned_transaction".tr,
                    style: context.textTheme.titleMedium),
                subtitle: Text("unsigned_extrinsic_desc".tr),
                value: !field.signedTx,
                onChanged: field.toggleSignedTx)
          ],
        ),
      ),
      ...forms.map((i) => FormField(validator: (value) {
            return i.error;
          }, builder: (context) {
            return SubstrateMetadataValidatorView(
                validator: i, account: controller.account);
          })),
      SliverToBoxAdapter(
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Expanded(
          child: ButtonProgress(
              backToIdle: APPConst.twoSecoundDuration,
              child: (context) => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FixedElevatedButton(
                          padding: WidgetConstant.paddingVertical40,
                          onPressed: () {
                            field.createPayload();
                          },
                          child: Text("create_payload".tr)),
                    ],
                  ),
              onError: (context, result) {
                return ErrorTextContainer(
                  error: result?.tr,
                  enableTap: false,
                  oTapError: () {
                    field.createPayload();
                  },
                );
              },
              key: field.payloadProgressKey),
        )
      ]))
    ]);
  }
}

class _SubstrateTransactionTransferFields extends StatelessWidget {
  const _SubstrateTransactionTransferFields(
      {required this.controller, required this.field});
  final SubstrateTransactionStateController controller;
  final SubstrateTransferForm field;
  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(slivers: [
      SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WidgetConstant.height20,
            Text("method_name".tr, style: context.textTheme.titleMedium),
            WidgetConstant.height8,
            AppDropDownBottom(items: {
              for (final i in field.metadata.transferTypes)
                i: Text(i.name.camelCase)
            }, value: field.method, onChanged: field.onChangeTransferMethod),
            WidgetConstant.height20,
            Text("list_of_recipients".tr, style: context.textTheme.titleMedium),
            Text("amount_for_each_output".tr),
            WidgetConstant.height8,
            Column(
              children: List.generate(field.destination.value.length, (index) {
                final SubstrateOutputWithBalance receiver =
                    field.destination.value[index];
                return ContainerWithBorder(
                  iconAlginment: CrossAxisAlignment.start,
                  enableTap: false,
                  onRemoveIcon: Icon(
                    Icons.remove_circle,
                    color: context.onPrimaryContainer,
                  ),
                  validate: receiver.hasAmount,
                  onRemove: () {
                    field.onRemoveReceiver(receiver);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ContainerWithBorder(
                          backgroundColor: context.colors.onPrimaryContainer,
                          child: ReceiptAddressDetailsView(
                            address: receiver.address,
                            color: context.primaryContainer,
                          )),
                      ContainerWithBorder(
                        onRemove: () {
                          context
                              .openSliverBottomSheet<BigInt>(
                            "setup_output_amount".tr,
                            child: SetupNetworkAmount(
                              token: field.network.coinParam.token,
                              max: field.maxTransfer(
                                  account: controller.address,
                                  receiver: receiver),
                              min: BigInt.zero,
                              subtitle: PageTitleSubtitle(
                                  title: "receiver".tr,
                                  body: ContainerWithBorder(
                                      child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      OneLineTextWidget(receiver.address.view)
                                    ],
                                  ))),
                            ),
                          )
                              .then((amount) {
                            field.setBalance(
                                address: receiver, balance: amount);
                          });
                        },
                        validate: receiver.hasAmount,
                        onRemoveIcon:
                            Icon(Icons.edit, color: context.primaryContainer),
                        backgroundColor: context.onPrimaryContainer,
                        child: CoinPriceView(
                            balance: receiver.balance,
                            token: field.network.coinParam.token,
                            style: context.primaryTextTheme.titleMedium,
                            symbolColor: context.colors.primaryContainer,
                            showTokenImage: true),
                      ),
                    ],
                  ),
                );
              }),
            ),
            APPAnimatedSize(
                isActive: field.enableDestinationField,
                onActive: (context) => ContainerWithBorder(
                    validate: field.destination.hasValue,
                    onRemove: () {
                      context
                          .openSliverBottomSheet(
                        "receiver_address".tr,
                        bodyBuilder: (scrollController) =>
                            SelectRecipientAccountView<BaseSubstrateAddress>(
                                account: controller.account,
                                scrollController: scrollController,
                                multipleSelect: field.metadata.supportBatch),
                      )
                          .then(
                        (value) {
                          if (value == null) return;
                          field.setReceiver(
                              addresses:
                                  field.metadata.supportBatch ? value : [value],
                              onExists: () {
                                context.showAlert("some_addresses_exist".tr);
                              });
                        },
                      );
                    },
                    onRemoveIcon:
                        Icon(Icons.add_box, color: context.onPrimaryContainer),
                    child: Text("tap_to_add_new_receipment".tr,
                        style: context.onPrimaryTextTheme.bodyMedium)),
                onDeactive: (context) => WidgetConstant.sizedBox)
          ],
        ),
      ),
      _AdditonalFields(controller, showMemo: controller.supportMemo)
    ]);
  }
}
