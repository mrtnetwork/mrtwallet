import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/start_page/home.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/main.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

class AddToContactListView extends StatefulWidget {
  const AddToContactListView(
      {super.key, required this.contact, required this.network});
  final ContactCore contact;
  final AppNetworkImpl network;

  @override
  State<AddToContactListView> createState() => _AddToContactListViewState();
}

class _AddToContactListViewState extends State<AddToContactListView> {
  final GlobalKey<FormState> formKey = GlobalKey(debugLabel: "SelectAddress_1");
  final GlobalKey<AppTextFieldState> textFieldKey =
      GlobalKey(debugLabel: "SelectAddress");
  final GlobalKey<StreamWidgetState> buttomProgressKey =
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
    buttomProgressKey.process();
    final wallet = context.watch<WalletProvider>(StateIdsConst.main);
    final newContact = ContactCore.newContact(
        network: widget.network,
        address: widget.contact.addressObject,
        name: name);
    final result = await wallet.addNewContact(newContact);
    if (result.hasError) {
      buttomProgressKey.error();
      _error = result.error?.tr;
      setState(() {});
    } else {
      added = true;
      buttomProgressKey.success();
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
                      .replaceOne(widget.network.coinParam.token.name))
                ],
              )),
          Text("address".tr, style: context.textTheme.titleMedium),
          WidgetConstant.height8,
          ContainerWithBorder(child: Text(widget.contact.address)),
          WidgetConstant.height20,
          AppTextField(
            key: textFieldKey,
            label: "name_of_contact".tr,
            initialValue: name,
            readOnly: buttomProgressKey.inProgress,
            minlines: 1,
            maxLines: 2,
            error: _error,
            suffixIcon: PasteTextIcon(onPaste: onPaste),
            validator: validator,
            onChanged: onChange,
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
                      buttomWidget: FixedElevatedButton(
                        onPressed: onTapAdd,
                        child: Text("add_to_contacts".tr),
                      ),
                      backToIdle: AppGlobalConst.oneSecoundDuration,
                      key: buttomProgressKey,
                    ),
            ],
          ),
        ],
      ),
    );
  }
}
