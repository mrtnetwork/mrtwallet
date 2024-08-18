import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/global/global.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/crypto/utils/address/utils.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';

class SelectRecipientAccountView<NETWORKADDRESS> extends StatefulWidget {
  const SelectRecipientAccountView(
      {super.key,
      required this.account,
      required this.scrollController,
      this.subtitle,
      this.multipleSelect = true});
  final APPCHAINNETWORK<NETWORKADDRESS> account;
  final ScrollController scrollController;
  final Widget? subtitle;
  final bool multipleSelect;

  @override
  State<SelectRecipientAccountView<NETWORKADDRESS>> createState() =>
      _SelectRecipientAccountViewState<NETWORKADDRESS>();
}

class _SelectRecipientAccountViewState<NETWORKADDRESS>
    extends State<SelectRecipientAccountView<NETWORKADDRESS>>
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

  final GlobalKey<AppTextFieldState> textFieldKey =
      GlobalKey(debugLabel: "SelectAddress");
  final GlobalKey<FormState> formKey = GlobalKey(debugLabel: "SelectAddress_1");
  late final WalletNetwork network = widget.account.network;
  late final bool isRippleNetwork = network.type == NetworkType.xrpl;
  String _address = "";
  Live<ContactCore<NETWORKADDRESS>?> newContact =
      Live<ContactCore<NETWORKADDRESS>?>(null);

  void onChange(String v) {
    _address = v;
  }

  bool useRippleTag = false;
  int? rippleAddressTag;

  void onChangeTag(int v) {
    rippleAddressTag = v;
  }

  void onUseRippleTag(bool? v) {
    useRippleTag = !useRippleTag;
    rippleAddressTag = null;
    updateState();
  }

  ContactCore<NETWORKADDRESS>? _toNewContact(Object? addr) {
    return ContactCore.newContact<NETWORKADDRESS>(
        network: network, address: addr, name: "new_address".tr);
  }

  ContactCore<NETWORKADDRESS>? _validate(String? address) {
    final addr =
        BlockchainAddressUtils.validateNetworkAddress(address, network);
    if (addr == null) return null;
    return _toNewContact(addr as NETWORKADDRESS);
  }

  (ContactCore<NETWORKADDRESS>?, String? error) _validateRipple(
      String? address, int? tag) {
    if (address == null) return (null, null);
    final addr = MethodUtils.nullOnException(() =>
        BlockchainAddressUtils.toRippleAddress(address, network.toNetwork()));
    if (addr == null) return (null, null);
    if (tag != null) {
      if (addr.tag == tag) return (_toNewContact(addr), null);
      if (addr.tag != null && addr.tag != tag) {
        return (null, "ripple_xaddress_tag_validator".tr);
      }
      final newAddress = BlockchainAddressUtils.validateXAddressTag(
          addr: address, network: network.toNetwork(), tag: tag);
      return (_toNewContact(newAddress), null);
    }
    return (_toNewContact(addr), null);
  }

  void _setValidate(ContactCore<NETWORKADDRESS>? contact) {
    if (contact == null) {
      newContact.value = null;
    } else {
      final inContact = widget.account.getReceiptAddress(contact.address);

      if (inContact != null) {
        newContact.value = null;
      } else {
        newContact.value = contact;
      }
      if (isDebug) {
        newContact.value = contact;
      }
    }
  }

  String? validatorTag(String? v) {
    int? tag = int.tryParse(v ?? "");
    if (tag == null || tag != rippleAddressTag) {
      return "ripple_address_validator_desc".tr;
    }
    return null;
  }

  String? validator(String? v) {
    ContactCore<NETWORKADDRESS>? addr;
    String? error;
    if (isRippleNetwork) {
      final validate = _validateRipple(v, rippleAddressTag);
      addr = validate.$1;
      error = validate.$2;
    } else {
      addr = _validate(v);
    }
    _setValidate(addr);
    if (useRippleTag && rippleAddressTag == null) {
      return "ripple_address_validator_desc".tr;
    }
    if (addr == null) {
      return error ?? "invalid_network_address".tr;
    }
    return null;
  }

  void onPaste(String v) {
    textFieldKey.currentState?.updateText(v);
  }

  void onAccountOrContact(String address) {
    final addr = _validate(address);
    if (addr == null) return;

    ReceiptAddress<NETWORKADDRESS>? receipt =
        widget.account.getReceiptAddress(addr.address) ??
            _buildReceiptAddress(addr);
    context.pop(receipt);
  }

  ReceiptAddress<NETWORKADDRESS> _buildReceiptAddress(ContactCore addr) {
    return ReceiptAddress<NETWORKADDRESS>(
        view: addr.address,
        type: addr.type,
        networkAddress: addr.addressObject);
  }

  void onSetup() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    ContactCore<NETWORKADDRESS>? addr;
    if (isRippleNetwork) {
      final validate = _validateRipple(_address, rippleAddressTag);
      addr = validate.$1;
    } else {
      addr = _validate(_address);
    }

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
      child: AddToContactListView<NETWORKADDRESS>(
          contact: newContact.value!, chain: widget.account),
    )
        .then((value) {
      setState(() {});
    });
  }

  bool get isDebug => kDebugMode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("select_account".tr),
        bottom: TabBar(controller: controller, tabs: [
          Tab(text: "address".tr),
          Tab(text: "accounts".tr),
          Tab(text: "contacts".tr)
        ]),
      ),
      body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [],
          body: TabBarView(controller: controller, children: [
            if (isRippleNetwork)
              _WriteRippleAddress(state: this)
            else
              _WriteAddress(state: this),
            _SelectFromAccounts(
                addresses: widget.account.addresses,
                controller: widget.scrollController,
                onSelectContact: onAccountOrContact),
            _SelectFromContacts(
                contacts: widget.account.contacts,
                controller: widget.scrollController,
                onSelectContact: onAccountOrContact)
          ])),
    );
  }
}

