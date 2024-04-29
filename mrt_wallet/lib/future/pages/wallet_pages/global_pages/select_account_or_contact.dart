import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/global_pages/add_to_contact_list.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/global_pages/address_details.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/types/typedef.dart';
import 'package:on_chain/on_chain.dart';
import 'package:on_chain/solana/solana.dart';
import 'package:xrpl_dart/xrpl_dart.dart';

class SelectRecipientAccountView extends StatefulWidget {
  const SelectRecipientAccountView(
      {super.key,
      required this.account,
      required this.scrollController,
      this.subtitle,
      this.multipleSelect = true});
  final NetworkAccountCore account;
  final ScrollController scrollController;
  final Widget? subtitle;
  final bool multipleSelect;

  @override
  State<SelectRecipientAccountView> createState() =>
      _SelectRecipientAccountViewState();
}

class _SelectRecipientAccountViewState extends State<SelectRecipientAccountView>
    with SingleTickerProviderStateMixin, SafeState {
  late final TabController controller = TabController(length: 3, vsync: this);
  void _listener() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(_listener);
  }

  @override
  void dispose() {
    controller.dispose();
    newContact.dispose();
    super.dispose();
  }

////
  final GlobalKey<AppTextFieldState> textFieldKey =
      GlobalKey(debugLabel: "SelectAddress");
  final GlobalKey<FormState> formKey = GlobalKey(debugLabel: "SelectAddress_1");
  late final AppNetworkImpl network = widget.account.network;
  String _address = "";
  Live<ContactCore?> newContact = Live<ContactCore?>(null);

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

  ContactCore? validatorSolAccount(String address) {
    return MethodCaller.nullOnException(() {
      final addr = SolAddress(address);
      return SolanaContact.newContact(address: addr, name: "new_address".tr);
    });
  }

  ContactCore? validatorCardanoAddress(String address) {
    return MethodCaller.nullOnException(() {
      final addr = ADAAddress.fromAddress(address,
          network: (network as APPCardanoNetwork).toCardanoNetwork);
      return CardanoContact.newContact(address: addr, name: "new_address".tr);
    });
  }

  ContactCore? validateCosmosAddress(String address) {
    return MethodCaller.nullOnException(() {
      final addr = CosmosBaseAddress(address,
          forceHrp: (network as APPCosmosNetwork).coinParam.hrp);
      return CosmosContact.newContact(address: addr, name: "new_address".tr);
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
    } else if (network is APPSolanaNetwork) {
      return validatorSolAccount(address);
    } else if (network is APPCardanoNetwork) {
      return validatorCardanoAddress(address);
    } else if (network is APPCosmosNetwork) {
      return validateCosmosAddress(address);
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

  void onAccountOrContact(String address) {
    final addr = validate(address);
    if (addr == null) return;
    ReceiptAddress? receipt = widget.account.getReceiptAddress(addr.address) ??
        _buildReceiptAddress(addr);
    context.pop(receipt);
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
      case APPSolanaNetwork:
        return ReceiptAddress<SolAddress>(
            type: addr.type,
            view: addr.address,
            networkAddress: addr.addressObject);
      case APPCardanoNetwork:
        return ReceiptAddress<ADAAddress>(
            type: addr.type,
            view: addr.address,
            networkAddress: addr.addressObject);
      case APPCosmosNetwork:
        return ReceiptAddress<CosmosBaseAddress>(
            type: addr.type,
            view: addr.address,
            networkAddress: addr.addressObject);
      default:
        return ReceiptAddress<BitcoinBaseAddress>(
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

  void onTapContact() {
    context
        .openSliverBottomSheet(
      "new_contact".tr,
      child: AddToContactListView(
          contact: newContact.value!, network: widget.account.network),
    )
        .then((value) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("select_account".tr),
        bottom: TabBar(controller: controller, tabs: [
          Tab(text: "address".tr),
          Tab(text: "accounts".tr),
          Tab(text: "contacts".tr),
        ]),
      ),
      body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [],
          body: TabBarView(controller: controller, children: [
            _WriteAddress(
              formKey: formKey,
              onPaste: onPaste,
              onChanged: onChange,
              onSetup: onSetup,
              defaultValue: _address,
              showAddContact: newContact,
              textFieldKey: textFieldKey,
              subtitle: widget.subtitle,
              validator: validator,
              controller: widget.scrollController,
              onTappAddContact: onTapContact,
            ),
            _SelectFromAccounts(
                addresses: widget.account.addresses,
                controller: widget.scrollController,
                onSelectContact: onAccountOrContact),
            _SelectFromContacts(
                contacts: widget.account.contacts,
                controller: widget.scrollController,
                onSelectContact: onAccountOrContact),
          ])),
    );
  }
}

class _SelectFromAccounts extends StatelessWidget {
  const _SelectFromAccounts(
      {required this.addresses,
      required this.controller,
      required this.onSelectContact});
  final List<CryptoAccountAddress> addresses;
  final ScrollController controller;
  final StringVoid onSelectContact;
  @override
  Widget build(BuildContext context) {
    return ConstraintsBoxView(
      child: ListView.builder(
          itemCount: addresses.length,
          controller: controller,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return Padding(
              padding: WidgetConstant.paddingHorizontal10,
              child: ContainerWithBorder(
                onRemove: () {
                  onSelectContact(addresses[index].address.toAddress);
                },
                onRemoveWidget: const SizedBox(),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                          child: AddressDetailsView(address: addresses[index])),
                    ),
                    WidgetConstant.width8,
                    CopyTextIcon(
                        dataToCopy: addresses[index].address.toAddress),
                  ],
                ),
              ),
            );
          }),
    );
  }
}

