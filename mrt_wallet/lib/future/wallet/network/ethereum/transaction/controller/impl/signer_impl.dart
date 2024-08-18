import 'package:blockchain_utils/signer/eth/eth_signature.dart';
import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:mrt_wallet/future/wallet/network/ethereum/transaction/controller/impl/transaction_impl.dart';
import 'package:mrt_wallet/wallet/models/signing/signing.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'package:mrt_wallet/crypto/requets/messages/models/models/signing.dart';
import 'package:on_chain/on_chain.dart';

mixin ETHSignerImpl on EthTransactionImpl {
  void stopGasEstimate();

  Future<String> signTransaction(ETHTransaction transaction) async {
    final nonce = await apiProvider.getAccountNonce(address.networkAddress);
    final tr = transaction.copyWith(nonce: nonce);
    final WalletSigningRequest<ETHSignature> request =
        WalletSigningRequest<ETHSignature>(
      addresses: [address],
      network: network,
      sign: (generateSignature) async {
        final signRequest = GlobalSignRequest.eth(
            digest: tr.serialized,
            index: address.keyIndex as Bip32AddressIndex);
        final sss = await generateSignature(signRequest);
        return ETHSignature.fromBytes(sss.signature);
      },
    );
    final signature =
        await walletProvider.wallet.signTransaction(request: request);
    return BytesUtils.toHexString(tr.signedSerialized(signature.result),
        prefix: "0x");
  }

  Future<String> signAndBroadCastTransaction(ETHTransaction transaction) async {
    final signedTransaction = await signTransaction(transaction);
    return await apiProvider.sendRawTransaction(signedTransaction);
  }
}
