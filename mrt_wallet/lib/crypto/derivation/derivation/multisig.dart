import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/crypto/constant/const.dart';
import 'package:mrt_wallet/crypto/keys/access/private_key_response.dart';
import 'package:mrt_wallet/crypto/keys/models/seed.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';

class MultiSigAddressIndex extends AddressDerivationIndex {
  @override
  final String? hdPath = null;
  final String? keyName;
  const MultiSigAddressIndex({this.keyName});

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([keyName]),
        CryptoKeyConst.multiSigAccountKeyIndex);
  }

  @override
  List get variabels => [];

  @override
  CryptoCoins get currencyCoin =>
      throw WalletExceptionConst.inaccessibleKeyAlgorithm;

  @override
  SeedTypes get seedGeneration => throw WalletExceptionConst.unsuportedFeature;

  @override
  AddressDerivationType get derivationType => AddressDerivationType.multisig;

  @override
  String get name => "multi_signature";

  @override
  String toString() {
    return name;
  }

  @override
  String? get importedKeyId => null;

  @override
  AddressDerivationIndex asImportedKey(String importKeyId) {
    throw WalletExceptionConst.featureUnavailableForMultiSignature;
  }

  @override
  PrivateKeyData derive(PrivateKeyData masterKey,
      {Bip44Levels maxLevel = Bip44Levels.addressIndex}) {
    throw WalletExceptionConst.multiSigDerivationNotSuported;
  }
}