class _SelectFromContacts extends StatelessWidget {
  const _SelectFromContacts(
      {required this.contacts,
      required this.controller,
      required this.onSelectContact});
  final List<ContactCore> contacts;
  final ScrollController controller;
  final StringVoid onSelectContact;
  @override
  Widget build(BuildContext context) {
    if (contacts.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.perm_contact_calendar_sharp,
              size: AppGlobalConst.double80),
          WidgetConstant.height8,
          Text("no_contacts_found".tr),
        ],
      );
    }
    return ConstraintsBoxView(
      child: ListView.builder(
          itemCount: contacts.length,
          shrinkWrap: true,
          controller: controller,
          primary: false,
          itemBuilder: (context, index) {
            return ContainerWithBorder(
              onRemoveWidget: const SizedBox(),
              onRemove: () {
                onSelectContact(contacts[index].address);
              },
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                        child: ContactAddressView(
                      contact: contacts[index],
                    )),
                  ),
                  WidgetConstant.width8,
                  CopyTextIcon(dataToCopy: contacts[index].address),
                ],
              ),
            );
          }),
    );
  }
}

class _WriteAddress extends StatelessWidget {
  const _WriteAddress(
      {required this.formKey,
      this.subtitle,
      required this.textFieldKey,
      this.onChanged,
      this.validator,
      required this.onPaste,
      required this.onSetup,
      required this.showAddContact,
      required this.controller,
      required this.defaultValue,
      required this.onTappAddContact});
  final ScrollController controller;
  final GlobalKey<FormState> formKey;
  final Widget? subtitle;
  final GlobalKey textFieldKey;
  final StringVoid? onChanged;
  final NullStringString? validator;
  final StringVoid onPaste;
  final DynamicVoid onSetup;
  final Live<ContactCore?> showAddContact;
  final String defaultValue;
  final DynamicVoid onTappAddContact;
  @override
  Widget build(BuildContext context) {
    return ConstraintsBoxView(
      padding: WidgetConstant.padding20,
      child: SingleChildScrollView(
        controller: controller,
        primary: false,
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              subtitle ??
                  PageTitleSubtitle(
                      title: "address_recipient_funds".tr,
                      body: Text("receiver_address_desc".tr)),
              AppTextField(
                key: textFieldKey,
                label: "address".tr,
                minlines: 1,
                initialValue: defaultValue,
                maxLines: 2,
                suffixIcon: Column(
                  children: [
                    LiveWidget(() {
                      final contact = showAddContact.value;
                      return AnimatedSize(
                        duration: AppGlobalConst.animationDuraion,
                        child: contact != null
                            ? IconButton(
                                onPressed: () {
                                  onTappAddContact();
                                },
                                icon: const Icon(Icons.account_circle),
                              )
                            : PasteTextIcon(onPaste: onPaste),
                      );
                    }),
                  ],
                ),
                validator: validator,
                onChanged: onChanged,
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
        ),
      ),
    );
  }
}
