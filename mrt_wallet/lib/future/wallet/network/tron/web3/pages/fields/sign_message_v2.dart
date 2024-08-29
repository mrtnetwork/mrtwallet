import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/wallet/web3/networks/tron/tron.dart';

class TronWeb3SignMessageV2RequestView extends StatelessWidget {
  const TronWeb3SignMessageV2RequestView({required this.request, Key? key})
      : super(key: key);
  final TronWeb3Form<Web3TronSignMessageV2> request;
  Web3TronSignMessageV2 get param => request.request.params;
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("message".tr, style: context.textTheme.titleMedium),
          TextAndLinkView(
              text: "eth_personal_sign_desc".tr,
              url: LinkConst.aboutEthereumPersonalSign,
              linkDesc: "read_more".tr),
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
                    request.confirmRequest();
                  })
            ],
          )
        ],
      ),
    );
  }
}
