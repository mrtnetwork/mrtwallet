import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/global_pages/address_details.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

class SelectAccountOrContactView extends StatefulWidget {
  const SelectAccountOrContactView(
      {super.key, required this.account, required this.scrollController});
  final NetworkAccountCore account;
  final ScrollController scrollController;

  @override
  State<SelectAccountOrContactView> createState() =>
      _SelectAccountOrContactViewState();
}

class _SelectAccountOrContactViewState extends State<SelectAccountOrContactView>
    with SingleTickerProviderStateMixin, SafeState {
  late final TabController controller = TabController(length: 2, vsync: this);
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("select_account".tr),
        bottom: TabBar(
            controller: controller,
            tabs: [Tab(text: "accounts".tr), Tab(text: "contacts".tr)]),
      ),
      body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [],
          body: TabBarView(controller: controller, children: [
            _SelectFromAccounts(
                addresses: widget.account.addresses,
                controller: widget.scrollController),
            _SelectFromContacts(
                contacts: widget.account.contacts,
                controller: widget.scrollController),
          ])),
    );
  }
}

class _SelectFromAccounts extends StatelessWidget {
  const _SelectFromAccounts(
      {required this.addresses, required this.controller});
  final List<CryptoAccountAddress> addresses;
  final ScrollController controller;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: addresses.length,
        controller: controller,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Padding(
            padding: WidgetConstant.paddingHorizontal10,
            child: ContainerWithBorder(
              onRemove: () {
                if (context.mounted) {
                  context.pop(addresses[index].address.toAddress);
                }
              },
              onRemoveWidget: const SizedBox(),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                        child: AddressDetailsView(
                            address: addresses[index], isSelected: false)),
                  ),
                  WidgetConstant.width8,
                  CopyTextIcon(dataToCopy: addresses[index].address.toAddress),
                ],
              ),
            ),
          );
        });
  }
}

class _SelectFromContacts extends StatelessWidget {
  const _SelectFromContacts({required this.contacts, required this.controller});
  final List<ContactCore> contacts;
  final ScrollController controller;
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
    return ListView.builder(
        itemCount: contacts.length,
        shrinkWrap: true,
        controller: controller,
        primary: false,
        itemBuilder: (context, index) {
          return ContainerWithBorder(
            onRemoveWidget: const SizedBox(),
            onRemove: () {
              if (context.mounted) {
                context.pop(contacts[index].address);
              }
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
        });
  }
}
