import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/wallet/models/networks/cosmos/cosmos.dart';

class SelectCosmosAccountIbcChannelView extends StatelessWidget {
  final List<CosmosIBCChannelId> channels;
  const SelectCosmosAccountIbcChannelView(this.channels, {super.key});

  @override
  Widget build(BuildContext context) {
    return ConditionalWidget(
      enable: channels.isNotEmpty,
      onDeactive: (context) {
        return NoItemFoundWidget();
      },
      onActive: (context) {
        return ListView.separated(
          itemBuilder: (context, index) {
            final channel = channels[index];
            return ContainerWithBorder(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("name".tr,
                        style: context.onPrimaryTextTheme.titleMedium),
                    WidgetConstant.height8,
                    ContainerWithBorder(
                      backgroundColor: context.onPrimaryContainer,
                      child: Text(channel.name,
                          style: context.primaryTextTheme.bodyMedium),
                    ),
                    WidgetConstant.height20,
                    Text("channel_id".tr,
                        style: context.onPrimaryTextTheme.titleMedium),
                    WidgetConstant.height8,
                    ContainerWithBorder(
                      backgroundColor: context.onPrimaryContainer,
                      child: CopyableTextWidget(
                          text: channel.channelId,
                          color: context.primaryContainer),
                    ),
                  ]),
            );
          },
          separatorBuilder: (context, index) => WidgetConstant.sizedBox,
          itemCount: channels.length,
          shrinkWrap: true,
          physics: WidgetConstant.noScrollPhysics,
        );
      },
    );
  }
}
