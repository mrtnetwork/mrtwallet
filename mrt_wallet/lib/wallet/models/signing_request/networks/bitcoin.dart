import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:mrt_wallet/wallet/models/account/address/core/address.dart';
import 'package:mrt_wallet/wallet/models/account/address/derivation/core/derivation.dart';
import 'package:mrt_wallet/wallet/models/account/address/networks/bitcoin/bitcoin.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:mrt_wallet/wallet/models/signing_request/core/signing_request.dart';

class BitcoinSigningRequest extends SigningRequest<BtcTransaction> {
  BitcoinSigningRequest({
    required this.addresses,
    required this.network,
    required this.transaction,
  });
  @override
  final List<CryptoAddress> addresses;

  @override
  final WalletNetwork network;
  final BasedBitcoinTransacationBuilder transaction;

  @override
  List<AddressDerivationIndex> get signers {
    List<AddressDerivationIndex> keyIndexes = [];
    for (final i in addresses) {
      if (i.multiSigAccount) {
        final multiSignatureAddress =
            (i as BitcoinMultiSigBase).multiSignatureAddress;
        final multiSigKeyIndexes =
            multiSignatureAddress.signers.map((e) => e.keyIndex).toList();
        keyIndexes.addAll(multiSigKeyIndexes);
      } else {
        keyIndexes.add(i.keyIndex);
      }
    }
    return keyIndexes;
  }
}
