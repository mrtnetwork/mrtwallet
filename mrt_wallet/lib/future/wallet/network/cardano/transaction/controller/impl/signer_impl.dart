import 'package:blockchain_utils/helper/extensions/extensions.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/widgets/progress_bar/widgets/progress.dart';
import 'package:mrt_wallet/wallet/models/signing/signing.dart';
import 'package:mrt_wallet/crypto/requets/messages/models/models/signing.dart';
import 'package:on_chain/ada/ada.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

import 'transaction.dart';

mixin CardanoSignerImpl on CardanoTransactionImpl {
  Future<ADATransaction> _signTransaction() async {
    final builder = buildTransaction(transactionFee.balance);
    final signersAddresses = builder.signers.immutable;
    final signers = List.generate(signersAddresses.length, (i) {
      final signer = signersAddresses[i];
      return addresses.firstWhere((e) {
        return e.networkAddress == signer || e.rewardAddress == signer;
      }, orElse: () => throw WalletExceptionConst.signerAccountNotFound);
    });
    final signerKeyIndexes = List.generate(signersAddresses.length, (i) {
      final address = signers[i];
      final signeraddress = signersAddresses[i];
      if (signeraddress.isRewardAddress) {
        if (!address.isRewardAddress && address.rewardKeyIndex == null) {
          throw WalletExceptionConst.signerAccountNotFound;
        }
        return address.rewardKeyIndex ?? address.keyIndex;
      }
      return address.keyIndex;
    });
    final tr = await walletProvider.wallet.signTransaction(
        request: WalletSigningRequest(
      addresses: signers,
      network: network,
      sign: (generateSignature) {
        int index = 0;
        return builder.signAndBuildTransactionAsync(
          ({required address, required digest}) async {
            final int addressIndex = index++;
            final keyIndex = signerKeyIndexes.elementAt(addressIndex);
            final signRequest = GlobalSignRequest.cardano(
                digest: digest, index: keyIndex.cast());
            final sig = await generateSignature(signRequest);
            final pubkey = AdaPublicKey.fromBytes(sig.signerPubKey.keyBytes());
            final ed25519Signature = Ed25519Signature(sig.signature);
            if (address.isByron) {
              return BootstrapWitness(
                  vkey: Vkey(pubkey.toBytes(false)),
                  signature: ed25519Signature,
                  chainCode: sig.signerPubKey.chainCodeBytes()!,
                  attributes:
                      address.cast<ADAByronAddress>().attributeSerialize());
            }
            return Vkeywitness(
                vKey: pubkey.toVerificationKey(), signature: ed25519Signature);
          },
        );
      },
    ));
    return tr.result;
  }

  void buildAndBroadcastTransaction() async {
    progressKey.progressText(
        "create_send_transaction".tr.replaceOne(network.coinParam.token.name));
    final result = await MethodUtils.call(() async {
      final result = await _signTransaction();
      final ser = result.serialize();
      final broadcast = await providers.broadcastTransaction(ser);
      return broadcast;
    });

    if (result.hasError) {
      progressKey.errorText(result.error!.tr,
          backToIdle: false, showBackButton: true);
    } else {
      progressKey.success(
          progressWidget: SuccessTransactionTextView(
            network: network,
            txIds: [result.result.toString()],
          ),
          backToIdle: false);
    }
  }
}
