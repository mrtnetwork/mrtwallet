import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/wallet/web3/networks/networks.dart';
import 'package:on_chain/ethereum/src/eip_4361/types/eip_4631.dart';

class SolanaWeb3SignMessageRequestView extends StatelessWidget {
  const SolanaWeb3SignMessageRequestView({required this.request, super.key});
  final Web3SolanaSignMessageForm request;
  Web3SolanaSignMessage get param => request.request.params;
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ContainerWithBorder(
              backgroundColor: context.colors.errorContainer,
              enableTap: false,
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
          ListView.separated(
              itemBuilder: (context, index) {
                final message = request.messages[index];
                return _SignMessageItemView(message: message);
              },
              separatorBuilder: (context, index) {
                return WidgetConstant.divider;
              },
              itemCount: request.messages.length,
              shrinkWrap: true,
              physics: WidgetConstant.noScrollPhysics),
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

class _SignMessageItemView extends StatelessWidget {
  final Web3SolanaSignMessageItemView message;
  const _SignMessageItemView({required this.message});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("account".tr, style: context.textTheme.titleMedium),
      Text("web3_request_account_desc".tr),
      WidgetConstant.height8,
      ContainerWithBorder(
          child: AddressDetailsView(
              address: message.address, color: context.onPrimaryContainer)),
      WidgetConstant.height20,
      Text("message".tr, style: context.textTheme.titleMedium),
      Text("sign_message_private_key".tr),
      WidgetConstant.height8,
      ContainerWithBorder(
          onRemove: () {},
          enableTap: false,
          onRemoveWidget: WidgetConstant.sizedBox,
          child: CopyableTextWidget(
              text: message.params.data, isSensitive: false)),
      if (message.params.content != null) ...[
        WidgetConstant.height20,
        Text("content".tr, style: context.textTheme.titleMedium),
        ContainerWithBorder(
          onRemove: () {},
          onRemoveWidget: WidgetConstant.sizedBox,
          enableTap: false,
          child: CopyableTextWidget(
            text: message.params.content!,
            widget: SelectableText(
              message.params.content!,
              style: context.onPrimaryTextTheme.bodyMedium,
              minLines: 1,
              maxLines: 5,
            ),
            isSensitive: false,
            maxLines: 10,
          ),
        ),
      ],
      ConditionalWidget(
          enable: message.isSignIn,
          onActive: (context) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WidgetConstant.height20,
                  Text("sign_in_data".tr, style: context.textTheme.titleMedium),
                  WidgetConstant.height8,
                  ContainerWithBorder(
                    child: APPExpansionListTile(
                      title: Text('content'.tr,
                          style: context.onPrimaryTextTheme.bodyMedium),
                      children: [
                        ContainerWithBorder(
                          child: _EIP4631ContentView(
                              params: message.params as Web3SolanaSignInParams),
                        )
                      ],
                    ),
                  ),
                ],
              ))
    ]);
  }
}

class _EIP4631ContentView extends StatelessWidget {
  final Web3SolanaSignInParams params;
  EIP4631 get message => params.message;
  const _EIP4631ContentView({required this.params});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('domain'.tr, style: context.onPrimaryTextTheme.titleMedium),
      WidgetConstant.height8,
      ContainerWithBorder(
          backgroundColor: context.onPrimaryContainer,
          child: CopyableTextWidget(
            text: message.domain,
            color: context.primaryContainer,
          )),
      if (message.hasStatement) ...[
        WidgetConstant.height20,
        Text('statement'.tr, style: context.onPrimaryTextTheme.titleMedium),
        WidgetConstant.height8,
        ContainerWithBorder(
            backgroundColor: context.onPrimaryContainer,
            child: CopyableTextWidget(
              text: message.statement!,
              color: context.primaryContainer,
            ))
      ],
      if (message.hasUri) ...[
        WidgetConstant.height20,
        Text('uri'.tr, style: context.onPrimaryTextTheme.titleMedium),
        WidgetConstant.height8,
        ContainerWithBorder(
            backgroundColor: context.onPrimaryContainer,
            child: CopyableTextWidget(
              text: message.uri!,
              color: context.primaryContainer,
            ))
      ],
      if (message.hasIssuedAt) ...[
        WidgetConstant.height20,
        Text('issued_at'.tr, style: context.onPrimaryTextTheme.titleMedium),
        WidgetConstant.height8,
        ContainerWithBorder(
            backgroundColor: context.onPrimaryContainer,
            child: CopyableTextWidget(
              text: message.issuedAt!,
              color: context.primaryContainer,
            ))
      ],
      if (message.hasNotBefore) ...[
        WidgetConstant.height20,
        Text('not_before'.tr, style: context.onPrimaryTextTheme.titleMedium),
        WidgetConstant.height8,
        ContainerWithBorder(
            backgroundColor: context.onPrimaryContainer,
            child: CopyableTextWidget(
              text: message.notBefore!,
              color: context.primaryContainer,
            ))
      ],
      if (message.hasExpirationTime) ...[
        WidgetConstant.height20,
        Text('expiration_time'.tr,
            style: context.onPrimaryTextTheme.titleMedium),
        WidgetConstant.height8,
        ContainerWithBorder(
            backgroundColor: context.onPrimaryContainer,
            child: CopyableTextWidget(
              text: message.expirationTime!,
              color: context.primaryContainer,
            ))
      ],
      if (message.hasNonce) ...[
        WidgetConstant.height20,
        Text('nonce'.tr, style: context.onPrimaryTextTheme.titleMedium),
        WidgetConstant.height8,
        ContainerWithBorder(
            backgroundColor: context.onPrimaryContainer,
            child: CopyableTextWidget(
              text: message.nonce!,
              color: context.primaryContainer,
            ))
      ],
      if (message.hasVersion) ...[
        WidgetConstant.height20,
        Text('version'.tr, style: context.onPrimaryTextTheme.titleMedium),
        WidgetConstant.height8,
        ContainerWithBorder(
            backgroundColor: context.onPrimaryContainer,
            child: CopyableTextWidget(
              text: message.version!,
              color: context.primaryContainer,
            ))
      ],
      if (message.hasRequestId) ...[
        WidgetConstant.height20,
        Text('request_id'.tr, style: context.onPrimaryTextTheme.titleMedium),
        WidgetConstant.height8,
        ContainerWithBorder(
            backgroundColor: context.onPrimaryContainer,
            child: CopyableTextWidget(
              text: message.requestId!,
              color: context.primaryContainer,
            ))
      ],
      if (message.hasResources) ...[
        WidgetConstant.height20,
        Text('resources'.tr, style: context.onPrimaryTextTheme.titleMedium),
        WidgetConstant.height8,
        ...List.generate(message.resources!.length, (i) {
          final resource = message.resources![i];
          return ContainerWithBorder(
              backgroundColor: context.onPrimaryContainer,
              child: CopyableTextWidget(
                text: resource,
                color: context.primaryContainer,
              ));
        }),
      ],
    ]);
  }
}
