import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/global/app.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/global/pages/receipt_address_view.dart';
import 'package:mrt_wallet/future/wallet/global/pages/token_details_view.dart';
import 'package:mrt_wallet/future/wallet/global/pages/transaction_amount.dart';
import 'package:mrt_wallet/future/wallet/network/ethereum/web3/pages/transaction.dart';
import 'package:mrt_wallet/future/wallet/network/forms/tron/tron.dart';
import 'package:mrt_wallet/future/wallet/network/tron/transaction/pages/pages/tron_fee_details_view.dart';
import 'package:mrt_wallet/future/wallet/network/tron/web3/controller/controller/transaction.dart';
import 'package:mrt_wallet/future/wallet/web3/pages/view_controller.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/models/network/core/network/network.dart';
import 'package:mrt_wallet/wallet/models/networks/ethereum/models/web3_transaction_infos.dart';
import 'package:mrt_wallet/wallet/models/networks/tron/tron.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';
import 'package:on_chain/tron/src/models/contract/base_contract/transaction_type.dart';

class TronWeb3TransactionFieldsView extends StatelessWidget {
  const TronWeb3TransactionFieldsView(
      {required this.wallet, super.key, required this.request});
  final Web3TronRequest<Map<String, dynamic>, Web3TronSendTransaction> request;
  final WalletProvider wallet;

  @override
  Widget build(BuildContext context) {
    return Web3PageRequestControllerView(
      controller: () => Web3TronTransactionRequestController(
          walletProvider: wallet, request: request),
      builder: (context, controller) {
        return [
          _TransactionFieldsView(
              form: controller.form as Web3TronReadOnlyForm,
              controller: controller)
        ];
      },
      request: request,
    );
  }
}

class _TransactionFieldsView extends StatelessWidget {
  const _TransactionFieldsView(
      {required this.form, required this.controller, Key? key})
      : super(key: key);
  final Web3TronTransactionRequestController controller;
  final Web3TronReadOnlyForm form;
  Web3TronTransactionInfo get info => controller.info;
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReceiptAddressView(
              address: controller.owner,
              title: "tron_owner_contract".tr,
              subtitle: "tron_owner_contract_desc".tr),
          WidgetConstant.height20,
          Text("tron_contract".tr, style: context.textTheme.titleMedium),
          Text("tron_transaction_type".tr),
          WidgetConstant.height8,
          ContainerWithBorder(
            child: Text(controller.type.name,
                style: context.colors.onPrimaryContainer.bodyMedium(context)),
          ),
          WidgetConstant.height20,
          if (info.destination != null) ...[
            ReceiptAddressView(
                address: info.destination,
                title: "destination".tr,
                subtitle: "tron_transaction_destination_desc".tr),
            WidgetConstant.height20,
          ],
          if (info.totalTrxAmount != null) ...[
            TransactionAmountView(
              amount: info.totalTrxAmount,
              subtitle: "tron_total_spent_desc".tr,
              token: controller.network.token,
            ),
            WidgetConstant.height20,
          ],
          _TransactionTypeWidgets(
            info: info,
            network: controller.network,
          ),
          WidgetConstant.height20,
          Text("transaction_fee".tr, style: context.textTheme.titleMedium),
          Text("total_burn".tr),
          WidgetConstant.height8,
          TronFeeInfoWidget(
              consumedFee: controller.consumedFee!,
              network: controller.network),
          WidgetConstant.height20,
          if (controller.feeLimit != null) ...[
            TransactionAmountView(
              amount: controller.feeLimit,
              token: controller.network.token,
              title: "fee_limit".tr,
              subtitle: "tron_fee_limit_desc".tr,
            ),
            WidgetConstant.height20
          ],
          if (controller.memo != null) ...[
            Text("memo".tr, style: context.textTheme.titleMedium),
            WidgetConstant.height8,
            ContainerWithBorder(
                child: CopyTextIcon(
                    dataToCopy: controller.memo!,
                    color: context.colors.onPrimaryContainer,
                    widget: SelectableText(controller.memo!,
                        style: context.colors.onPrimaryContainer
                            .bodyMedium(context),
                        maxLines: 3,
                        minLines: 1))),
            WidgetConstant.height20
          ],
          Text("transaction_id".tr, style: context.textTheme.titleMedium),
          WidgetConstant.height8,
          ContainerWithBorder(
              child: Text(
            controller.transaction.rawData.txID,
            style: context.colors.onPrimaryContainer.bodyMedium(context),
          )),
          InsufficientBalanceErrorView(
            verticalMargin: WidgetConstant.paddingVertical10,
            balance: controller.remindAmount.$1,
            token: controller.remindAmount.$2,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FixedElevatedButton(
                padding: WidgetConstant.paddingVertical40,
                onPressed: controller.trIsReady
                    ? () {
                        controller.confirmTransaction();
                      }
                    : null,
                child: Text("send_transaction".tr),
              )
            ],
          )
        ],
      ),
    );
  }
}

