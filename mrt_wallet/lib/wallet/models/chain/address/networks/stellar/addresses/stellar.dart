import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/chain/address/core/address.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'package:mrt_wallet/wallet/models/chain/address/creation_params/new_address.dart';
import 'package:mrt_wallet/wallet/models/balance/balance.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:mrt_wallet/wallet/models/nfts/core/core.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:stellar_dart/stellar_dart.dart';
import 'package:mrt_wallet/wallet/models/token/token.dart';
import 'multisig.dart';

enum StellarAddressType {
  muxedAddress("muxed_address"),
  pubkey("pubkey_address");

  final String value;
  const StellarAddressType(this.value);
}

class IStellarAddress
    extends ChainAccount<StellarAddress, StellarIssueToken, NFTCore>
    with Equatable {
  IStellarAddress._(
      {required this.keyIndex,
      required this.coin,
      required List<int> publicKey,
      required this.address,
      required this.network,
      required this.networkAddress,
      required this.id,
      required List<StellarIssueToken> tokens,
      required List<NFTCore> nfts,
      String? accountName})
      : publicKey = publicKey.asImmutableBytes,
        _tokens = tokens.immutable,
        _nfts = nfts.immutable,
        _accountName = accountName,
        addressType = id == null
            ? StellarAddressType.pubkey
            : StellarAddressType.muxedAddress;

  factory IStellarAddress.newAccount(
      {required StellarNewAddressParams accountParams,
      required List<int> publicKey,
      required WalletStellarNetwork network}) {
    StellarAddress stellarAddress;
    if (accountParams.id != null) {
      stellarAddress = StellarMuxedAddress.fromPublicKey(
          publicKey: publicKey, accountId: accountParams.id!);
    } else {
      stellarAddress = StellarAccountAddress.fromPublicKey(publicKey);
    }

    final addressDetails = AccountBalance(
        address: stellarAddress.toString(),
        balance: IntegerBalance.zero(network.coinParam.decimal));
    return IStellarAddress._(
      coin: accountParams.coin,
      publicKey: publicKey,
      address: addressDetails,
      keyIndex: accountParams.deriveIndex,
      networkAddress: stellarAddress,
      network: network.value,
      id: accountParams.id,
      tokens: const [],
      nfts: const [],
    );
  }
  factory IStellarAddress.fromCbsorHex(WalletNetwork network, String hex) {
    return IStellarAddress.fromCborBytesOrObject(network,
        bytes: BytesUtils.fromHexString(hex));
  }
  factory IStellarAddress.fromCborBytesOrObject(WalletNetwork network,
      {List<int>? bytes, CborObject? obj}) {
    final toCborTag = (obj ?? CborObject.fromCbor(bytes!)) as CborTagValue;
    if (BytesUtils.bytesEqual(
        toCborTag.tags, CborTagsConst.stellarMultisigAccount)) {
      return IStellarMultisigAddress.fromCborBytesOrObject(network,
          obj: toCborTag);
    }

    final CborListValue cbor = CborSerializable.decodeCborTags(
        null, toCborTag, CborTagsConst.stellarAccount);
    final CoinProposal proposal = CoinProposal.fromName(cbor.elementAt(0));
    final CryptoCoins coin = CryptoCoins.getCoin(cbor.elementAt(1), proposal)!;
    final keyIndex =
        AddressDerivationIndex.fromCborBytesOrObject(obj: cbor.getCborTag(2));
    final List<int> publicKey = cbor.elementAt(3);
    final networkId = cbor.elementAt(7);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final AccountBalance address = AccountBalance.fromCborBytesOrObject(
        network.coinParam.decimal,
        obj: cbor.getCborTag(4));
    final StellarAddress rippleAddress =
        StellarAddress.fromBase32Addr(cbor.elementAt(5));
    final BigInt? id = cbor.elementAt(6);
    final List<StellarIssueToken> tokens = (cbor.elementAt<List<dynamic>>(8))
        .map((e) => StellarIssueToken.fromCborBytesOrObject(obj: e))
        .toList();
    final String? accountName = cbor.elementAt(10);
    return IStellarAddress._(
        coin: coin,
        publicKey: publicKey,
        address: address,
        keyIndex: keyIndex,
        networkAddress: rippleAddress,
        network: networkId,
        id: id,
        tokens: tokens,
        nfts: [],
        accountName: accountName);
  }

  @override
  String accountToString() {
    return address.toAddress;
  }

  @override
  final AccountBalance address;

  @override
  final CryptoCoins coin;

  @override
  final AddressDerivationIndex keyIndex;

  @override
  final int network;

  final List<int> publicKey;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          coin.proposal.specName,
          coin.coinName,
          keyIndex.toCbor(),
          publicKey,
          address.toCbor(),
          networkAddress.toString(),
          id,
          network,
          CborListValue.fixedLength(_tokens.map((e) => e.toCbor()).toList()),
          CborListValue.fixedLength(_nfts.map((e) => e.toCbor()).toList()),
          accountName ?? const CborNullValue()
        ]),
        CborTagsConst.stellarAccount);
  }

  @override
  List get variabels {
    return [id, keyIndex, network];
  }

  @override
  final StellarAddress networkAddress;
  final StellarAddressType addressType;
  final BigInt? id;

  @override
  String get type => addressType.value;

  List<StellarIssueToken> _tokens;
  @override
  List<StellarIssueToken> get tokens => _tokens;

  List<NFTCore> _nfts;
  @override
  List<NFTCore> get nfts => _nfts;

  @override
  void addToken(StellarIssueToken newToken) {
    if (_tokens.contains(newToken)) {
      throw WalletExceptionConst.tokenAlreadyExist;
    }
    _tokens = List.unmodifiable([newToken, ..._tokens]);
  }

  @override
  void updateToken(StellarIssueToken token, Token updatedToken) {
    if (!tokens.contains(token)) return;
    List<StellarIssueToken> existTokens = List<StellarIssueToken>.from(_tokens);
    existTokens.removeWhere((element) => element == token);
    existTokens = [token.updateToken(updatedToken), ...existTokens];
    _tokens = List.unmodifiable(existTokens);
  }

  @override
  void removeToken(StellarIssueToken token) {
    if (!tokens.contains(token)) return;
    final existTokens = List.from(_tokens);
    existTokens.removeWhere((element) => element == token);
    _tokens = List.unmodifiable(existTokens);
  }

  @override
  void addNFT(NFTCore newNft) {}

  @override
  void removeNFT(NFTCore nft) {}

  @override
  bool get multiSigAccount => false;

  String? _accountName;
  @override
  String? get accountName => _accountName;

  @override
  void setAccountName(String? name) {
    _accountName = name;
  }

  @override
  String get orginalAddress => networkAddress.baseAddress;

  @override
  bool isEqual(ChainAccount other) {
    if (other is! IStellarAddress) return false;
    return networkAddress == other.networkAddress &&
        multiSigAccount == other.multiSigAccount;
  }

  @override
  StellarNewAddressParams toAccountParams() {
    return StellarNewAddressParams(deriveIndex: keyIndex, coin: coin, id: id);
  }
}

