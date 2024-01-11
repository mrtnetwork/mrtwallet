import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/global_pages/wallet_global_pages.dart';

import 'package:mrt_wallet/future/pages/wallet_pages/wallet_pages.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:on_chain/on_chain.dart';
import 'package:xrp_dart/xrp_dart.dart';

class SelectNetworkAddressView extends StatefulWidget {
  const SelectNetworkAddressView(
      {super.key, required this.account, this.subtitle});
  final NetworkAccountCore account;
  final Widget? subtitle;

  @override
  State<SelectNetworkAddressView> createState() => _SelectAddressState();
}

class _SelectAddressState extends State<SelectNetworkAddressView>
    with SafeState {
  final GlobalKey<AppTextFieldState> textFieldKey =
      GlobalKey(debugLabel: "SelectAddress");
  final GlobalKey<FormState> formKey = GlobalKey(debugLabel: "SelectAddress_1");
  late final AppNetworkImpl network = widget.account.network;
  String _address = "";
  Live<ContactCore?> newContact = Live<ContactCore?>(null);
  bool get showAddContact => newContact.value != null;

  void onChange(String v) {
    _address = v;
  }

  ContactCore? validatorEthereumAccount(String address) {
    return MethodCaller.nullOnException(() {
      final addr = ETHAddress(address);
      return EthereumContract.newContact(address: addr, name: "new_address".tr);
    });
  }

  ContactCore? validatorTronAccount(String address) {
    return MethodCaller.nullOnException(() {
      final addr = TronAddress(address);
      return TronContact.newContact(address: addr, name: "new_address".tr);
    });
  }

  ContactCore? validateBitcoinNetwork(
      String address, AppBitcoinNetwork network) {
    return MethodCaller.nullOnException(() {
      final addr = BlockchainAddressUtils.toBitcoinAddress(
          address, network.coinParam.transacationNetwork);
      return BitcoinContact.newContact(
          network: network, address: addr, name: "new_address".tr);
    });
  }

  RippleContact? validateXRPAddress(String address, AppXRPNetwork network) {
    return MethodCaller.nullOnException(() {
      final toRipple = BlockchainAddressUtils.toRippleAddress(address, network);
      return RippleContact.newContact(
          network: network, address: toRipple, name: "new_address".tr);
    });
  }

  ContactCore? validate(String? address) {
    if (address == null) return null;
    if (network is AppXRPNetwork) {
      return validateXRPAddress(address, network.toNetwork());
    } else if (network is APPEVMNetwork) {
      return validatorEthereumAccount(address);
    } else if (network is APPTVMNetwork) {
      return validatorTronAccount(address);
    }
    return validateBitcoinNetwork(address, network.toNetwork());
  }

  void _setValidate(ContactCore? contact) {
    if (contact == null) {
      newContact.value = null;
    } else {
      final inContact = widget.account.getReceiptAddress(contact.address);
      if (inContact != null) {
        newContact.value = null;
      } else {
        newContact.value = contact;
      }
    }
  }

  String? validator(String? v) {
    final addr = validate(v);
    _setValidate(addr);
    if (addr == null) {
      return "invalid_network_address".tr;
    }
    return null;
  }

  void onPaste(String v) {
    textFieldKey.currentState?.updateText(v);
  }

  ReceiptAddress _buildReceiptAddress(ContactCore addr) {
    switch (widget.account.network.runtimeType) {
      case AppXRPNetwork:
        return ReceiptAddress<XRPAddress>(
            type: addr.type,
            view: addr.address,
            networkAddress: addr.addressObject);
      case APPEVMNetwork:
        return ReceiptAddress<ETHAddress>(
            type: addr.type,
            view: addr.address,
            networkAddress: addr.addressObject);
      case APPTVMNetwork:
        return ReceiptAddress<TronAddress>(
            type: addr.type,
            view: addr.address,
            networkAddress: addr.addressObject);
      default:
        return ReceiptAddress<BitcoinAddress>(
            type: addr.type,
            view: addr.address,
            networkAddress: addr.addressObject);
    }
  }

  void onSetup() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    final addr = validate(_address);
    if (context.mounted && addr != null) {
      ReceiptAddress? receipt =
          widget.account.getReceiptAddress(addr.address) ??
              _buildReceiptAddress(addr);
      context.pop(receipt);
    }
  }

  void fromMyAccount(String? account) {
    if (account == null) return;
    onPaste(account);
  }

  @override
  void dispose() {
    newContact.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.subtitle ??
              PageTitleSubtitle(
                  title: "address_recipient_funds".tr,
                  body: Text("receiver_address_desc".tr)),
          AppTextField(
            key: textFieldKey,
            label: "address".tr,
            minlines: 1,
            maxLines: 2,
            suffixIcon: Column(
              children: [
                PasteTextIcon(onPaste: onPaste),
              ],
            ),
            validator: validator,
            onChanged: onChange,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              LiveWidget(() => AnimatedSize(
                    duration: AppGlobalConst.animationDuraion,
                    child: showAddContact
                        ? FilledButton.icon(
                            onPressed: () {
                              context.openSliverBottomSheet(
                                "new_contact".tr,
                                child: AddToContactListView(
                                    contact: newContact.value!,
                                    network: widget.account.network),
                              );
                            },
                            icon: const Icon(Icons.perm_contact_cal_rounded),
                            label: Text("add_to_contacts".tr))
                        : const SizedBox(),
                  )),
              MyAccountIcon(
                onTap: () {
                  context
                      .openSliverBottomSheet<String>(
                        "select_account".tr,
                        bodyBuilder: (controller) => SelectAccountOrContactView(
                            account: widget.account,
                            scrollController: controller),
                        minExtent: 0.6,
                        maxExtend: 1,
                        initialExtend: 0.7,
                      )
                      .then(fromMyAccount);
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FixedElevatedButton(
                  padding: WidgetConstant.paddingVertical20,
                  onPressed: onSetup,
                  child: Text("setup_address".tr))
            ],
          ),
        ],
      ),
    );
  }
}
