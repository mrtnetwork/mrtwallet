import 'package:blockchain_utils/bip/address/ada/ada_addres_type.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/widgets/progress_bar/widgets/progress.dart';
import 'package:mrt_wallet/wallet/models/signing/signing.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'package:mrt_wallet/crypto/requets/messages/models/models/signing.dart';
import 'package:on_chain/ada/ada.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

import 'transaction.dart';

mixin CardanoSignerImpl on CardanoTransactionImpl {
  Future<ADATransaction> _signTransaction() async {
    try {
      final builder = buildTransaction(transactionFee.balance);
      final signers = getTransactionSignerAccounts();
      final signerKeyIndexes = getTransactionSignersKeysIndex();
      final tr = await walletProvider.wallet.signTransaction(
          request: WalletSigningRequest(
        addresses: signers,
        network: network,
        sign: (generateSignature) {
          return builder.signAndBuildTransactionAsync(
            ({required address, required digest}) async {
              final int addressIndex = signers.indexWhere((element) =>
                  element.networkAddress == address ||
                  element.rewardAddress == address);
              if (addressIndex < 0) {
                throw WalletException("Signer account does not found.");
              }
              final keyIndex = signerKeyIndexes.elementAt(addressIndex);
              final signRequest = GlobalSignRequest.cardano(
                  digest: digest, index: keyIndex as Bip32AddressIndex);
              final sss = await generateSignature(signRequest);
              final pubkey =
                  AdaPublicKey.fromBytes(sss.signerPubKey.keyBytes());
              final ed25519Signature = Ed25519Signature(sss.signature);
              if (address.addressType == ADAAddressType.byron) {
                return BootstrapWitness(
                    vkey: Vkey(pubkey.toBytes(false)),
                    signature: ed25519Signature,
                    chainCode: sss.signerPubKey.chainCodeBytes()!,
                    attributes:
                        (address as ADAByronAddress).attributeSerialize());
              }
              return Vkeywitness(
                  vKey: pubkey.toVerificationKey(),
                  signature: ed25519Signature);
            },
          );
        },
      ));
      if (tr.hasError) {
        throw tr.exception!;
      }
      return tr.result;
    } catch (e) {
      rethrow;
    }
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
            txId: [result.result.toString()],
          ),
          backToIdle: false);
    }
  }
}
