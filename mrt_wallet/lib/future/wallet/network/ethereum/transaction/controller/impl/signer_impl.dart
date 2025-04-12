import 'package:blockchain_utils/signer/types/eth_signature.dart';
import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/crypto/requets/messages/models/models/signing.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:on_chain/on_chain.dart';

mixin ETHSignerImpl {
  WalletProvider get walletProvider;
  WalletEthereumNetwork get network;
  EthereumClient get apiProvider;
  IEthAddress get address;
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
            digest: tr.serialized, index: address.keyIndex.cast());
        final ethSignature = await generateSignature(signRequest);
        return ETHSignature.fromBytes(ethSignature.signature);
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
