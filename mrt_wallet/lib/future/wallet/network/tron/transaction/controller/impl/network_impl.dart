import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/network/tron/transaction/controller/impl/transaction.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:on_chain/on_chain.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

mixin TronNetworkConditionImpl on TronTransactionImpl {
  late TronChainParameters _chainParameters;
  @override
  TronChainParameters get tronChainParameters => _chainParameters;
  TransactionContractType get type;
  Future<bool> initNetworkCondition() async {
    final result = await MethodUtils.call(() async {
      if (address.accountInfo == null) {
        return null;
      }
      await apiProvider.updateAccountResource(address);
      final chaiParams = await apiProvider.getChainParameters();
      return chaiParams;
    });
    if (result.hasError) {
      progressKey.errorText(result.error!.tr, backToIdle: false);
    } else if (result.result == null) {
      progressKey.errorText("account_not_found".tr, backToIdle: false);
    } else {
      _chainParameters = result.result!;
      final permission = checkPermission(address: address, type: type);
      if (!permission) {
        if (!address.multiSigAccount) {
          progressKey.errorText("multi_sig_account_does_not_supported".tr,
              backToIdle: false);
        } else {
          progressKey.errorText("tron_account_permission_not_access_desc".tr,
              backToIdle: false);
        }
        return false;
      }
      final initFields = await MethodUtils.call(() async {
        return await field.init(
            provider: apiProvider, address: address, account: account);
      });
      if (initFields.hasError) {
        progressKey.errorText(initFields.error!);
      } else {
        progressKey.success();
        return true;
      }
    }
    return false;
  }

  static bool checkPermission(
      {required ITronAddress address, required TransactionContractType type}) {
    final account = address.accountInfo!;
    final List<AccountPermission> permissions = [
      account.ownerPermission,
      ...account.activePermissions
    ];
    if (address.multiSigAccount) {
      final msigAccount = address as ITronMultisigAddress;
      final int? permissionId = msigAccount.multiSignatureAccount.permissionID;
      BigInt sumOfThereshHold = BigInt.zero;
      final List<PermissionKeys> signers =
          msigAccount.multiSignatureAccount.signers
              .map((e) => PermissionKeys(
                  address: TronAddress.fromPublicKey(
                    BytesUtils.fromHexString(e.publicKey),
                  ),
                  weight: e.weight))
              .toList();
      final findPermission = MethodUtils.nullOnException(() =>
          permissions.firstWhere((element) => element.id == permissionId));
      if (findPermission == null) return false;

      for (final i in findPermission.keys) {
        final findSigner = MethodUtils.nullOnException(() => signers.firstWhere(
            (element) => element.address.toAddress() == i.address.toAddress()));
        if (findSigner == null) continue;
        sumOfThereshHold = sumOfThereshHold + findSigner.weight;
      }
      if (sumOfThereshHold >= findPermission.threshold) {
        if (findPermission.operations == null) {
          return true;
        }
        final operations =
            TronHelper.decodePermissionOperation(findPermission.operations!);
        if (operations.contains(type)) {
          return true;
        }
        return false;
      }
      return false;
    }
    final accountAccess = permissions.where((element) => element.keys
        .map((e) => e.address.toAddress())
        .contains(account.address));
    for (final i in accountAccess) {
      final accKey = MethodUtils.nullOnException(() => i.keys.firstWhere(
          (element) => element.address.toAddress() == account.address));
      if (accKey == null) return false;
      if (accKey.weight == i.threshold) {
        if (i.type == PermissionType.owner) {
          return true;
        }
        final operations = TronHelper.decodePermissionOperation(i.operations!);
        if (operations.contains(type)) {
          return true;
        }
      }
    }
    return false;
  }
}
