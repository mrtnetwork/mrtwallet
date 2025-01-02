import 'package:blockchain_utils/helper/extensions/extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/global/global.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/crypto/utils/address/utils.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';

typedef RecipientFilter<NETWORKADDRESS> = String? Function(
    NETWORKADDRESS address);
typedef OnSelectRecipients<NETWORKADDRESS>
    = Future<List<ReceiptAddress<NETWORKADDRESS>>?> Function(
        {required APPCHAINNETWORK<NETWORKADDRESS> account,
        RecipientFilter<NETWORKADDRESS>? onFilterAccount,
        required List<ReceiptAddress<NETWORKADDRESS>> selectedAddresses});

class SelectRecipientAccountView<NETWORKADDRESS> extends StatefulWidget {
  const SelectRecipientAccountView(
      {super.key,
      required this.account,
      required this.scrollController,
      this.subtitle,
      this.multipleSelect = false,
      this.onFilterAccount,
      this.selectedAddresses = const []});
  final APPCHAINNETWORK<NETWORKADDRESS> account;
  final ScrollController scrollController;
  final Widget? subtitle;
  final bool multipleSelect;
  final RecipientFilter<NETWORKADDRESS>? onFilterAccount;
  final List<ReceiptAddress<NETWORKADDRESS>> selectedAddresses;

  @override
  State<SelectRecipientAccountView<NETWORKADDRESS>> createState() =>
      _SelectRecipientAccountViewState<NETWORKADDRESS>();
}

class _SelectRecipientAccountViewState<NETWORKADDRESS>
    extends State<SelectRecipientAccountView<NETWORKADDRESS>>
    with SingleTickerProviderStateMixin, SafeState {
  List<ReceiptAddress<NETWORKADDRESS>> multipleReceipments = [];
  late final List<NETWORKCHAINACCOUNT<NETWORKADDRESS>> addresses;
  List<NETWORKCHAINACCOUNT<NETWORKADDRESS>> selectedAccountAddresses = [];

  List<ContactCore<NETWORKADDRESS>> get contacts => widget.account.contacts;
  List<ContactCore<NETWORKADDRESS>> selectedAccountContacts = [];
  late final multipleSelect = widget.multipleSelect;
  bool showSubmit = false;

  late final TabController controller = TabController(length: 3, vsync: this);
  void _listener() {
    setState(() {});
  }

  void addReceipt(ReceiptAddress<NETWORKADDRESS>? receipt) {
    if (receipt == null) return;
    final filter = widget.onFilterAccount;
    if (filter != null) {
      final validate = filter(receipt.networkAddress);
      if (validate != null) {
        context.showAlert(validate);
        return;
      }
    }
    if (multipleSelect) {
      final r = multipleReceipments.remove(receipt);
      if (!r) {
        multipleReceipments.add(receipt);
      }
      showSubmit = multipleReceipments.isNotEmpty;
      if (receipt.account != null) {
        if (r) {
          selectedAccountAddresses.remove(receipt.account!);
        } else {
          selectedAccountAddresses.add(receipt.account!);
        }
      }
      if (receipt.contact != null) {
        if (r) {
          selectedAccountContacts.remove(receipt.contact!);
        } else {
          selectedAccountContacts.add(receipt.contact!);
        }
      }
      updateState();
    } else {
      context.pop(receipt);
    }
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    addresses = widget.account.addresses;
    multipleReceipments = widget.selectedAddresses.clone();
    selectedAccountAddresses = widget.selectedAddresses
        .map((e) => e.account)
        .whereType<NETWORKCHAINACCOUNT<NETWORKADDRESS>>()
        .toList();
    selectedAccountContacts = widget.selectedAddresses
        .map((e) => e.contact)
        .whereType<ContactCore<NETWORKADDRESS>>()
        .toList();
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
    final int? tag = int.tryParse(v ?? "");
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
    final filter = widget.onFilterAccount;
    if (filter != null) return filter(addr.addressObject);
    return null;
  }

  void onPaste(String v) {
    textFieldKey.currentState?.updateText(v);
  }

  void onAccountOrContact(String address) {
    final addr = _validate(address);
    if (addr == null) return;
    final ReceiptAddress<NETWORKADDRESS> receipt =
        widget.account.getReceiptAddress(addr.address) ??
            _buildReceiptAddress(addr);
    addReceipt(receipt);
  }

  ReceiptAddress<NETWORKADDRESS> _buildReceiptAddress(ContactCore addr) {
    return ReceiptAddress<NETWORKADDRESS>(
        view: addr.address,
        type: addr.type,
        networkAddress: addr.addressObject);
  }

  void onAddReceipt() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    ContactCore<NETWORKADDRESS>? addr;
    if (isRippleNetwork) {
      final validate = _validateRipple(_address, rippleAddressTag);
      addr = validate.$1;
    } else {
      addr = _validate(_address);
    }

    if (addr != null) {
      final ReceiptAddress<NETWORKADDRESS> receipt =
          widget.account.getReceiptAddress(addr.address) ??
              _buildReceiptAddress(addr);
      addReceipt(receipt);
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

  void onTapReview() async {
    if (multipleReceipments.isEmpty) return;
    final r = await context.openSliverBottomSheet<bool>("review_addresses".tr,
        slivers: [_ShowMultipleSelectedAddress<NETWORKADDRESS>(state: this)]);
    if (r == true && multipleReceipments.isNotEmpty) {
      context.pop(multipleReceipments);
      return;
    }
    updateState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: APPAnimatedSize(
          isActive: showSubmit,
          onActive: (context) => Badge.count(
                count: multipleReceipments.length,
                child: FloatingActionButton.extended(
                  onPressed: onTapReview,
                  icon: Icon(Icons.check_circle),
                  label: Text("review_addresses".tr),
                ),
              ),
          onDeactive: (context) => null),
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
            switch (isRippleNetwork) {
              false => _WriteAddress(state: this),
              true => _WriteRippleAddress(state: this)
            },
            _SelectFromAccounts(
                state: this, controller: widget.scrollController),
            _SelectFromContacts(
                state: this, controller: widget.scrollController)
          ])),
    );
  }
}

