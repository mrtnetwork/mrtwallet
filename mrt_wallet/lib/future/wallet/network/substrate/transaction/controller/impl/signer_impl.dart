import 'package:blockchain_utils/crypto/crypto/schnorrkel/keys/keys.dart';
import 'package:mrt_wallet/future/state_managment/extension/app_extensions/string.dart';
import 'package:mrt_wallet/app/utils/method/utiils.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/models/signing/signing.dart';
import 'package:mrt_wallet/crypto/requets/messages/models/models/signing.dart';
import 'package:mrt_wallet/crypto/utils/substrate/substrate.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

import 'transaction.dart';

mixin SubstrateSignerImpl on SubstrateTransactiomImpl {
  Future<Extrinsic> buildEstimateTransaction() async {
    return _buildAndSignTransaction(fakeSignature: true);
  }

  Future<Extrinsic> _buildAndSignTransaction(
      {bool fakeSignature = false}) async {
    final transaction = await buildTransaction();
    final digest = transaction.serialzeSign();
    final SubstrateMultiSignature signature;
    final algorithm = address.keyIndex.currencyCoin.conf.type;
    if (fakeSignature) {
      signature = SubstrateMultiSignature(SubstrateSr25519Signature(
          List<int>.filled(SchnorrkelKeyCost.signatureLength, 0)));
    } else {
      final sig = await walletProvider.wallet.signTransaction(
          request: WalletSigningRequest<SubstrateMultiSignature>(
        addresses: [address],
        network: network,
        sign: (generateSignature) async {
          final signature = await generateSignature(GlobalSignRequest.substrate(
              digest: digest, index: address.keyIndex));
          return SubstrateUtils.buildMultiSignature(
              algorithm: algorithm, signature: signature.signature);
        },
      ));
      signature = sig.result;
    }
    final extrinsic = transaction.toExtrinsic(
        signature: signature, signer: address.networkAddress);
    return extrinsic;
  }

  Future<void> signAndSendTransaction() async {
    progressKey.progressText(
        "create_send_transaction".tr.replaceOne(network.coinParam.token.name));
    final result = await MethodUtils.call(() async {
      final extrinsic = await _buildAndSignTransaction();
      return await apiProvider.broadcastTransaction(extrinsic);
    });
    if (result.hasError) {
      progressKey.errorText(result.error!.tr,
          showBackButton: true, backToIdle: false);
    } else {
      progressKey.success(
          progressWidget: SuccessTransactionTextView(
              network: network, txId: [result.result]),
          backToIdle: false);
    }
  }
}
