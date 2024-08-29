import 'package:blockchain_utils/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/account/pages/account_controller.dart';
import 'package:mrt_wallet/future/wallet/global/global.dart';
import 'package:mrt_wallet/future/wallet/network/solana/transaction/controller/controller/controller.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/network/forms/forms.dart';
import 'package:on_chain/solana/solana.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';

class SolanaTransactionFieldsView extends StatelessWidget {
  const SolanaTransactionFieldsView({super.key, this.field});
  final LiveTransactionForm<SolanaTransactionForm>? field;
  @override
  Widget build(BuildContext context) {
    final LiveTransactionForm<SolanaTransactionForm> validator =
        field ?? context.getArgruments();
    return NetworkAccountControllerView<SolanaChain>(
        childBulder: (wallet, chain, switchAccount) {
          return MrtViewBuilder<SolanaTransactionStateController>(
            repositoryId: StateConst.solana,
            controller: () => SolanaTransactionStateController(
                walletProvider: wallet,
                account: chain,
                network: chain.network,
                address: chain.address,
                apiProvider: chain.provider()!,
                validator: validator),
            builder: (controller) {
              return PageProgress(
                backToIdle: APPConst.oneSecoundDuration,
                key: controller.progressKey,
                child: (c) {
                  return CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: ConstraintsBoxView(
                            padding: WidgetConstant.padding20,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("account".tr,
                                    style: context.textTheme.titleLarge),
                                WidgetConstant.height8,
                                ContainerWithBorder(
                                  onRemoveIcon: const Icon(Icons.edit),
                                  child: AddressDetailsView(
                                      address: controller.owner,
                                      key: ValueKey<ISolanaAddress?>(
                                          controller.owner)),
                                  onRemove: () {
                                    context
                                        .openSliverBottomSheet<ISolanaAddress>(
                                          "switch_account".tr,
                                          child: SwitchOrSelectAccountView(
                                              account: controller.account,
                                              showMultiSig: true),
                                          minExtent: 0.5,
                                          maxExtend: 0.9,
                                          initialExtend: 0.7,
                                          centerContent: false,
                                        )
                                        .then(switchAccount);
                                  },
                                ),
                                WidgetConstant.height20,
                                _SolanaTransactionFileds(
                                    validator: controller.validator,
                                    controller: controller),
                                AnimatedSize(
                                  duration: APPConst.animationDuraion,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      WidgetConstant.height20,
                                      Text("transaction_fee".tr,
                                          style: context.textTheme.titleLarge),
                                      WidgetConstant.height8,
                                      ContainerWithBorder(
                                          validate: controller.hasFee,
                                          onRemove: () {},
                                          onTapWhenOnRemove: false,
                                          onRemoveIcon: StreamWidget(
                                            key: controller.feeProgressKey,
                                            initialStatus:
                                                StreamWidgetStatus.idle,
                                            buttonWidget: Icon(Icons.circle,
                                                color:
                                                    context.colors.transparent),
                                          ),
                                          child: CoinPriceView(
                                            token: controller
                                                .network.coinParam.token,
                                            balance: controller.fee,
                                            style: context.textTheme.titleLarge,
                                          )),
                                    ],
                                  ),
                                ),
                                WidgetConstant.height20,
                                Text("setup_memo".tr,
                                    style: context.textTheme.titleMedium),
                                WidgetConstant.height8,
                                ContainerWithBorder(
                                    onRemoveIcon: controller.hasMemo
                                        ? const Icon(Icons.remove_circle)
                                        : const Icon(Icons.add_box),
                                    onRemove: () {
                                      controller.onTapMemo((s) async {
                                        final result = await context
                                            .openSliverBottomSheet<String>(
                                          "transaction_memo".tr,
                                          child: StringWriterView(
                                            defaultValue: s,
                                            maxLength: SolanaConst.memoLength,
                                            title: PageTitleSubtitle(
                                                title: "setup_memo".tr,
                                                body: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text("empty_desc".tr),
                                                  ],
                                                )),
                                            buttonText: "setup_memo".tr,
                                            label: "memo".tr,
                                          ),
                                        );
                                        return result;
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: controller.hasMemo
                                              ? Text(controller.memoStr ?? "")
                                              : Text("tap_to_add_memo".tr,
                                                  style: context
                                                      .textTheme.labelLarge),
                                        ),
                                      ],
                                    )),
                                WidgetConstant.height20,
                                InsufficientBalanceErrorView(
                                  verticalMargin:
                                      WidgetConstant.paddingVertical10,
                                  balance: controller.remindAmount.$1,
                                  token: controller.remindAmount.$2,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FixedElevatedButton(
                                      padding: WidgetConstant.paddingVertical40,
                                      onPressed: controller.transactionIsReady
                                          ? controller.sendTransaction
                                          : null,
                                      child: Text("send_transaction".tr),
                                    ),
                                  ],
                                ),
                              ],
                            )),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
        title: validator.validator.name.tr);
  }
}