class IStellarMultisigAddress extends IStellarAddress
    implements MultiSigCryptoAccountAddress {
  IStellarMultisigAddress._(
      {required super.address,
      required super.network,
      required super.coin,
      required super.networkAddress,
      required super.nfts,
      required super.id,
      required super.tokens,
      required this.multiSignatureAccount,
      String? accountName})
      : super._(
            keyIndex: const MultiSigAddressIndex(),
            publicKey: const [],
            accountName: accountName);
  @override
  StellarMultiSigNewAddressParams toAccountParams() {
    return StellarMultiSigNewAddressParams(
        coin: coin,
        id: id,
        masterAddress: networkAddress.toPublicKey().toAddress(),
        multiSigAccount: multiSignatureAccount);
  }

  factory IStellarMultisigAddress.newAccount(
      {required StellarMultiSigNewAddressParams accountParams,
      required WalletStellarNetwork network}) {
    final addressDetails = AccountBalance(
        address: accountParams.id == null
            ? accountParams.masterAddress.baseAddress
            : accountParams.masterAddress
                .toMuxedAddress(accountParams.id!)
                .muxedAddress,
        balance: IntegerBalance.zero(network.coinParam.decimal));

    return IStellarMultisigAddress._(
        coin: accountParams.coin,
        multiSignatureAccount: accountParams.multiSigAccount,
        address: addressDetails,
        networkAddress: StellarAddress.fromBase32Addr(addressDetails.address),
        network: network.value,
        id: accountParams.id,
        tokens: const [],
        nfts: const []);
  }
  factory IStellarMultisigAddress.fromCborBytesOrObject(WalletNetwork network,
      {List<int>? bytes, CborObject? obj}) {
    final toCborTag = (obj ?? CborObject.fromCbor(bytes!)) as CborTagValue;

    final CborListValue values = CborSerializable.decodeCborTags(
        null, toCborTag, CborTagsConst.stellarMultisigAccount);
    final CoinProposal proposal = CoinProposal.fromName(values.elementAt(0));
    final CryptoCoins coin =
        CryptoCoins.getCoin(values.elementAt(1), proposal)!;

    final int networkId = values.elementAt(7);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final AccountBalance address = AccountBalance.fromCborBytesOrObject(
        network.coinParam.decimal,
        obj: values.getCborTag(4));

    final StellarAddress stellarAddress =
        StellarAddress.fromBase32Addr(values.elementAt(5));
    BigInt? id = values.elementAt(6);

    StellarMultiSignatureAddress multiSigAccount =
        StellarMultiSignatureAddress.fromCborBytesOrObject(
            obj: values.getCborTag(11));
    final String? accountName = values.elementAt(12);
    return IStellarMultisigAddress._(
        coin: coin,
        address: address,
        networkAddress: stellarAddress,
        network: networkId,
        id: id,
        tokens: [],
        multiSignatureAccount: multiSigAccount,
        nfts: [],
        accountName: accountName);
  }

  final StellarMultiSignatureAddress multiSignatureAccount;
  @override
  List<int> get publicKey => throw UnimplementedError();

  @override
  List get variabels {
    return [id, keyIndex, network, multiSignatureAccount];
  }

  @override
  List<Bip32AddressIndex> signerKeyIndexes() {
    return keyDetails.map((e) => e.$2).toList();
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          coin.proposal.specName,
          coin.coinName,
          const CborNullValue(),
          const CborNullValue(),
          address.toCbor(),
          networkAddress.toString(),
          id,
          network,
          CborListValue.fixedLength(_tokens.map((e) => e.toCbor()).toList()),
          CborListValue.fixedLength(_nfts.map((e) => e.toCbor()).toList()),
          const CborNullValue(),
          multiSignatureAccount.toCbor(),
          accountName ?? const CborNullValue()
        ]),
        CborTagsConst.stellarMultisigAccount);
  }

  @override
  bool get multiSigAccount => true;

  @override
  List<(String, Bip32AddressIndex)> get keyDetails =>
      multiSignatureAccount.signers
          .map((e) => (e.publicKey, e.keyIndex))
          .toList();
}
