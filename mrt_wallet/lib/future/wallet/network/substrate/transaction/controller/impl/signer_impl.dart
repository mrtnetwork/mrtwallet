import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/network/forms/substrate/core/substrate.dart';
import 'package:mrt_wallet/wallet/models/chain/address/networks/substrate/substrate.dart';
import 'package:mrt_wallet/wallet/models/network/core/network/network.dart';
import 'package:mrt_wallet/wallet/models/networks/substrate/models/metadata_fields.dart';
import 'package:mrt_wallet/wallet/models/signing/signing.dart';
import 'package:mrt_wallet/crypto/requets/messages/models/models/signing.dart';

mixin SubstrateSignerImpl {
  WalletProvider get walletProvider;
  Future<ExtrinsicInfo> buildAndSignTransaction(
      {ONSUBSTRATEREQUESTSIGNATURE? onGenerateSignature,
      required ISubstrateAddress address,
      List<String> memos = const []});

  Future<List<int>> _signTransaction({
    required ISubstrateAddress address,
    required WalletSubstrateNetwork network,
    required List<int> digest,
  }) async {
    final sig = await walletProvider.wallet.signTransaction(
        request: WalletSigningRequest<List<int>>(
      addresses: [address],
      network: network,
      sign: (generateSignature) async {
        final signature = await generateSignature(GlobalSignRequest.substrate(
            digest: digest, index: address.keyIndex));
        return signature.signature;
      },
    ));
    return sig.result;
  }

  Future<ExtrinsicInfo> signTransaction({
    required ISubstrateAddress address,
    required WalletSubstrateNetwork network,
  }) async {
    return await buildAndSignTransaction(
        onGenerateSignature: (digest) async {
          return await _signTransaction(
              address: address, network: network, digest: digest);
        },
        address: address);
  }
}