class _SolanaTransactionFileds extends StatelessWidget {
  const _SolanaTransactionFileds(
      {required this.validator, required this.controller});
  final LiveTransactionForm<SolanaTransactionForm> validator;
  final SolanaTransactionStateController controller;
  @override
  Widget build(BuildContext context) {
    return LiveWidget(() {
      switch (validator.validator.mode) {
        case SolanaTransactionType.createAssociatedTokenAccount:
          final field =
              validator.value as SolanaCreateAssociatedTokenAccountForm;
          return _CreateAssociatedTokenAccountFields(
              field: field, controller: controller);
        case SolanaTransactionType.createAccount:
          final field = validator.value as SolanaCreateAccountForm;
          return _CreateAccountFields(field: field, controller: controller);
        case SolanaTransactionType.initializeMint:
          final field = validator.value as SolanaInitializeMintForm;
          return _InitializeMintFields(field: field, controller: controller);
        case SolanaTransactionType.mintTo:
          final field = validator.value as SolanaMintToForm;
          return _MintToFields(field: field, controller: controller);
        default:
          final field = validator.value as SolanaTransferForm;
          return _SolanaTransferFields(field: field, controller: controller);
      }
    });
  }
}

class _SolanaTransferFields extends StatelessWidget {
  const _SolanaTransferFields({required this.field, required this.controller});
  final SolanaTransferForm field;
  final SolanaTransactionStateController controller;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (field.isTokenTransfer)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("token_transfer".tr, style: context.textTheme.titleLarge),
              WidgetConstant.height8,
              TokenDetailsView(
                token: field.splToken!,
                onSelectWidget: WidgetConstant.sizedBox,
              ),
              WidgetConstant.height20,
            ],
          ),
        ReceiptAddressView(
          address: field.destination.value,
          subtitle: "receiver_address_desc".tr,
          onTap: () {
            context
                .openSliverBottomSheet<ReceiptAddress<SolAddress>>(
                    "recipient".tr,
                    maxExtend: 1,
                    minExtent: 0.8,
                    initialExtend: 0.9,
                    bodyBuilder: (sc) => SelectRecipientAccountView<SolAddress>(
                        account: controller.account, scrollController: sc))
                .then(
              (value) {
                field.setValue(field.destination, value);
              },
            );
          },
        ),
        WidgetConstant.height20,
        Text("destination_info".tr, style: context.textTheme.titleMedium),
        Text("destination_info_desc".tr),
        WidgetConstant.height8,
        ContainerWithBorder(
            onRemoveIcon: StreamWidget(
                buttonWidget:
                    Icon(Icons.circle, color: context.colors.transparent),
                key: field.accountKey),
            onRemove: () {
              if (!field.hasErrpr) return;
              field.updateAccountInfo();
            },
            child: !field.destination.hasValue
                ? Text("no_account_chosen".tr)
                : field.hasErrpr
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          WidgetConstant.errorIcon,
                          WidgetConstant.width8,
                          Expanded(
                            child: Text(
                              "request_error".tr,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      )
                    : field.accountInfo == null
                        ? Text("account_not_found".tr)
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("owner".tr,
                                  style: context.textTheme.labelLarge),
                              Text(field.accountInfo!.owner.address),
                              Divider(color: context.colors.onPrimaryContainer),
                              Text("executable".tr,
                                  style: context.textTheme.labelLarge),
                              Text(field.accountInfo!.executable.tr),
                            ],
                          )),
        WidgetConstant.height20,
        TransactionAmountView(
          amount: field.amount.value,
          subtitle: "input_the_amout".tr,
          validate:
              field.amount.isCompleted && !field.showRequirementAmountAlert,
          validateError: field.showRequirementAmountAlert
              ? "amount_must_exceed".tr.replaceOne(PriceUtils.priceWithCoinName(
                  SolanaConst.systemProgramRentSol,
                  controller.network.coinParam.token.symbol))
              : null,
          onTap: () {
            context
                .openSliverBottomSheet<BigInt>(
              "setup_output_amount".tr,
              child: SetupNetworkAmount(
                token: field.token,
                max: field.isTokenTransfer
                    ? field.splToken!.balance.value.balance
                    : controller.address.address.currencyBalance -
                        controller.fee.balance,
                min: BigInt.zero,
                subtitle: field.destination.hasValue
                    ? ReceiptAddressView(
                        address: field.destination.value,
                        onTap: null,
                      )
                    : const SizedBox(),
              ),
            )
                .then((value) {
              if (value == null) {
                field.setValue(field.amount, null);
              } else {
                field.setValue(
                    field.amount, IntegerBalance(value, field.token.decimal!));
              }
            });
          },
          token: field.token,
        ),
      ],
    );
  }
}

