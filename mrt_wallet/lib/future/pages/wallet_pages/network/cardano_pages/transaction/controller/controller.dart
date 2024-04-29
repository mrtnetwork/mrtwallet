import 'package:mrt_wallet/future/pages/wallet_pages/network/cardano_pages/transaction/controller/impl/certificate_impl.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/cardano_pages/transaction/controller/impl/fee_impl.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/cardano_pages/transaction/controller/impl/memo_impl.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/cardano_pages/transaction/controller/impl/minting_impl.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/cardano_pages/transaction/controller/impl/transaction.dart';
import 'impl/signer_impl.dart';

class CardanoTransactionStateController extends CardanoTransactionImpl
    with
        CardanoTransactionFeeImpl,
        CardanoSignerImpl,
        CardanoTransactionMemoImpl,
        CardanoMintingImpl,
        CardanoCertificateImpl {
  CardanoTransactionStateController(
      {required super.walletProvider, required super.chainAccount});

  @override
  String get repositoryId => "cardano";

  @override
  void buildAndBroadcastTransaction() {
    if (!trReady) return;
    super.buildAndBroadcastTransaction();
  }
}
