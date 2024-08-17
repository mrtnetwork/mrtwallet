import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/global/pages/receipt_address_view.dart';
import 'package:mrt_wallet/future/wallet/global/pages/token_details_view.dart';
import 'package:mrt_wallet/future/wallet/network/ethereum/transaction/pages/gas_fee.dart';
import 'package:mrt_wallet/future/wallet/network/ethereum/web3/controller/controller/transaction.dart';
import 'package:mrt_wallet/future/wallet/web3/web3.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';

class EthereumWeb3TransactionFieldsView extends StatelessWidget {
  const EthereumWeb3TransactionFieldsView(
      {required this.wallet, super.key, required this.request});
  final Web3EthereumRequest<String, Web3EthreumSendTransaction> request;
  final WalletProvider wallet;
  @override
  Widget build(BuildContext context) {
    return Web3PageRequestControllerView<
            Web3EthereumTransactionRequestController>(
        request: request,
        controller: () => Web3EthereumTransactionRequestController(
            walletProvider: wallet, request: request),
        builder: (context, controller) {
          return [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ETHTransactionTransferFields(
                    field: controller.transactionInfos,
                    controller: controller,
                  ),
                  WidgetConstant.height20,
                  EthereumGasFeeView(transaction: controller),
                  WidgetConstant.height20,
                  InsufficientBalanceErrorView(
                    verticalMargin: WidgetConstant.paddingVertical10,
                    balance: controller.remindAmount.$1,
                    token: controller.remindAmount.$2,
                  ),
                  ErrorTextContainer(
                      error: controller.error,
                      verticalMargin: WidgetConstant.paddingVertical10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FixedElevatedButton(
                        padding: WidgetConstant.paddingVertical20,
                        onPressed: controller.trIsReady
                            ? controller.sedTransaction
                            : null,
                        child: Text("send_transaction".tr),
                      )
                    ],
                  )
                ],
              ),
            )
          ];
        });
  }
}

class _ETHTransactionTransferFields extends StatelessWidget {
  const _ETHTransactionTransferFields(
      {required this.field, required this.controller});
  final Web3EthereumTransactionRequestInfos field;
  final Web3EthereumTransactionRequestController controller;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Transaction Amount", style: context.textTheme.titleMedium),
        WidgetConstant.height8,
        ContainerWithBorder(
            child: CoinPriceView(
                token: controller.network.token,
                balance: field.value,
                style: context.textTheme.titleLarge,
                showTokenImage: true)),
        WidgetConstant.height20,
        if (field.destination?.networkAddress != null) ...[
          ReceiptAddressView(
              address: field.destination,
              title: field.isContract ? "contract".tr : "recipient".tr),
          WidgetConstant.height20,
        ],
        _EthereumTransactionDataView(data: field.dataInfo),
      ],
    );
  }
}

class _EthereumTransactionDataView extends StatelessWidget {
  const _EthereumTransactionDataView({required this.data, Key? key})
      : super(key: key);
  final EthereumTransactionDataInfo? data;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("transaction_type".tr, style: context.textTheme.titleMedium),
        WidgetConstant.height8,
        ContainerWithBorder(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data?.localizationName.tr ?? "transfer".tr,
                style: context.colors.onPrimaryContainer.bodyMedium(context)),
            if (data?.selector != null)
              Text(data!.selector!,
                  style: context.colors.onPrimaryContainer.bodyMedium(context))
          ],
        )),
        if (data != null) ...[
          WidgetConstant.height20,
          _EthereumTransactionDataWidget(data: data!)
        ],
      ],
    );
  }
}