class _CreateAssociatedTokenAccountFields extends StatelessWidget {
  const _CreateAssociatedTokenAccountFields(
      {required this.field, required this.controller});
  final SolanaCreateAssociatedTokenAccountForm field;
  final SolanaTransactionStateController controller;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReceiptAddressView(
          address: field.ownerAddress.value,
          title: "owner_address".tr,
          subtitle: "owner_of_account".tr,
          onTap: () {
            context
                .openSliverBottomSheet<ReceiptAddress<SolAddress>>(
                    "owner_address".tr,
                    maxExtend: 1,
                    minExtent: 0.8,
                    initialExtend: 0.9,
                    bodyBuilder: (sc) => SelectRecipientAccountView<SolAddress>(
                          account: controller.account,
                          scrollController: sc,
                          subtitle: PageTitleSubtitle(
                              title: "owner".tr,
                              body: Text("owner_of_account".tr)),
                        ))
                .then(
              (value) {
                field.setValue(field.ownerAddress, value);
              },
            );
          },
        ),
        WidgetConstant.height20,
        ReceiptAddressView(
          address: field.mintAddress.value,
          title: "mint_address".tr,
          subtitle: "mint_address_desc".tr,
          onTap: () {
            context
                .openSliverBottomSheet<ReceiptAddress<SolAddress>>(
                    "mint_address".tr,
                    maxExtend: 1,
                    minExtent: 0.8,
                    initialExtend: 0.9,
                    bodyBuilder: (sc) => SelectRecipientAccountView<SolAddress>(
                          account: controller.account,
                          scrollController: sc,
                          subtitle: PageTitleSubtitle(
                              title: "mint_address".tr,
                              body: Text("mint_address_desc".tr)),
                        ))
                .then(
              (value) {
                field.setValue(field.mintAddress, value);
              },
            );
          },
        ),
        WidgetConstant.height20,
        ReceiptAddressView(
          address: field.tokenProgram.value,
          subtitle: "program_address_desc".tr,
          title: "program_address".tr,
          onTap: () {
            context
                .openSliverBottomSheet<ReceiptAddress<SolAddress>>(
                    "program_address".tr,
                    maxExtend: 1,
                    minExtent: 0.8,
                    initialExtend: 0.9,
                    bodyBuilder: (sc) => SelectRecipientAccountView<SolAddress>(
                          account: controller.account,
                          scrollController: sc,
                          subtitle: PageTitleSubtitle(
                              title: "program_address".tr,
                              body: Text("program_address_desc".tr)),
                        ))
                .then(
              (value) {
                field.setValue(field.tokenProgram, value);
              },
            );
          },
        ),
        AnimatedSize(
          duration: APPConst.animationDuraion,
          child: field.assosicatedAddress == null
              ? WidgetConstant.sizedBox
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WidgetConstant.height20,
                    Text("associated_token_address".tr,
                        style: context.textTheme.titleMedium),
                    WidgetConstant.height8,
                    ContainerWithBorder(
                      child: Text(field.assosicatedAddress?.address ?? ""),
                    )
                  ],
                ),
        )
      ],
    );
  }
}

