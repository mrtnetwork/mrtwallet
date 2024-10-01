import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/network/stellar/transaction/pages/operations/change_trust.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:stellar_dart/stellar_dart.dart';

import 'create_account.dart';
import 'manage_buy_offer.dart';
import 'manage_sell_offer.dart';
import 'path_payment_receive.dart';
import 'path_payment_send.dart';
import 'payment.dart';

class StellarCreateTransactionOperationsView extends StatefulWidget {
  final StellarTransactionStateController controller;
  final StellarTransactionOperation? updateOperation;

  const StellarCreateTransactionOperationsView(
      {required this.controller, this.updateOperation, Key? key})
      : super(key: key);

  @override
  State<StellarCreateTransactionOperationsView> createState() =>
      _StellarCreateTransactionOperationsViewState();
}

class _StellarCreateTransactionOperationsViewState
    extends State<StellarCreateTransactionOperationsView> with SafeState {
  OperationType? operation;

  late final Map<OperationType, Widget> operationItems = {
    for (final i in StellarConst.supportedOperations) i: Text(i.name.camelCase)
  };

  void onChangeOperation(OperationType? operation) {
    this.operation = operation;
    updateState();
  }

  void onPop(bool didPop, Object? result) {
    if (didPop) return;
    operation = null;
    updateState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    operation = widget.updateOperation?.type;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: operation == null || widget.updateOperation != null,
      onPopInvokedWithResult: onPop,
      child: APPAnimatedSwitcher<OperationType?>(enable: operation, widgets: {
        null: (context) => _SelectOperationView(this),
        OperationType.changeTrust: (context) => ChangeTrustOperationView(
              controller: widget.controller,
              operation: widget.updateOperation as StellarChangeTrustOperation?,
            ),
        OperationType.payment: (context) => PaymentOperationView(
              controller: widget.controller,
              operation: widget.updateOperation as StellarPaymentOperation?,
            ),
        OperationType.pathPaymentStrictReceive: (context) =>
            PathPaymentStrictReceiveOperationView(
              controller: widget.controller,
              operation: widget.updateOperation
                  as StellarPathPaymentStrictReceiveOperation?,
            ),
        OperationType.pathPaymentStrictSend: (context) =>
            PathPaymentStrictSendOperationView(
              controller: widget.controller,
              operation: widget.updateOperation
                  as StellarPathPaymentStrictSendOperation?,
            ),
        OperationType.createAccount: (context) => CreateAccountOperationView(
              controller: widget.controller,
              operation:
                  widget.updateOperation as StellarCreateAccountOperation?,
            ),
        OperationType.manageSellOffer: (context) =>
            ManageSellOfferOperationView(
              controller: widget.controller,
              operation:
                  widget.updateOperation as StellarManageSellOfferOperation?,
            ),
        OperationType.manageBuyOffer: (context) => ManageBuyOfferOperationView(
              controller: widget.controller,
              operation:
                  widget.updateOperation as StellarManageBuyOfferOperation?,
            ),
      }),
    );
  }
}

/// ManageSellOfferOperationView

class _SelectOperationView extends StatelessWidget {
  final _StellarCreateTransactionOperationsViewState state;
  const _SelectOperationView(this.state, {Key? key}) : super(key: key);

  @override
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageTitleSubtitle(
            title: "transaction_operation".tr,
            body: Text("stellar_transaction_operation_desc".tr)),
        ListView.separated(
            shrinkWrap: true,
            physics: WidgetConstant.noScrollPhysics,
            itemBuilder: (context, index) {
              final element = StellarConst.supportedOperations.elementAt(index);
              return AppListTile(
                title: Text(element.translate.tr),
                onTap: () => state.onChangeOperation(element),
                subtitle: Text(element.description),
                maxLine: 3,
                trailing: const Icon(Icons.arrow_forward),
              );
            },
            separatorBuilder: (context, index) => WidgetConstant.divider,
            itemCount: StellarConst.supportedOperations.length),
      ],
    );
  }
}

extension OperationTypeDesc on OperationType {
  String get description {
    switch (this) {
      case OperationType.changeTrust:
        return "change_trust_desc".tr;
      case OperationType.createAccount:
        return "stellar_create_account_operation_desc".tr;
      case OperationType.manageBuyOffer:
        return "stellar_manage_buy_offer_desc".tr;
      case OperationType.manageSellOffer:
        return "stellar_manage_sell_offer_desc".tr;
      case OperationType.pathPaymentStrictReceive:
        return "stellar_path_payment_strict_receive_desc".tr;
      case OperationType.pathPaymentStrictSend:
        return "stellar_path_payment_strict_send_desc".tr;
      case OperationType.payment:
        return "stellar_payment_desc".tr;
      default:
        return '';
    }
  }

  String get translate {
    switch (this) {
      case OperationType.createAccount:
        return "create_an_account";
      case OperationType.payment:
        return "payment";
      case OperationType.pathPaymentStrictReceive:
        return "stellar_path_payment_strict_receive";
      case OperationType.manageSellOffer:
        return "stellar_manage_sell_offer";
      case OperationType.createPassiveSellOffer:
        return "create_passive_sell_offer";
      case OperationType.setOptions:
        return "set_options";
      case OperationType.changeTrust:
        return "change_trust";
      case OperationType.allowTrust:
        return "allow_trust";
      case OperationType.accountMerge:
        return "account_merge";
      case OperationType.inflation:
        return "inflation";
      case OperationType.manageData:
        return "manage_data";
      case OperationType.bumpSequence:
        return "bump_sequence";
      case OperationType.manageBuyOffer:
        return "stellar_manage_buy_offer";
      case OperationType.pathPaymentStrictSend:
        return "stellar_path_payment_strict_send";
      case OperationType.createClaimableBalance:
        return "create_claimable_balance";
      case OperationType.claimClaimableBalance:
        return "claim_claimable_balance";
      case OperationType.beginSponsoringFutureReserves:
        return "begin_sponsoring_future_reserves";
      case OperationType.endSponsoringFutureReserves:
        return "end_sponsoring_future_reserves";
      case OperationType.revokeSponsorship:
        return "revoke_sponsorship";
      case OperationType.clawback:
        return "clawback";
      case OperationType.clawbackClaimableBalance:
        return "clawback_claimable_balance";
      case OperationType.setTrustLineFlags:
        return "set_trust_line_flags";
      case OperationType.liquidityPoolDeposit:
        return "liquidity_pool_deposit";
      case OperationType.liquidityPoolWithdraw:
        return "liquidity_pool_withdraw";
      case OperationType.invokeHostFunction:
        return "invoke_host_function";
      case OperationType.extendFootprintTtl:
        return "extend_footprint_ttl";
      case OperationType.restoreFootprint:
        return "restore_footprint";
      default:
        return "";
    }
  }
}