class _SelectFromAccounts extends StatelessWidget {
  const _SelectFromAccounts(
      {required this.addresses,
      required this.controller,
      required this.onSelectContact});
  final List<ChainAccount> addresses;
  final ScrollController controller;
  final StringVoid onSelectContact;
  @override
  Widget build(BuildContext context) {
    return ConstraintsBoxView(
      child: CustomScrollView(
        controller: controller,
        slivers: [
          SliverList.builder(
              itemCount: addresses.length,
              // controller: controller,
              // shrinkWrap: true,
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
                              child: AddressDetailsView(
                            address: addresses[index],
                          )),
                        ),
                        WidgetConstant.width8,
                        CopyTextIcon(
                            isSensitive: false,
                            dataToCopy: addresses[index].address.toAddress),
                      ],
                    ),
                  ),
                );
              })
        ],
      ),
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
              size: APPConst.double80),
          WidgetConstant.height8,
          Text("no_contacts_found".tr),
        ],
      );
    }
    return ConstraintsBoxView(
      child: ListView.builder(
          itemCount: contacts.length,
          shrinkWrap: true,
          // controller: controller,
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
                  CopyTextIcon(
                    isSensitive: false,
                    dataToCopy: contacts[index].address,
                  ),
                ],
              ),
            );
          }),
    );
  }
}

class _WriteAddress extends StatelessWidget {
  const _WriteAddress({required this.state});
  final _SelectRecipientAccountViewState state;
  @override
  Widget build(BuildContext context) {
    return ConstraintsBoxView(
      padding: WidgetConstant.padding20,
      child: SingleChildScrollView(
        primary: false,
        child: Form(
          key: state.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              state.widget.subtitle ??
                  PageTitleSubtitle(
                      title: "address_recipient_funds".tr,
                      body: Text("receiver_address_desc".tr)),
              AppTextField(
                key: state.textFieldKey,
                label: "address".tr,
                minlines: 1,
                initialValue: state._address,
                maxLines: 2,
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LiveWidget(() {
                      final contact = state.newContact.value;
                      return APPAnimatedSwitcher(
                        widgets: {
                          true: (c) => IconButton(
                                onPressed: () {
                                  state.onTapContact();
                                },
                                icon: const Icon(Icons.account_circle),
                              ),
                          false: (c) => PasteTextIcon(
                                onPaste: state.onPaste,
                                isSensitive: false,
                              )
                        },
                        enable: contact != null,
                      );
                    }),
                    BarcodeScannerIconView(state.onPaste),
                  ],
                ),
                validator: state.validator,
                onChanged: state.onChange,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FixedElevatedButton(
                      padding: WidgetConstant.paddingVertical20,
                      onPressed: state.onSetup,
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

class _WriteRippleAddress extends StatelessWidget {
  const _WriteRippleAddress({required this.state});
  final _SelectRecipientAccountViewState state;
  @override
  Widget build(BuildContext context) {
    return ConstraintsBoxView(
      padding: WidgetConstant.padding20,
      child: SingleChildScrollView(
        primary: false,
        child: Form(
          key: state.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              state.widget.subtitle ??
                  PageTitleSubtitle(
                      title: "address_recipient_funds".tr,
                      body: Text("receiver_address_desc".tr)),
              AppTextField(
                key: state.textFieldKey,
                label: "address".tr,
                minlines: 1,
                initialValue: state._address,
                maxLines: 2,
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LiveWidget(() {
                      final contact = state.newContact.value;
                      return APPAnimatedSwitcher(
                        widgets: {
                          true: (c) => IconButton(
                                onPressed: () {
                                  state.onTapContact();
                                },
                                icon: const Icon(Icons.account_circle),
                              ),
                          false: (c) => PasteTextIcon(
                                onPaste: state.onPaste,
                                isSensitive: false,
                              )
                        },
                        enable: contact != null,
                      );
                    }),
                    BarcodeScannerIconView(state.onPaste),
                  ],
                ),
                validator: state.validator,
                onChanged: state.onChange,
              ),
              WidgetConstant.height20,
              AppCheckListTile(
                contentPadding: EdgeInsets.zero,
                title: Text("insert_address_tag".tr,
                    style: context.textTheme.titleMedium),
                subtitle: Text("ripple_xaddress_feature".tr),
                onChanged: state.onUseRippleTag,
                value: state.useRippleTag,
              ),
              APPAnimatedSize(
                  isActive: state.useRippleTag,
                  onActive: (c) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          WidgetConstant.height8,
                          NumberTextField(
                              label: "tag".tr,
                              onChange: state.onChangeTag,
                              max: RippleConst.maxRippleTag,
                              defaultValue: state.rippleAddressTag,
                              validator: state.validatorTag,
                              min: 0),
                        ],
                      ),
                  onDeactive: (c) => WidgetConstant.sizedBox),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FixedElevatedButton(
                      padding: WidgetConstant.paddingVertical40,
                      onPressed: state.onSetup,
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
