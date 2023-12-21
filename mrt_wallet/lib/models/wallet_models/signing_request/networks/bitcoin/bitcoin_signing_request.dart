import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:mrt_wallet/models/wallet_models/address/address.dart';
import 'package:mrt_wallet/models/wallet_models/network/network_models.dart';
import 'package:mrt_wallet/models/wallet_models/signing_request/core/signing_request.dart';

class BitcoinSigningRequest implements SigningRequest {
  BitcoinSigningRequest({
    required this.addresses,
    required this.network,
    required this.transaction,
  });
  @override
  final List<CryptoAccountAddress> addresses;

  @override
  final AppNetworkImpl network;
  final BitcoinTransactionBuilder transaction;

  @override
  List<AddressDerivationIndex> get signers {
    List<AddressDerivationIndex> keyIndexes = [];
    for (final i in addresses) {
      if (i.multiSigAccount) {
        i as IBitcoinMultiSigAddress;
        final multiSigKeyIndexes =
            i.multiSignatureAddress.signers.map((e) => e.keyIndex).toList();
        keyIndexes.addAll(multiSigKeyIndexes);
      } else {
        keyIndexes.add(i.keyIndex);
      }
    }
    return keyIndexes;
  }
}