class _CreateAccountFields extends StatelessWidget {
  const _CreateAccountFields({required this.field, required this.controller});
  final SolanaCreateAccountForm field;
  final SolanaTransactionStateController controller;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReceiptAddressView(
          address: field.newAccountAddress.value,
          title: "new_account_address".tr,
          subtitle: "solana_new_account_desc".tr,
          onTap: () {
            context
                .openSliverBottomSheet<ISolanaAddress>(
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
                .then(field.changeAssetOutputAddress);
          },
        ),
        WidgetConstant.height20,
        ReceiptAddressView(
          address: field.ownerAddress.value,
          title: "owner".tr,
          subtitle: "owner_of_account".tr,
          onTap: () {
            context
                .openSliverBottomSheet<ReceiptAddress<SolAddress>>("owner".tr,
                    maxExtend: 1,
                    minExtent: 0.8,
                    initialExtend: 0.9,
                    bodyBuilder: (sc) => SelectRecipientAccountView<SolAddress>(
                          account: controller.account,
                          scrollController: sc,
                          subtitle: PageTitleSubtitle(
                              title: "owner".tr,
                              body: Text("owner_of_account".tr)),
                        ))
                .then(
              (value) {
                if (value == null) return;
                field.setValue(field.ownerAddress, value);
              },
            );
          },
        ),
        WidgetConstant.height20,
        Text("account_size".tr, style: context.textTheme.titleMedium),
        Text("solana_account_size_desc".tr),
        WidgetConstant.height8,
        ContainerWithBorder(
          validate: field.space.hasValue,
          onRemoveIcon: field.space.hasValue
              ? const Icon(Icons.edit)
              : const Icon(Icons.add),
          onRemove: () {
            context
                .openSliverBottomSheet<BigRational>(
                  "account_size".tr,
                  child: NumberWriteView(
                    defaultValue: field.space.value,
                    allowDecimal: false,
                    max: SolanaConst.maximumAccountSizeBytes,
                    min: BigRational.zero,
                    allowSign: false,
                    title: PageTitleSubtitle(
                        title: "account_size".tr,
                        body: Text("solana_account_size_desc".tr)),
                    buttonText: "setup_account_size".tr,
                    label: "account_size".tr,
                  ),
                )
                .then(field.setSpace);
          },
          child: Text(field.space.value?.toString().to3Digits ??
              "tap_to_input_value".tr),
        ),
        WidgetConstant.height20,
        TransactionAmountView(
          amount: field.lamports.value,
          title: "lamports".tr,
          subtitle: "solana_create_account_lamports_desc".tr,
          validate: field.lamports.isCompleted,
          onRemoveIcon: StreamWidget(
              key: field.rentProgress,
              buttonWidget: field.lamports.hasValue
                  ? const Icon(Icons.edit)
                  : const Icon(Icons.add)),
          onTap: () {
            if (field.rentProgress.inProgress) return;
            context
                .openSliverBottomSheet<BigInt>(
                  "lamports".tr,
                  child: SetupNetworkAmount(
                    token: controller.network.coinParam.token,
                    max: controller.address.address.currencyBalance -
                        controller.fee.balance,
                    min: BigInt.zero,
                    subtitle: Text("solana_create_account_lamports_desc".tr),
                  ),
                )
                .then(field.setLamports);
          },
          token: controller.network.coinParam.token,
        ),
      ],
    );
  }
}

