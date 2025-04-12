import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/wallet/web3/networks/networks.dart';

class BitcoinWeb3SignMessageRequestView extends StatelessWidget {
  const BitcoinWeb3SignMessageRequestView({required this.request, super.key});
  final Web3BitcoinSignMessageForm request;
  Web3BitcoinSignMessage get param => request.request.params;
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ErrorTextContainer(
              error: "sign_message_private_key_desc".tr, enableTap: false),
          WidgetConstant.height20,
          Text("message".tr, style: context.textTheme.titleMedium),
          Text("sign_message_private_key".tr),
          WidgetConstant.height8,
          ContainerWithBorder(
              onRemove: () {},
              onRemoveWidget:
                  CopyTextIcon(dataToCopy: request.message, isSensitive: false),
              enableTap: false,
              child: Text(request.message,
                  style: context.onPrimaryTextTheme.bodyMedium)),
          if (request.content != null) ...[
            WidgetConstant.height20,
            Text("content".tr, style: context.textTheme.titleMedium),
            ContainerWithBorder(
                onRemove: () {},
                onRemoveWidget: CopyTextIcon(
                    dataToCopy: request.content ?? "", isSensitive: false),
                enableTap: false,
                child: SelectableText(request.content ?? "",
                    style: context.onPrimaryTextTheme.bodyMedium,
                    minLines: 1,
                    maxLines: 5)),
          ],
          WidgetConstant.height20,
          Text("prefix".tr, style: context.textTheme.titleMedium),
          ContainerWithBorder(
              onRemove: () {},
              onRemoveWidget: CopyTextIcon(
                  dataToCopy: request.messagePrefix, isSensitive: false),
              enableTap: false,
              child: SelectableText(request.messagePrefix,
                  style: context.onPrimaryTextTheme.bodyMedium,
                  minLines: 1,
                  maxLines: 5)),
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
                                      enableTap: false,
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
