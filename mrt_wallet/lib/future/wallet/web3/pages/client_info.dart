import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/global/app.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';

class Web3ClientInfoView extends StatelessWidget {
  const Web3ClientInfoView({required this.permission, this.info, Key? key})
      : super(key: key);
  final Web3APPAuthentication permission;
  final Web3RequestApplicationInformation? info;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("client".tr, style: context.textTheme.titleMedium),
        Text("web3_client_desc".tr),
        WidgetConstant.height8,
        ContainerWithBorder(
          child: Row(
            children: [
              CircleAPPImageView(
                info?.info.image ?? permission.icon,
                radius: 35,
                onError: (c) =>
                    const Icon(Icons.broken_image, size: APPConst.double40),
              ),
              WidgetConstant.width8,
              Flexible(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(permission.applicationId,
                      style: context.textTheme.labelLarge),
                  OneLineTextWidget(
                    info?.info.name ?? permission.name,
                    style: context.textTheme.bodySmall,
                  ),
                ],
              )),
            ],
          ),
        ),
      ],
    );
  }
}
