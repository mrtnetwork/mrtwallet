import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/wallet_models/network/core/network.dart';
import 'package:mrt_wallet/provider/api/core/api_provider.dart';

class SelectProviderView extends StatelessWidget {
  const SelectProviderView(
      {super.key, required this.selectedProvider, required this.network});
  final ApiProviderService selectedProvider;
  final AppNetworkImpl network;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageTitleSubtitle(
            title: "what_is_service_provider".tr,
            body: Text("what_is_api_provider".tr)),
        PageTitleSubtitle(
            title: "choose_provider".tr,
            body: Text("select_provider_desc".tr)),
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
                            if (isSelected) const Icon(Icons.check_circle)
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
          itemCount: AppBitcoinNetwork.values.length,
        ),
      ],
    );
  }
}