class _InitializeMintFields extends StatelessWidget {
  const _InitializeMintFields({required this.field, required this.controller});
  final SolanaInitializeMintForm field;
  final SolanaTransactionStateController controller;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReceiptAddressView(
          address: field.programId.value,
          title: "program_id".tr,
          subtitle: "solana_program_id_desc".tr,
          onTap: () {
            context
                .openSliverBottomSheet<ReceiptAddress<SolAddress>>(
                    "program_id".tr,
                    maxExtend: 1,
                    minExtent: 0.8,
                    initialExtend: 0.9,
                    bodyBuilder: (sc) => SelectRecipientAccountView<SolAddress>(
                        account: controller.account, scrollController: sc))
                .then(
              (value) {
                if (value == null) return;
                field.setValue(field.programId, value);
              },
            );
          },
        ),
        WidgetConstant.height20,
        ReceiptAddressView(
          address: field.mint.value,
          title: "mint".tr,
          subtitle: "mint_address_to_initialize".tr,
          onTap: () {
            context
                .openSliverBottomSheet<ReceiptAddress<SolAddress>>("mint".tr,
                    maxExtend: 1,
                    minExtent: 0.8,
                    initialExtend: 0.9,
                    bodyBuilder: (sc) => SelectRecipientAccountView<SolAddress>(
                        account: controller.account, scrollController: sc))
                .then(
              (value) {
                if (value == null) return;
                field.setValue(field.mint, value);
              },
            );
          },
        ),
        WidgetConstant.height20,
        ReceiptAddressView(
          address: field.mintAuthority.value,
          title: "mint_authority".tr,
          subtitle: "mint_authority_desc".tr,
          onTap: () {
            context
                .openSliverBottomSheet<ReceiptAddress<SolAddress>>(
                    "mint_authority".tr,
                    maxExtend: 1,
                    minExtent: 0.8,
                    initialExtend: 0.9,
                    bodyBuilder: (sc) => SelectRecipientAccountView<SolAddress>(
                        account: controller.account, scrollController: sc))
                .then(
              (value) {
                if (value == null) return;
                field.setValue(field.mintAuthority, value);
              },
            );
          },
        ),
        WidgetConstant.height20,
        ReceiptAddressView(
          address: field.freezAuthority.value,
          validate: true,
          title: "freeze_authority".tr,
          subtitle: "freeze_authority_desc".tr,
          onTap: () {
            context
                .openSliverBottomSheet<ReceiptAddress<SolAddress>>(
                    "freeze_authority".tr,
                    maxExtend: 1,
                    minExtent: 0.8,
                    initialExtend: 0.9,
                    bodyBuilder: (sc) => SelectRecipientAccountView<SolAddress>(
                        account: controller.account, scrollController: sc))
                .then(
              (value) {
                if (value == null) return;
                field.setValue(field.freezAuthority, value);
              },
            );
          },
        ),
        WidgetConstant.height20,
        Text("decimals".tr, style: context.textTheme.titleMedium),
        Text("solana_mint_decimal_desc".tr),
        WidgetConstant.height8,
        ContainerWithBorder(
          validate: field.decimals.hasValue,
          onRemoveIcon: field.decimals.hasValue
              ? const Icon(Icons.edit)
              : const Icon(Icons.add),
          onRemove: () {
            context
                .openSliverBottomSheet<BigRational>(
              "decimals".tr,
              child: NumberWriteView(
                defaultValue: field.decimals.value,
                allowDecimal: false,
                max: SolanaConst.maxSPLTokenDecimalPlaces,
                min: BigRational.zero,
                allowSign: false,
                title: PageTitleSubtitle(
                    title: "decimals".tr,
                    body: Text("solana_mint_decimal_desc".tr)),
                buttonText: "setup_token_decimal".tr,
                label: "decimals".tr,
              ),
            )
                .then(
              (value) {
                field.setValue(field.decimals, value);
              },
            );
          },
          child: Text(field.decimals.value?.toString().to3Digits ??
              "tap_to_input_value".tr),
        ),
      ],
    );
  }
}

