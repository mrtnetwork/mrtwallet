import 'package:flutter/widgets.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/global/pages/update_wallet_infos.dart';
import 'package:mrt_wallet/future/wallet/setup/controller/controller.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/models/setting/setting.dart';
import 'package:mrt_wallet/wallet/provider/wallet_provider.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';

class CreateWalletSettingsView extends StatefulWidget {
  const CreateWalletSettingsView(this.wallet, {Key? key}) : super(key: key);
  final HDWallet wallet;

  @override
  State<CreateWalletSettingsView> createState() =>
      _CreateWalletSettingsViewState();
}

class _CreateWalletSettingsViewState extends State<CreateWalletSettingsView>
    with SafeState {
  final GlobalKey<PageProgressState> progressKey = GlobalKey();
  late String name = widget.wallet.name;
  late bool reqPassword = widget.wallet.requiredPassword;
  late bool protectWallet = widget.wallet.protectWallet;
  late bool defaultWallet = true;
  late WalletLockTime locktime = widget.wallet.locktime;
  late List<String> walletIds;

  void setup(WalletUpdateInfosData walletInfos) async {
    name = walletInfos.name;
    locktime = walletInfos.lockTime;
    reqPassword = walletInfos.requirmentPassword;
    defaultWallet = walletInfos.asDefaultWallet;
    protectWallet = walletInfos.protectWallet;

    progressKey.progressText("launch_the_wallet".tr);
    final result = await MethodUtils.call(
      () async {
        final model = context.watch<SetupWalletController>(StateConst.setup);
        await model.setupHDWallet(walletInfos);
      },
    );
    if (result.hasError) {
      progressKey.errorText(result.error!.tr);
    } else {
      progressKey.success(backToIdle: false);
    }
  }

  void onChangeLockTime(WalletLockTime? time) {
    if (time == null || !reqPassword) return;
    locktime = time;
  }

  void _init() {
    final walletProvider = context.watch<WalletProvider>(StateConst.main);
    walletIds = walletProvider.wallet.wallets.map((e) => e.name).toList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return PageProgress(
      key: progressKey,
      backToIdle: APPConst.oneSecoundDuration,
      child: (c) => UpdateWalletInfosWidget(
        name: name,
        locktime: locktime,
        requrmentPassword: reqPassword,
        exitsIds: walletIds,
        asDefaultWallet: defaultWallet,
        onUpdate: (update) => setup(update),
        protectWallet: protectWallet,
      ),
    );
  }
}
