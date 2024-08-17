import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/wallet/global/global.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:on_chain/on_chain.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';

class CardanoTransactionCertificateView extends StatefulWidget {
  final ADAChain account;
  const CardanoTransactionCertificateView(this.account, {super.key});

  @override
  State<CardanoTransactionCertificateView> createState() =>
      _CardanoTransactionCertificateViewState();
}

class _CardanoTransactionCertificateViewState
    extends State<CardanoTransactionCertificateView> with SafeState {
  ADATransactionCertificateType type =
      ADATransactionCertificateType.registraction;

  bool get isReady => reward != null && address != null;

  void onChageCertificate(ADATransactionCertificateType? newCertificate) {
    type = newCertificate ?? type;
    setState(() {});
  }

  ReceiptAddress<ADARewardAddress>? reward;
  ICardanoAddress? address;

  bool _validateRewardAccount(ICardanoAddress addr) {
    if (addr.rewardAddress == null) {
      context.showAlert("stake_address_validator".tr);
      return false;
    }
    return true;
  }

  void updateRewardAddress(ICardanoAddress? addr) {
    if (addr == null) return;
    if (_validateRewardAccount(addr)) {
      address = addr;
      reward = ReceiptAddress<ADARewardAddress>(
          view: addr.rewardAddress!.address,
          type: addr.rewardAddress!.addressType.name,
          networkAddress: addr.rewardAddress!,
          account: addr as NETWORKCHAINACCOUNT<ADARewardAddress>);
      setState(() {});
    }
  }

  ADACertificateBuilder toCertificateBuilder() {
    switch (type) {
      case ADATransactionCertificateType.deregistration:
        return ADACertificateBuilder(
            certificate:
                StakeDeregistration(reward!.networkAddress.paymentCredential),
            signer: reward!.networkAddress);
      case ADATransactionCertificateType.registraction:
        return ADACertificateBuilder(
            certificate:
                StakeRegistration(reward!.networkAddress.paymentCredential));
      default:
        throw UnimplementedError();
    }
  }

  ADATransactionCertificate toAdaTransactionCertificate() {
    return ADATransactionCertificate(
        certificate: toCertificateBuilder(),
        type: type,
        rewardAccount: ReceiptAddress(
            view: reward!.networkAddress.address,
            type: reward!.networkAddress.addressType.name,
            networkAddress: reward!.networkAddress,
            account: address));
  }

  void onSubmit() {
    if (!isReady) return;
    context.pop(toAdaTransactionCertificate());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("certificate_type".tr),
        Text("add_certificate_to_transaction_desc".tr),
        WidgetConstant.height8,
        AppDropDownBottom(
          items: {
            for (final i in ADATransactionCertificateType.values)
              i: Text(i.viewName.tr)
          },
          label: "certificate_type".tr,
          onChanged: onChageCertificate,
        ),
        WidgetConstant.height20,
        ReceiptAddressView(
          title: "stake_address".tr,
          onTap: () {
            context
                .openSliverBottomSheet<ICardanoAddress>(
                  "select_account".tr,
                  child: SwitchOrSelectAccountView(
                    account: widget.account,
                    showMultiSig: true,
                  ),
                  minExtent: 0.5,
                  maxExtend: 0.9,
                  initialExtend: 0.7,
                  centerContent: false,
                )
                .then(updateRewardAddress);
          },
          address: reward,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FixedElevatedButton(
                padding: WidgetConstant.paddingVertical20,
                onPressed: isReady ? onSubmit : null,
                child: Text("setup_certificate".tr))
          ],
        )
      ],
    );
  }
}
