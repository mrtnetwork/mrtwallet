import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/account/address/core/address.dart';
import 'package:mrt_wallet/wroker/derivation/derivation.dart';
import 'package:mrt_wallet/wallet/models/balance/balance.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:mrt_wallet/wallet/models/nfts/core/core.dart';
import 'package:mrt_wallet/wallet/models/account/address/balance/balance.dart';
import 'package:mrt_wallet/wallet/models/account/address/new/new_address.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/wallet/models/token/token.dart';

class ICosmosAddress extends CryptoAddress<BigInt, CosmosBaseAddress>
    with Equatable {
  ICosmosAddress._(
      {required this.keyIndex,
      required this.coin,
      required List<int> publicKey,
      required this.address,
      required this.network,
      required this.networkAddress,
      required List<TokenCore<BigInt>> tokens,
      required List<NFTCore> nfts,
      String? accountName,
      required this.hrp})
      : publicKey = List.unmodifiable(publicKey),
        _tokens = List.unmodifiable(tokens),
        _nfts = List.unmodifiable(nfts),
        _accountName = accountName;

  factory ICosmosAddress.newAccount(
      {required CosmosNewAddressParams accountParams,
      required List<int> publicKey,
      required WalletCosmosNetwork network}) {
    final cosmosAddr = accountParams.toAddress(
        publicKey: publicKey, hrp: network.coinParam.hrp);
    final addressDetauls = IntegerAddressBalance(
        address: cosmosAddr.address,
        balance: IntegerBalance.zero(network.coinParam.decimal));
    return ICosmosAddress._(
        coin: accountParams.coin,
        publicKey: publicKey,
        address: addressDetauls,
        keyIndex: accountParams.deriveIndex,
        networkAddress: cosmosAddr,
        network: network.value,
        tokens: const [],
        nfts: const [],
        hrp: network.coinParam.hrp);
  }
  factory ICosmosAddress.fromCbsorHex(String hex, WalletNetwork network) {
    return ICosmosAddress.fromCborBytesOrObject(network,
        bytes: BytesUtils.fromHexString(hex));
  }
  factory ICosmosAddress.fromCborBytesOrObject(WalletNetwork network,
      {List<int>? bytes, CborObject? obj}) {
    final toCborTag = (obj ?? CborObject.fromCbor(bytes!)) as CborTagValue;

    final CborListValue cbor = CborSerializable.decodeCborTags(
        null, toCborTag, CborTagsConst.cosmosAccount);
    final CoinProposal proposal = CoinProposal.fromName(cbor.elementAt(0));
    final CryptoCoins coin = CryptoCoins.getCoin(cbor.elementAt(1), proposal)!;
    final keyIndex =
        AddressDerivationIndex.fromCborBytesOrObject(obj: cbor.getCborTag(2));
    final List<int> publicKey = cbor.elementAt(3);
    final networkId = cbor.elementAt(6);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final IntegerAddressBalance address =
        IntegerAddressBalance.fromCborBytesOrObject(network.coinParam.decimal,
            obj: cbor.getCborTag(4));
    final String hrp = cbor.elementAt(10);
    final CosmosBaseAddress cosmosAddr =
        CosmosBaseAddress(cbor.elementAt(5), forceHrp: hrp);

    final String? accountName = cbor.elementAt(9);

    return ICosmosAddress._(
        coin: coin,
        publicKey: publicKey,
        address: address,
        keyIndex: keyIndex,
        networkAddress: cosmosAddr,
        network: networkId,
        tokens: [],
        nfts: [],
        accountName: accountName,
        hrp: hrp);
  }

  @override
  String accountToString() {
    return address.toAddress;
  }

  @override
  final AddressBalanceCore<BigInt> address;

  @override
  final CryptoCoins coin;

  @override
  final AddressDerivationIndex keyIndex;

  @override
  final int network;

  final List<int> publicKey;

  final String hrp;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          coin.proposal.specName,
          coin.coinName,
          keyIndex.toCbor(),
          publicKey,
          address.toCbor(),
          networkAddress.address,
          network,
          CborListValue.fixedLength(_tokens.map((e) => e.toCbor()).toList()),
          CborListValue.fixedLength(_nfts.map((e) => e.toCbor()).toList()),
          accountName ?? const CborNullValue(),
          CborStringValue(hrp)
        ]),
        CborTagsConst.cosmosAccount);
  }

  @override
  List get variabels {
    return [keyIndex, network];
  }

  @override
  final CosmosBaseAddress networkAddress;

  @override
  String? type;

  List<TokenCore<BigInt>> _tokens;
  @override
  List<TokenCore<BigInt>> get tokens => _tokens;

  List<NFTCore> _nfts;
  @override
  List<NFTCore> get nfts => _nfts;

  @override
  void addToken(TokenCore<BigInt> newToken) {}

  @override
  void removeToken(TokenCore<BigInt> token) {
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
  void updateToken(TokenCore<BigInt> token, Token updatedToken) {}
  SignerInfo get signerInfo => SignerInfo(
      publicKey: coin.conf.type == EllipticCurveTypes.nist256p1
          ? CosmosSecp256R1PublicKey.fromBytes(publicKey)
          : CosmosSecp256K1PublicKey.fromBytes(publicKey),
      modeInfo: const ModeInfo(ModeInfoSignle(SignMode.signModeDirect)),
      sequence: BigInt.zero);

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
  String get orginalAddress => networkAddress.address;

  @override
  bool isEqual(CryptoAddress<BigInt, CosmosBaseAddress> other) {
    if (other is! ICosmosAddress) return false;
    return other.networkAddress.address == networkAddress.address &&
        hrp == other.hrp;
  }

  @override
  CosmosNewAddressParams toAccountParams() {
    return CosmosNewAddressParams(deriveIndex: keyIndex, coin: coin);
  }
}
