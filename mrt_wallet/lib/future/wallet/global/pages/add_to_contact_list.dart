import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/models/models.dart';

class AddToContactListView<NETWORKADDRESS> extends StatefulWidget {
  const AddToContactListView(
      {super.key, required this.contact, required this.chain});
  final ContactCore<NETWORKADDRESS> contact;
  final APPCHAINNETWORK<NETWORKADDRESS> chain;

  @override
  State<AddToContactListView<NETWORKADDRESS>> createState() =>
      _AddToContactListViewState<NETWORKADDRESS>();
}

class _AddToContactListViewState<NETWORKADDRESS>
    extends State<AddToContactListView<NETWORKADDRESS>> {
  final GlobalKey<FormState> formKey = GlobalKey(debugLabel: "SelectAddress_1");
  final GlobalKey<AppTextFieldState> textFieldKey =
      GlobalKey(debugLabel: "SelectAddress");
  final GlobalKey<StreamWidgetState> buttonProgressKey =
      GlobalKey<StreamWidgetState>();
  bool added = false;
  late String name = widget.contact.name.tr;
  void onChange(String v) {
    name = v;
    if (_error != null) {
      _error = null;
      setState(() {});
    }
  }

  void onPaste(String v) {
    textFieldKey.currentState?.updateText(v);
  }

  String? validator(String? v) {
    if (v == null || v.length < 3) {
      return "contact_name_validator".tr;
    }
    return null;
  }

  String? _error;

  void onTapAdd() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    buttonProgressKey.process();
    final wallet = context.watch<WalletProvider>(StateConst.main);
    final ContactCore<NETWORKADDRESS> newContact =
        ContactCore.newContact<NETWORKADDRESS>(
            network: widget.chain.network,
            address: widget.contact.addressObject,
            name: name);
    final result = await wallet.wallet
        .addNewContact(account: widget.chain, newContact: newContact);
    if (result.hasError) {
      buttonProgressKey.error();
      _error = result.error?.tr;
      setState(() {});
    } else {
      added = true;
      buttonProgressKey.success();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageTitleSubtitle(
              title: "add_to_contacts".tr,
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("contact_desc_1"
                      .tr
                      .replaceOne(widget.chain.network.token.name))
                ],
              )),
          Text("address".tr, style: context.textTheme.titleMedium),
          WidgetConstant.height8,
          ContainerWithBorder(child: Text(widget.contact.address)),
          AnimatedSize(
            duration: APPConst.animationDuraion,
            alignment: Alignment.topCenter,
            child: added
                ? WidgetConstant.sizedBox
                : Column(
                    children: [
                      WidgetConstant.height20,
                      AppTextField(
                        key: textFieldKey,
                        label: "name_of_contact".tr,
                        initialValue: name,
                        readOnly: buttonProgressKey.inProgress,
                        minlines: 1,
                        maxLines: 2,
                        error: _error,
                        suffixIcon: PasteTextIcon(
                          onPaste: onPaste,
                          isSensitive: false,
                        ),
                        validator: validator,
                        onChanged: onChange,
                      ),
                    ],
                  ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              added
                  ? Column(
                      children: [
                        WidgetConstant.checkCircleLarge,
                        WidgetConstant.height8,
                        Text("contact_saved".tr)
                      ],
                    )
                  : StreamWidget(
                      padding: WidgetConstant.paddingVertical20,
                      buttonWidget: FixedElevatedButton(
                        onPressed: onTapAdd,
                        child: Text("add_to_contacts".tr),
                      ),
                      backToIdle: APPConst.oneSecoundDuration,
                      key: buttonProgressKey,
                    ),
            ],
          ),
        ],
      ),
    );
  }
}