class _ShowMultipleSelectedAddress<NETWORKADDRESS> extends StatefulWidget {
  const _ShowMultipleSelectedAddress({required this.state});
  final _SelectRecipientAccountViewState state;

  @override
  State<_ShowMultipleSelectedAddress<NETWORKADDRESS>> createState() =>
      _ShowMultipleSelectedAddressState<NETWORKADDRESS>();
}

class _ShowMultipleSelectedAddressState<NETWORKADDRESS>
    extends State<_ShowMultipleSelectedAddress<NETWORKADDRESS>> with SafeState {
  late final List<ReceiptAddress<NETWORKADDRESS>> addresses =
      List.from(widget.state.multipleReceipments);
  void onTapAddress(ReceiptAddress<NETWORKADDRESS> addr) {
    widget.state.addReceipt(addr);
    updateState();
  }

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(slivers: [
      SliverConstraintsBoxView(
        padding: WidgetConstant.paddingHorizontal20,
        sliver: SliverList.builder(
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final addr = addresses[index];
              return ContainerWithBorder(
                  onRemove: () {
                    onTapAddress(addr);
                  },
                  onRemoveWidget: IgnorePointer(
                    child: Checkbox(
                      value: widget.state.multipleReceipments.contains(addr),
                      onChanged: (v) {},
                    ),
                  ),
                  child: ReceiptAddressDetailsView(
                      address: addr, color: context.colors.onPrimaryContainer));
            }),
      ),
      SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FixedElevatedButton(
                activePress: widget.state.multipleReceipments.isNotEmpty,
                padding: WidgetConstant.paddingVertical40,
                onPressed: () {
                  context.pop(true);
                },
                child: Text("setup_addresses".tr)),
          ],
        ),
      ),
    ]);
  }
}

class _SelectFromAccounts extends StatelessWidget {
  const _SelectFromAccounts({required this.state, required this.controller});
  final _SelectRecipientAccountViewState state;
  final ScrollController controller;
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: controller,
      slivers: [
        SliverConstraintsBoxView(
          padding: WidgetConstant.paddingHorizontal20,
          sliver: SliverList.builder(
              itemCount: state.addresses.length,
              itemBuilder: (context, index) {
                final addr = state.addresses[index];
                return ContainerWithBorder(
                  onRemove: () {
                    state.onAccountOrContact(addr.address.toAddress);
                  },
                  onRemoveWidget: ConditionalWidgets(
                      enable: state.multipleSelect,
                      widgets: {
                        true: (context) => IgnorePointer(
                              child: Checkbox(
                                  value: state.selectedAccountAddresses
                                      .contains(addr),
                                  onChanged: (v) {}),
                            )
                      }),
                  child: Row(
                    children: [
                      Expanded(
                        child: AddressDetailsView(
                            address: state.addresses[index],
                            color: context.onPrimaryContainer),
                      ),
                      WidgetConstant.width8,
                      CopyTextIcon(
                          isSensitive: false,
                          dataToCopy: state.addresses[index].address.toAddress)
                    ],
                  ),
                );
              }),
        )
      ],
    );
  }
}

class _SelectFromContacts extends StatelessWidget {
  const _SelectFromContacts({required this.controller, required this.state});
  // final;
  final ScrollController controller;
  final _SelectRecipientAccountViewState state;
  @override
  Widget build(BuildContext context) {
    return switch (state.contacts.isEmpty) {
      true => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.perm_contact_calendar_sharp,
                size: APPConst.double80),
            WidgetConstant.height8,
            Text("no_contacts_found".tr),
          ],
        ),
      false => ConstraintsBoxView(
          child: ListView.builder(
              itemCount: state.contacts.length,
              shrinkWrap: true,
              primary: false,
              itemBuilder: (context, index) {
                return ContainerWithBorder(
                  onRemoveWidget: ConditionalWidgets(
                      enable: state.multipleSelect,
                      widgets: {
                        true: (context) => IgnorePointer(
                              child: Checkbox(
                                  value: state.selectedAccountContacts
                                      .contains(state.contacts[index]),
                                  onChanged: (v) {}),
                            )
                      }),
                  onRemove: () {
                    state.onAccountOrContact(state.contacts[index].address);
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                            child: ContactAddressView(
                                contact: state.contacts[index])),
                      ),
                      WidgetConstant.width8,
                      CopyTextIcon(
                          isSensitive: false,
                          dataToCopy: state.contacts[index].address),
                    ],
                  ),
                );
              }),
        )
    };
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
                      padding: WidgetConstant.paddingVertical40,
                      onPressed: state.onAddReceipt,
                      child: ConditionalWidgets(
                          enable: state.multipleSelect,
                          widgets: {
                            false: (context) => Text("setup_address".tr),
                            true: (context) => Text("add_to_address".tr)
                          }))
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
                  // ,
                  FixedElevatedButton(
                      padding: WidgetConstant.paddingVertical40,
                      onPressed: state.onAddReceipt,
                      child: ConditionalWidgets(
                          enable: state.multipleSelect,
                          widgets: {
                            false: (context) => Text("setup_address".tr),
                            true: (context) => Text("add_to_address".tr)
                          }))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