class _EthereumTransactionDataWidget extends StatelessWidget {
  const _EthereumTransactionDataWidget({required this.data, Key? key})
      : super(key: key);
  final EthereumTransactionDataInfo data;
  @override
  Widget build(BuildContext context) {
    switch (data.type) {
      case SolidityMethodInfoTypes.creationContract:
      case SolidityMethodInfoTypes.unknown:
        return WidgetConstant.sizedBox;
      case SolidityMethodInfoTypes.unknownData:
        return _UnknownTransactionDataView(data: data.cast());
      case SolidityMethodInfoTypes.erc20:
      case SolidityMethodInfoTypes.erc20Transfer:
        return _EthereumTransactionERC20DataWidget(data: data.cast());
      case SolidityMethodInfoTypes.nameAndInputs:
        return _EthereumTransactionNameAndInputsWidget(data: data.cast());
      default:
        throw UnimplementedError("unknow data infos.");
    }
  }
}

class _EthereumTransactionNameAndInputsWidget extends StatelessWidget {
  const _EthereumTransactionNameAndInputsWidget({required this.data, Key? key})
      : super(key: key);
  final SolidityNameAndInputValues data;
  @override
  Widget build(BuildContext context) {
    return ContainerWithBorder(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "method_name".tr,
          style: context.colors.onPrimaryContainer.titleMedium(context),
        ),
        WidgetConstant.height8,
        ContainerWithBorder(
          constraints: null,
          backgroundColor: context.colors.onPrimaryContainer,
          child: Text(
            data.localizationName.tr,
            style: context.colors.primaryContainer.bodyMedium(context),
          ),
        ),
        WidgetConstant.height20,
        Text("inputs".tr,
            style: context.colors.onPrimaryContainer.titleMedium(context)),
        WidgetConstant.height8,
        ...List.generate(data.inputs.length, (i) {
          final value = data.inputs[i];
          return ContainerWithBorder(
            backgroundColor: context.colors.onPrimaryContainer,
            constraints: null,
            child: Text(value.toString(),
                style: context.colors.primaryContainer.bodyMedium(context)),
          );
        })
      ],
    ));
  }
}

class _EthereumTransactionERC20DataWidget extends StatelessWidget {
  const _EthereumTransactionERC20DataWidget({required this.data, Key? key})
      : super(key: key);
  final SolidityERC20MethodInfo data;
  @override
  Widget build(BuildContext context) {
    if (data.type == SolidityMethodInfoTypes.erc20) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("token_info".tr, style: context.textTheme.titleMedium),
          WidgetConstant.height8,
          TokenDetailsView(
              token: data.token, onSelectWidget: WidgetConstant.sizedBox),
        ],
      );
    } else {
      final SolidityERC20TransferMethodInfo transferData = data.cast();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("token_info".tr, style: context.textTheme.titleMedium),
          WidgetConstant.height8,
          TokenDetailsView(
              token: data.token, onSelectWidget: WidgetConstant.sizedBox),
          WidgetConstant.height20,
          ReceiptAddressView(address: transferData.to),
          WidgetConstant.height20,
          Text("transfer_amount".tr, style: context.textTheme.titleMedium),
          Text("transfer_token_desc".tr),
          WidgetConstant.height8,
          ContainerWithBorder(
              child: CoinPriceView(
                  balance: transferData.value,
                  token: transferData.token.token,
                  style: context.textTheme.titleLarge,
                  showTokenImage: true))
        ],
      );
    }
  }
}

class _UnknownTransactionDataView extends StatelessWidget {
  const _UnknownTransactionDataView({required this.data, Key? key})
      : super(key: key);
  final UnknownTransactionData data;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("transaction_data".tr, style: context.textTheme.titleMedium),
        WidgetConstant.height8,
        ContainerWithBorder(
          onRemove: () {},
          onTapWhenOnRemove: false,
          onRemoveWidget:
              CopyTextIcon(dataToCopy: data.dataHex, isSensitive: false),
          child: Text(
            data.dataHex,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (data.content != null) ...[
          WidgetConstant.height20,
          Text("content".tr, style: context.textTheme.titleMedium),
          WidgetConstant.height8,
          ContainerWithBorder(
            onRemove: () {},
            onTapWhenOnRemove: false,
            onRemoveWidget:
                CopyTextIcon(dataToCopy: data.content!, isSensitive: false),
            child: Text(
              data.content!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }
}
