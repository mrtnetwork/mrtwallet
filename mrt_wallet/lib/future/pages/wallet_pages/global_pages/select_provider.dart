import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/wallet_models/network/network_models.dart';
import 'package:mrt_wallet/provider/api/core/api_provider.dart';

class SelectProviderView extends StatelessWidget {
  const SelectProviderView(
      {super.key,
      required this.selectedProvider,
      required this.network,
      this.showEdit = false});
  final ApiProviderService selectedProvider;
  final AppNetworkImpl network;
  final bool showEdit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageTitleSubtitle(
            title: "what_is_service_provider".tr,
            body: Text("what_is_api_provider".tr)),
        Text("choose_provider".tr, style: context.textTheme.titleMedium),
        Text("select_provider_desc".tr),
        WidgetConstant.height8,
        ListView.builder(
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final len = network.coinParam.providers.length;
            final lastIndex = index + 1 == len;
            final bool isSelected =
                selectedProvider == network.coinParam.providers[index];
            return Column(
              children: [
                InkWell(
                  borderRadius: WidgetConstant.border8,
                  onTap: isSelected
                      ? null
                      : () {
                          context.pop(network.coinParam.providers[index]);
                        },
                  child: Padding(
                    padding: WidgetConstant.padding5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    network
                                        .coinParam.providers[index].serviceName,
                                    style: context.textTheme.labelLarge),
                                Text(network
                                    .coinParam.providers[index].websiteUri)
                              ],
                            )),
                            WidgetConstant.width8,
                            if (isSelected) const Icon(Icons.check_circle),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (!lastIndex) const Divider()
              ],
            );
          },
          itemCount: network.coinParam.providers.length,
        ),
      ],
    );
  }
}
