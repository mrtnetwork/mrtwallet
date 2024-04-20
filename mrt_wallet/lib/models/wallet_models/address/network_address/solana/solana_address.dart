import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/models/wallet_models/address/address.dart';
import 'package:mrt_wallet/models/wallet_models/currency_balance/balance.dart';
import 'package:mrt_wallet/models/wallet_models/network/network_models.dart';
import 'package:mrt_wallet/models/wallet_models/nfts/core/nft_core.dart';
import 'package:mrt_wallet/models/wallet_models/token/core/core.dart';
import 'package:mrt_wallet/models/wallet_models/token/networks/networks.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';
import 'package:on_chain/solana/solana.dart';

class ISolanaAddress
    with Equatable
    implements Bip32AddressCore<BigInt, SolAddress> {
  ISolanaAddress._(
      {required this.keyIndex,
      required this.coin,
      required List<int> publicKey,
      required this.address,
      required this.network,
      required this.networkAddress,
      required List<SolanaSPLToken> tokens,
      required List<NFTCore> nfts,
      String? accountName})
      : publicKey = List.unmodifiable(publicKey),
        _tokens = List.unmodifiable(tokens),
        _nfts = List.unmodifiable(nfts),
        _accountName = accountName;

  factory ISolanaAddress.newAccount(
      {required SolanaNewAddressParam accountParams,
      required List<int> publicKey,
      required AppNetworkImpl network}) {
    final ethAddress = SolAddress.fromPublicKey(publicKey);
    final addressDetauls = NoneDecimalNetworkAddressDetails(
        address: ethAddress.address,
        balance: NoneDecimalBalance.zero(network.coinParam.decimal));
    return ISolanaAddress._(
      coin: accountParams.coin,
      publicKey: publicKey,
      address: addressDetauls,
      keyIndex: accountParams.deriveIndex,
      networkAddress: ethAddress,
      network: network.value,
      tokens: const [],
      nfts: const [],
    );
  }
  factory ISolanaAddress.fromCbsorHex(String hex, AppNetworkImpl network) {
    return ISolanaAddress.fromCborBytesOrObject(network,
        bytes: BytesUtils.fromHexString(hex));
  }
  factory ISolanaAddress.fromCborBytesOrObject(AppNetworkImpl network,
      {List<int>? bytes, CborObject? obj}) {
    final toCborTag = (obj ?? CborObject.fromCbor(bytes!)) as CborTagValue;

    final CborListValue cbor = CborSerializable.decodeCborTags(
        null, toCborTag, WalletModelCborTagsConst.solAccount);
    final CryptoProposal proposal = CryptoProposal.fromName(cbor.elementAt(0));
    final CryptoCoins coin = CryptoCoins.getCoin(cbor.elementAt(1), proposal)!;
    final keyIndex =
        AddressDerivationIndex.fromCborBytesOrObject(obj: cbor.getCborTag(2));
    final List<int> publicKey = cbor.elementAt(3);
    final networkId = cbor.elementAt(6);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final NoneDecimalNetworkAddressDetails address =
        NoneDecimalNetworkAddressDetails.fromCborBytesOrObject(
            network.coinParam.decimal,
            obj: cbor.getCborTag(4));

    final SolAddress ethAddress = SolAddress(cbor.elementAt(5));

    final List<SolanaSPLToken> splTokens = [];
    final List<dynamic>? tokens = cbor.elementAt(7);
    if (tokens != null) {
      for (final i in tokens) {
        splTokens.add(SolanaSPLToken.fromCborBytesOrObject(obj: i));
      }
    }

    final String? accountName = cbor.elementAt(9);
    return ISolanaAddress._(
        coin: coin,
        publicKey: publicKey,
        address: address,
        keyIndex: keyIndex,
        networkAddress: ethAddress,
        network: networkId,
        tokens: splTokens,
        nfts: [],
        accountName: accountName);
  }

  @override
  String accountToString() {
    return address.toAddress;
  }

  @override
  final NetworkAddressDetailsCore<BigInt> address;

  @override
  final CryptoCoins coin;

  @override
  final AddressDerivationIndex keyIndex;

  @override
  final int network;

  @override
  final List<int> publicKey;

  @override
  List<String> get signers => [BytesUtils.toHexString(publicKey)];

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
          accountName ?? const CborNullValue()
        ]),
        WalletModelCborTagsConst.solAccount);
  }

  @override
  List get variabels {
    return [keyIndex, network];
  }

  @override
  final SolAddress networkAddress;

  @override
  String? get type => null;

  List<SolanaSPLToken> _tokens;
  @override
  List<SolanaSPLToken> get tokens => _tokens;

  List<NFTCore> _nfts;
  @override
  List<NFTCore> get nfts => _nfts;

  @override
  void addToken(TokenCore<BigInt> newToken) {
    if (newToken is! SolanaSPLToken) {
      throw WalletExceptionConst.invalidArgruments(
          "SolanaSPLToken", "${newToken.runtimeType}");
    }
    if (_tokens.contains(newToken)) {
      throw WalletExceptionConst.tokenAlreadyExist;
    }
    _tokens = List.unmodifiable([newToken, ..._tokens]);
  }

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

  SolAddress associatedTokenAccount(
          {required SolAddress mint,
          SolAddress tokenProgramId = SPLTokenProgramConst.tokenProgramId}) =>
      AssociatedTokenAccountProgramUtils.associatedTokenAccount(
              mint: mint, owner: networkAddress, tokenProgramId: tokenProgramId)
          .address;
}
