import 'lock_time.dart';

class WalletUpdateInfosData {
  final String name;
  final WalletLockTime lockTime;
  final bool requirmentPassword;
  final bool asDefaultWallet;
  final bool protectWallet;
  const WalletUpdateInfosData(
      {required this.name,
      required this.lockTime,
      required this.requirmentPassword,
      required this.asDefaultWallet,
      required this.protectWallet});
}