class _MintToFields extends StatelessWidget {
  const _MintToFields({required this.field, required this.controller});
  final SolanaMintToForm field;
  final SolanaTransactionStateController controller;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReceiptAddressView(
          address: field.programId.value,
          title: "program_id".tr,
          subtitle: "solana_program_id_desc".tr,
          onTap: () {
            context
                .openSliverBottomSheet<ReceiptAddress<SolAddress>>(
                    "program_id".tr,
                    maxExtend: 1,
                    minExtent: 0.8,
                    initialExtend: 0.9,
                    bodyBuilder: (sc) => SelectRecipientAccountView<SolAddress>(
                        account: controller.account, scrollController: sc))
                .then(
              (value) {
                if (value == null) return;
                field.setValue(field.programId, value);
              },
            );
          },
        ),
        WidgetConstant.height20,
        ReceiptAddressView(
          address: field.mint.value,
          title: "mint".tr,
          subtitle: "mint_address_mint_desc".tr,
          onTap: () {
            context
                .openSliverBottomSheet<ReceiptAddress<SolAddress>>("mint".tr,
                    maxExtend: 1,
                    minExtent: 0.8,
                    initialExtend: 0.9,
                    bodyBuilder: (sc) => SelectRecipientAccountView<SolAddress>(
                          account: controller.account,
                          scrollController: sc,
                          subtitle: PageTitleSubtitle(
                              title: "mint".tr,
                              body: Text("mint_address_mint_desc".tr)),
                        ))
                .then(
              (value) {
                if (value == null) return;
                field.setValue(field.mint, value);
              },
            );
          },
        ),
        WidgetConstant.height20,
        ReceiptAddressView(
          address: field.authority.value,
          title: "authority".tr,
          subtitle: "mint_to_authority_desc".tr,
          onTap: () {
            context
                .openSliverBottomSheet<ReceiptAddress<SolAddress>>(
                    "authority".tr,
                    maxExtend: 1,
                    minExtent: 0.8,
                    initialExtend: 0.9,
                    bodyBuilder: (sc) => SelectRecipientAccountView<SolAddress>(
                          account: controller.account,
                          scrollController: sc,
                          subtitle: PageTitleSubtitle(
                              title: "authority".tr,
                              body: Text("mint_to_authority_desc".tr)),
                        ))
                .then(
              (value) {
                if (value == null) return;
                field.setValue(field.authority, value);
              },
            );
          },
        ),
        WidgetConstant.height20,
        ReceiptAddressView(
          address: field.destination.value,
          validate: field.destination.hasValue,
          title: "destination".tr,
          subtitle: "use_owner_account_instead_pda_desc".tr,
          onTap: () {
            context
                .openSliverBottomSheet<ReceiptAddress<SolAddress>>(
                    "destination".tr,
                    maxExtend: 1,
                    minExtent: 0.8,
                    initialExtend: 0.9,
                    bodyBuilder: (sc) => SelectRecipientAccountView<SolAddress>(
                          account: controller.account,
                          scrollController: sc,
                          subtitle: PageTitleSubtitle(
                              title: "destination".tr,
                              body: Text("mint_to_destination_desc".tr)),
                        ))
                .then(
              (value) {
                if (value == null) return;
                field.setDestination(value);
              },
            );
          },
        ),
        WidgetConstant.height20,
        Text("destination_info".tr, style: context.textTheme.titleMedium),
        Text("destination_info_desc".tr),
        WidgetConstant.height8,
        ContainerWithBorder(
            onRemoveIcon: StreamWidget(
                buttonWidget:
                    Icon(Icons.circle, color: context.colors.transparent),
                key: field.accountProgressKey),
            onRemove: () {
              if (!field.hasFetchingAccountError) return;
              field.getDestinationAccountInfo();
            },
            child: !field.destination.hasValue
                ? Text("no_account_chosen".tr)
                : field.hasFetchingAccountError
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          WidgetConstant.errorIcon,
                          WidgetConstant.width8,
                          Expanded(
                            child: Text(
                              "request_error".tr,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      )
                    : field.destinationAccount == null
                        ? Text("account_not_found".tr)
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("owner".tr,
                                  style: context.textTheme.labelLarge),
                              Text(field.destinationAccount!.owner.address),
                              Divider(color: context.colors.onPrimaryContainer),
                              Text("executable".tr,
                                  style: context.textTheme.labelLarge),
                              Text(field.destinationAccount!.executable.tr),
                            ],
                          )),
        WidgetConstant.height20,
        TransactionAmountView(
          amount: field.amount.value,
          title: "amount".tr,
          subtitle: "mint_to_amount_desc".tr,
          validate: field.amount.isCompleted,
          onTap: () {
            context
                .openSliverBottomSheet<BigInt>(
              "amount".tr,
              child: SetupNetworkAmount(
                token: field.token,
                max: maxU64,
                min: BigInt.zero,
                subtitle: PageTitleSubtitle(
                    title: "amount".tr, body: Text("mint_to_amount_desc".tr)),
              ),
            )
                .then((value) {
              if (value == null) {
                field.setValue(field.amount, null);
              } else {
                field.setValue(
                    field.amount, IntegerBalance(value, field.token.decimal!));
              }
            });
          },
          token: field.token,
        ),
      ],
    );
  }
}
