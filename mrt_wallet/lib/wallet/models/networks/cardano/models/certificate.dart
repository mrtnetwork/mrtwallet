import 'package:mrt_wallet/wallet/models/others/models/receipt_address.dart';
import 'package:on_chain/on_chain.dart';

enum ADATransactionCertificateType {
  deregistration("stake_deregistration"),
  registraction("stake_registration"),
  delegation("stake_delegation");

  final String viewName;
  const ADATransactionCertificateType(this.viewName);
}

class ADATransactionCertificate {
  final ADACertificateBuilder certificate;
  final ADATransactionCertificateType type;
  final ReceiptAddress<ADAAddress> rewardAccount;
  const ADATransactionCertificate(
      {required this.certificate,
      required this.type,
      required this.rewardAccount});
}
