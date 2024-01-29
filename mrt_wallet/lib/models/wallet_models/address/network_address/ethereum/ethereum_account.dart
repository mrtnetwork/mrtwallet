import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/models/wallet_models/address/address.dart';
import 'package:mrt_wallet/models/wallet_models/currency_balance/balance.dart';
import 'package:mrt_wallet/models/wallet_models/network/network_models.dart';
import 'package:mrt_wallet/models/wallet_models/nfts/core/nft_core.dart';
import 'package:mrt_wallet/models/wallet_models/nfts/networks/ripple/ripple_nft_token.dart';
import 'package:mrt_wallet/models/wallet_models/token/core/core.dart';
import 'package:mrt_wallet/models/wallet_models/token/networks/ethereum/erc20_token.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';
import 'package:on_chain/ethereum/address/evm_address.dart';

class IEthAddress
    with Equatable
    implements Bip32AddressCore<BigInt, ETHAddress> {
  IEthAddress._(
      {required this.keyIndex,
      required this.coin,
      required List<int> publicKey,
      required this.address,
      required this.network,
      required this.networkAddress,
      required List<ETHERC20Token> tokens,
      required List<RippleNFToken> nfts,
      String? accountName})
      : publicKey = List.unmodifiable(publicKey),
        _tokens = List.unmodifiable(tokens),
        _nfts = List.unmodifiable(nfts),
        _accountName = accountName;

  factory IEthAddress.newAccount(
      {required EthereumNewAddressParam accountParams,
      required List<int> publicKey,
      required AppNetworkImpl network}) {
    final ethAddress = ETHAddress.fromPublicKey(publicKey);
    final addressDetauls = NoneDecimalNetworkAddressDetails(
        address: ethAddress.address,
        balance: NoneDecimalBalance.zero(network.coinParam.decimal));
    return IEthAddress._(
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
  factory IEthAddress.fromCbsorHex(String hex, AppNetworkImpl network) {
    return IEthAddress.fromCborBytesOrObject(network,
        bytes: BytesUtils.fromHexString(hex));
  }
  factory IEthAddress.fromCborBytesOrObject(AppNetworkImpl network,
      {List<int>? bytes, CborObject? obj}) {
    final toCborTag = (obj ?? CborObject.fromCbor(bytes!)) as CborTagValue;

    final CborListValue cbor = CborSerializable.decodeCborTags(
        null, toCborTag, WalletModelCborTagsConst.ethAccount);
    final CryptoProposal proposal = CryptoProposal.fromName(cbor.getIndex(0));
    final CryptoCoins coin = CryptoCoins.getCoin(cbor.getIndex(1), proposal)!;
    final keyIndex =
        AddressDerivationIndex.fromCborBytesOrObject(obj: cbor.getCborTag(2));
    final List<int> publicKey = cbor.getIndex(3);
    final networkId = cbor.getIndex(6);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final NoneDecimalNetworkAddressDetails address =
        NoneDecimalNetworkAddressDetails.fromCborBytesOrObject(
            network.coinParam.decimal,
            obj: cbor.getCborTag(4));

    final ETHAddress ethAddress = ETHAddress(cbor.getIndex(5));

    final List<ETHERC20Token> erc20Tokens = [];
    final List<dynamic>? tokens = cbor.getIndex(7);
    if (tokens != null) {
      for (final i in tokens) {
        erc20Tokens.add(ETHERC20Token.fromCborBytesOrObject(obj: i));
      }
    }

    final String? accountName = cbor.getIndex(9);
    return IEthAddress._(
        coin: coin,
        publicKey: publicKey,
        address: address,
        keyIndex: keyIndex,
        networkAddress: ethAddress,
        network: networkId,
        tokens: erc20Tokens,
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
        WalletModelCborTagsConst.ethAccount);
  }

  @override
  List get variabels {
    return [keyIndex, network];
  }

  @override
  final ETHAddress networkAddress;

  @override
  String? get type => null;

  List<ETHERC20Token> _tokens;
  @override
  List<ETHERC20Token> get tokens => _tokens;

  List<NFTCore> _nfts;
  @override
  List<NFTCore> get nfts => _nfts;

  @override
  void addToken(TokenCore<BigInt> newToken) {
    if (newToken is! ETHERC20Token) {
      throw WalletExceptionConst.invalidArgruments(
          "ETHERC20Token", "${newToken.runtimeType}");
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
}