class _TransactionTypeWidgets extends StatelessWidget {
  final Web3TronTransactionInfo info;
  final WalletNetwork network;
  const _TransactionTypeWidgets(
      {required this.network, required this.info, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return switch (info.type) {
      TransactionContractType.transferContract => WidgetConstant.sizedBox,
      TransactionContractType.transferAssetContract =>
        _TransferAssetView(info: info as Web3TronTransferAssetInfo),
      TransactionContractType.freezeBalanceV2Contract =>
        _FreezeBalanceView(info: info as Web3TronFreezeBalanceInfo),
      TransactionContractType.createSmartContract =>
        _CreateContractInfo(info: info as Web3TronCreateContractInfo),
      TransactionContractType.triggerSmartContract => _TriggerSmartContractInfo(
          network: network,
          info: info as Web3TronTriggerSmartContract,
        ),
      _ => _UnknownContractInfo(info: info as Web3TronUnknowContractInfo)
    };
  }
}

class _TransferAssetView extends StatelessWidget {
  const _TransferAssetView({
    required this.info,
    this.tokenTitle,
    this.tokenSubtitle,
    this.valueSubtitle,
    Key? key,
  }) : super(key: key);
  final Web3TronTransferAssetInfo info;
  final String? tokenTitle;
  final String? tokenSubtitle;
  final String? valueSubtitle;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tokenTitle ?? "token_transfer".tr,
            style: context.textTheme.titleMedium),
        if (tokenSubtitle != null) Text(tokenSubtitle!.tr),
        WidgetConstant.height8,
        TokenDetailsView(
          token: info.token,
          onSelectWidget: WidgetConstant.sizedBox,
          radius: APPConst.circleRadius25,
        ),
        WidgetConstant.height20,
        TransactionAmountView(
          amount: info.amount,
          token: info.token.token,
          subtitle: valueSubtitle,
        ),
      ],
    );
  }
}

class _FreezeBalanceView extends StatelessWidget {
  const _FreezeBalanceView({required this.info, Key? key}) : super(key: key);
  final Web3TronFreezeBalanceInfo info;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("resource".tr, style: context.textTheme.titleMedium),
      Text("trx_stake_type".tr),
      WidgetConstant.height8,
      ContainerWithBorder(
        child: Text(info.resource.name.camelCase,
            style: context.colors.onPrimaryContainer.bodyMedium(context)),
      ),
    ]);
  }
}

class _CreateContractInfo extends StatelessWidget {
  const _CreateContractInfo({required this.info, Key? key}) : super(key: key);
  final Web3TronCreateContractInfo info;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (info.callValue != null) ...[
          _TransferAssetView(info: info.callValue!),
          WidgetConstant.height20
        ],
        Text("contract_address".tr, style: context.textTheme.titleMedium),
        WidgetConstant.height8,
        ContainerWithBorder(
            child: Text(
          info.contractAddress.toAddress(),
          style: context.colors.onPrimaryContainer.bodyMedium(context),
        ))
      ],
    );
  }
}

class _UnknownContractInfo extends StatelessWidget {
  const _UnknownContractInfo({required this.info, Key? key}) : super(key: key);
  final Web3TronUnknowContractInfo info;
  Map<String, dynamic> get data => info.contractFields;
  @override
  Widget build(BuildContext context) {
    if (info.contractFields.isEmpty) return WidgetConstant.sizedBox;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("contract_information".tr, style: context.textTheme.titleMedium),
        WidgetConstant.height8,
        ContainerWithBorder(
          padding: EdgeInsets.zero,
          child: Theme(
            data: context.theme.copyWith(
                dividerColor: context.colors.transparent,
                hoverColor: context.colors.transparent),
            child: ExpansionTile(
              title: Text("information".tr),
              shape:
                  RoundedRectangleBorder(borderRadius: WidgetConstant.border8),
              enabled: true,
              initiallyExpanded: false,
              backgroundColor: context.colors.primaryContainer,
              children: List.generate(data.length, (index) {
                final key = data.keys.elementAt(index);
                final value = data[key];
                if (value == null) return WidgetConstant.sizedBox;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ContainerWithBorder(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            key.camelCase,
                            style: context.colors.onPrimaryContainer
                                .lableLarge(context),
                          ),
                          ContainerWithBorder(
                            backgroundColor: context.colors.onPrimaryContainer,
                            constraints: null,
                            child: CopyTextIcon(
                              dataToCopy: value.toString(),
                              isSensitive: false,
                              color: context.colors.primaryContainer,
                              widget: SelectableText(
                                value.toString(),
                                style: context.colors.primaryContainer
                                    .bodyMedium(context),
                                maxLines: 4,
                                minLines: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}

class _TriggerSmartContractInfo extends StatelessWidget {
  final Web3TronTriggerSmartContract info;
  final WalletNetwork network;

  EthereumTransactionDataInfo get data => info.dataInfo;
  const _TriggerSmartContractInfo(
      {required this.info, required this.network, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (info.callValue != null) ...[
          _TransferAssetView(
            info: info.callValue!,
            tokenTitle: "tron_call_token".tr,
            tokenSubtitle: "tron_call_token_desc".tr,
            valueSubtitle: "tron_call_token_value_desc".tr,
          ),
          WidgetConstant.height20,
        ],
        Text("transaction_type".tr, style: context.textTheme.titleMedium),
        WidgetConstant.height8,
        ContainerWithBorder(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data.localizationName.tr,
                style: context.colors.onPrimaryContainer.bodyMedium(context)),
            if (data.selector != null)
              Text(data.selector!,
                  style: context.colors.onPrimaryContainer.bodyMedium(context))
          ],
        )),
        WidgetConstant.height20,
        EthereumTransactionDataWidget(
          data: data,
          network: network,
        ),
      ],
    );
  }
}
