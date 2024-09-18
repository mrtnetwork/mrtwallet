import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/wallet/web3/networks/networks.dart';

class SolanaWeb3SignMessageRequestView extends StatelessWidget {
  const SolanaWeb3SignMessageRequestView({required this.request, Key? key})
      : super(key: key);
  final Web3SolanaSignMessageForm<Web3SolanaSignMessage> request;
  Web3SolanaSignMessage get param => request.request.params;
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ContainerWithBorder(
              backgroundColor: context.colors.errorContainer,
              onTapWhenOnRemove: false,
              child: Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: context.colors.error,
                    size: APPConst.double40,
                  ),
                  WidgetConstant.width8,
                  Expanded(
                    child: Text("sign_message_private_key_desc".tr,
                        style: context.colors.onErrorContainer
                            .bodyMedium(context)),
                  ),
                ],
              )),
          WidgetConstant.height20,
          Text("message".tr, style: context.textTheme.titleMedium),
          Text("sign_message_private_key".tr),
          WidgetConstant.height8,
          ContainerWithBorder(
              onRemove: () {},
              onRemoveWidget:
                  CopyTextIcon(dataToCopy: param.challeng, isSensitive: false),
              onTapWhenOnRemove: false,
              child: Text(param.challeng,
                  style:
                      context.colors.onPrimaryContainer.bodyMedium(context))),
          if (param.content != null) ...[
            WidgetConstant.height20,
            Text("content".tr, style: context.textTheme.titleMedium),
            ContainerWithBorder(
                onRemove: () {},
                onRemoveWidget: CopyTextIcon(
                    dataToCopy: param.content ?? "", isSensitive: false),
                onTapWhenOnRemove: false,
                child: SelectableText(
                  param.content ?? "",
                  style: context.colors.onPrimaryContainer.bodyMedium(context),
                  minLines: 1,
                  maxLines: 5,
                )),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FixedElevatedButton(
                  padding: WidgetConstant.paddingVertical40,
                  child: Text("sign_message".tr),
                  onPressed: () {
                    request.signMessage(() async {
                      return context.openSliverDialog<bool>(
                          (ctx) => DialogTextView(
                              widget: Column(
                                children: [
                                  Icon(
                                    Icons.warning,
                                    color: context.colors.error,
                                    size: APPConst.double80,
                                  ),
                                  WidgetConstant.height8,
                                  ContainerWithBorder(
                                      backgroundColor:
                                          context.colors.errorContainer,
                                      onTapWhenOnRemove: false,
                                      child: Text(
                                          "sign_message_private_key_desc".tr,
                                          style: context.colors.onErrorContainer
                                              .bodyMedium(context))),
                                ],
                              ),
                              buttonWidget: const AsyncDialogDoubleButtonView(),
                              text: "sign_message_private_key_desc".tr),
                          "sign_message".tr);
                    });
                  })
            ],
          )
        ],
      ),
    );
  }
}
