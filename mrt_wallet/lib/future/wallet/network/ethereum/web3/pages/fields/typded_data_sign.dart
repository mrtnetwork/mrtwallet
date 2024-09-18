import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/wallet/models/networks/ethereum/models/eip712_domain.dart';
import 'package:mrt_wallet/wallet/web3/networks/ethereum/params/models/sign_typed_data.dart';
import 'package:on_chain/solidity/solidity.dart';

class EthereumWeb3TypedDataSignRequestView extends StatelessWidget {
  const EthereumWeb3TypedDataSignRequestView({required this.request, Key? key})
      : super(key: key);
  final EthereumWeb3Form<Web3EthreumTypdedData> request;
  Web3EthreumTypdedData get param => request.request.params;
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("version".tr, style: context.textTheme.titleMedium),
          WidgetConstant.height8,
          ContainerWithBorder(
            child: Text(param.typedData.version.name.toString(),
                style: context.colors.onPrimaryContainer.bodyMedium(context)),
          ),
          _EIP712FieldsView(
            typedData: param.typedData,
            domain: param.domain,
          ),
          WidgetConstant.height20,
          ContainerWithBorder(
            onTapWhenOnRemove: false,
            padding: EdgeInsets.zero,
            child: Theme(
                data: context.theme
                    .copyWith(dividerColor: context.colors.transparent),
                child: ExpansionTile(
                  title:
                      Text("message".tr, style: context.textTheme.titleMedium),
                  subtitle: TextAndLinkView(
                      text: "eth_sign_typed_data_desc"
                          .tr
                          .replaceOne(param.method.name),
                      url: LinkConst.aboutEthereumTypedData,
                      linkDesc: "read_more".tr),
                  children: List.generate(param.typedDataJson.length, (index) {
                    final key = param.typedDataJson.keys.elementAt(index);
                    final value = param.typedDataJson[key];
                    if (value == null) return WidgetConstant.sizedBox;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ContainerWithBorder(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                key.camelCase,
                                style: context.colors.onPrimaryContainer
                                    .lableLarge(context),
                              ),
                              ContainerWithBorder(
                                backgroundColor:
                                    context.colors.onPrimaryContainer,
                                constraints: null,
                                child: CopyTextIcon(
                                  dataToCopy: value.toString(),
                                  isSensitive: false,
                                  color: context.colors.primaryContainer,
                                  widget: SelectableText(
                                    value.toString(),
                                    style: context.colors.primaryContainer
                                        .bodyMedium(context),
                                    maxLines: 4,
                                    minLines: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                )),
          ),
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

class _EIP712FieldsView extends StatelessWidget {
  const _EIP712FieldsView(
      {required this.typedData, required this.domain, Key? key})
      : super(key: key);
  final EIP712Base typedData;
  final EIP712Domain? domain;
  @override
  Widget build(BuildContext context) {
    if (typedData.version.version > 1) {
      final Eip712TypedData eip712 = typedData as Eip712TypedData;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WidgetConstant.height20,
          Text("primary_type".tr, style: context.textTheme.titleMedium),
          WidgetConstant.height8,
          ContainerWithBorder(
            onRemove: () {},
            onRemoveWidget: CopyTextIcon(
                dataToCopy: eip712.primaryType, isSensitive: false),
            onTapWhenOnRemove: false,
            child: Text(
              eip712.primaryType,
              style: context.colors.onPrimaryContainer.bodyMedium(context),
            ),
          ),
          _EIP712DomainView(domain)
        ],
      );
    }
    return WidgetConstant.sizedBox;
  }
}

class _EIP712DomainView extends StatelessWidget {
  const _EIP712DomainView(this.domain);
  final EIP712Domain? domain;
  @override
  Widget build(BuildContext context) {
    if (domain == null) return WidgetConstant.sizedBox;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WidgetConstant.height20,
        Text("domain".tr, style: context.textTheme.titleMedium),
        WidgetConstant.height8,
        ContainerWithBorder(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("name".tr,
                style: context.colors.onPrimaryContainer.lableLarge(context)),
            ContainerWithBorder(
                backgroundColor: context.colors.onPrimaryContainer,
                child: Text(domain!.name,
                    style:
                        context.colors.primaryContainer.bodyMedium(context))),
            WidgetConstant.height8,
            Text("version".tr,
                style: context.colors.onPrimaryContainer.lableLarge(context)),
            ContainerWithBorder(
                backgroundColor: context.colors.onPrimaryContainer,
                child: Text(domain!.version,
                    style:
                        context.colors.primaryContainer.bodyMedium(context))),
            WidgetConstant.height8,
            Text("verifying_contract".tr,
                style: context.colors.onPrimaryContainer.lableLarge(context)),
            ContainerWithBorder(
                backgroundColor: context.colors.onPrimaryContainer,
                onRemove: () {},
                onRemoveWidget: CopyTextIcon(
                    dataToCopy: domain!.verifyingContract.address,
                    isSensitive: false,
                    color: context.colors.primaryContainer),
                child: Text(domain!.verifyingContract.address,
                    style:
                        context.colors.primaryContainer.bodyMedium(context))),
          ],
        )),
        WidgetConstant.height20,
      ],
    );
  }
}
