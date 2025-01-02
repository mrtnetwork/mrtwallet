import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/global/app.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/web3/pages/client_info.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/models/models.dart';
import 'package:mrt_wallet/wallet/web3/core/request/web_request.dart';

class Web3PermissionAppbarActionView extends StatelessWidget {
  const Web3PermissionAppbarActionView({required this.request, super.key});
  final Web3Request request;
  Chain get chain => request.chain;
  WalletNetwork get network => chain.network;
  @override
  Widget build(BuildContext context) {
    return TappedTooltipView(
      tooltipWidget: ToolTipView(
        padding: EdgeInsets.zero,
        tooltipWidget: (c) => Container(
          padding: WidgetConstant.padding10,
          constraints:
              const BoxConstraints(maxWidth: APPConst.tooltipConstrainedWidth),
          decoration: BoxDecoration(
              borderRadius: WidgetConstant.border8,
              color: context.colors.surface),
          child: Column(
            children: [
              ContainerWithBorder(
                child: Row(
                  children: [
                    CircleTokenImageView(network.coinParam.token,
                        radius: APPConst.circleRadius25),
                    WidgetConstant.width8,
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        OneLineTextWidget(
                          network.token.name,
                          style: context.onPrimaryTextTheme.bodyMedium,
                        ),
                        CoinPriceView(
                          token: network.token,
                          balance: chain.totalBalance.value,
                          style: context.onPrimaryTextTheme.labelLarge,
                          symbolColor: context.onPrimaryContainer,
                        )
                      ],
                    )),
                  ],
                ),
              ),
              WidgetConstant.height20,
              Web3ClientInfoView(
                  permission: request.authenticated, info: request.info),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleTokenImageView(network.token, radius: 15),
            Text(network.token.nameView, style: context.textTheme.labelMedium)
          ],
        ),
      ),
    );
  }
}
