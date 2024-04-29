import 'package:mrt_wallet/future/pages/wallet_pages/network/cardano_pages/transaction/controller/impl/transaction.dart';
import 'package:mrt_wallet/models/wallet_models/network/custom/cardano/cardano.dart';

mixin CardanoCertificateImpl on CardanoTransactionImpl {
  List<ADATransactionCertificate> _certificates = [];
  @override
  List<ADATransactionCertificate> get certificates => _certificates;
  void addCertificate(ADATransactionCertificate? newCertificate) {
    if (newCertificate == null) return;
    _certificates = [newCertificate, ...certificates];
    notify();
    calculateFee();
  }

  void removeCertificate(ADATransactionCertificate? certificate) {
    if (!_certificates.contains(certificate)) return;
    _certificates = List<ADATransactionCertificate>.unmodifiable(
        _certificates.where((element) => element != certificate));
    notify();
    calculateFee();
  }
}
