import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/global/global.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';

class SelectRecipientAccountView<NETWORKADDRESS> extends StatefulWidget {
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
      _SelectRecipientAccountViewState<NETWORKADDRESS>();
}

class _SelectRecipientAccountViewState<NETWORKADDRESS>
    extends State<SelectRecipientAccountView>
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
  String _address = "";
  Live<ContactCore?> newContact = Live<ContactCore?>(null);

  void onChange(String v) {
    _address = v;
  }

  ContactCore<NETWORKADDRESS>? validate(String? address) {
    final addr =
        BlockchainAddressUtils.validateNetworkAddress(address, network);
    if (addr == null) return null;
    final contact = ContactCore.newContact<NETWORKADDRESS>(
        network: network, address: addr, name: "new_address".tr);
    return contact as ContactCore<NETWORKADDRESS>;
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
    ReceiptAddress<NETWORKADDRESS>? receipt =
        widget.account.getReceiptAddress(addr.address)
                as ReceiptAddress<NETWORKADDRESS>? ??
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
            _WriteAddress(state: this),
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
  final List<CryptoAddress> addresses;
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
  const _WriteAddress({required this.state});
  final _SelectRecipientAccountViewState state;
  @override
  Widget build(BuildContext context) {
    return ConstraintsBoxView(
      padding: WidgetConstant.padding20,
      child: SingleChildScrollView(
        controller: state.widget.scrollController,
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
                suffixIcon: Column(
                  children: [
                    LiveWidget(() {
                      final contact = state.newContact.value;
                      return AnimatedSize(
                        duration: APPConst.animationDuraion,
                        child: contact != null
                            ? IconButton(
                                onPressed: () {
                                  state.onTapContact();
                                },
                                icon: const Icon(Icons.account_circle),
                              )
                            : PasteTextIcon(onPaste: state.onPaste),
                      );
                    }),
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
