import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/models/wallet_models/address/address.dart';
import 'package:mrt_wallet/models/wallet_models/currency_balance/balance.dart';
import 'package:mrt_wallet/models/wallet_models/network/custom/cardano/cardano_address_details.dart';
import 'package:mrt_wallet/models/wallet_models/network/network_models.dart';
import 'package:mrt_wallet/models/wallet_models/nfts/core/nft_core.dart';
import 'package:mrt_wallet/models/wallet_models/token/core/core.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';
import 'package:on_chain/ada/src/address/address.dart';

class ICardanoAddress
    with Equatable
    implements Bip32AddressCore<BigInt, ADAAddress> {
  ICardanoAddress._(
      {required this.keyIndex,
      required this.coin,
      required List<int> publicKey,
      required this.address,
      required this.network,
      required this.networkAddress,
      required List<TokenCore> tokens,
      required List<NFTCore> nfts,
      required this.addressDetails,
      String? accountName})
      : publicKey = List.unmodifiable(publicKey),
        _tokens = List.unmodifiable(tokens),
        _nfts = List.unmodifiable(nfts),
        _accountName = accountName;

  factory ICardanoAddress.newAccount(
      {required CardanoNewAddressParams accountParams,
      required List<int> publicKey,
      required APPCardanoNetwork network}) {
    final cardanoAddr = accountParams.toAddress();
    final addressDetauls = NoneDecimalNetworkAddressDetails(
        address: cardanoAddr.address,
        balance: NoneDecimalBalance.zero(network.coinParam.decimal));
    return ICardanoAddress._(
      coin: accountParams.coin,
      publicKey: publicKey,
      address: addressDetauls,
      keyIndex: accountParams.deriveIndex,
      networkAddress: cardanoAddr,
      network: network.value,
      tokens: const [],
      nfts: const [],
      addressDetails: accountParams.addressDetails!,
    );
  }
  factory ICardanoAddress.fromCbsorHex(String hex, AppNetworkImpl network) {
    return ICardanoAddress.fromCborBytesOrObject(network,
        bytes: BytesUtils.fromHexString(hex));
  }
  factory ICardanoAddress.fromCborBytesOrObject(AppNetworkImpl network,
      {List<int>? bytes, CborObject? obj}) {
    final toCborTag = (obj ?? CborObject.fromCbor(bytes!)) as CborTagValue;

    final CborListValue cbor = CborSerializable.decodeCborTags(
        null, toCborTag, WalletModelCborTagsConst.cardanoAccount);
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

    final ADAAddress adaAddress = ADAAddress.fromAddress(cbor.elementAt(5));
    final CardanoAddrDetails addrDetails =
        CardanoAddrDetails.fromCborBytesOrObject(obj: cbor.getCborTag(7));
    if (addrDetails.toAddress(coin).address != adaAddress.address) {
      throw MessageException("Incorrect ADA addresss.", details: {
        "address": adaAddress.address,
        "Excepted": addrDetails.toAddress(coin).address
      });
    }

    final String? accountName = cbor.elementAt(10);
    return ICardanoAddress._(
        coin: coin,
        publicKey: publicKey,
        address: address,
        keyIndex: keyIndex,
        networkAddress: adaAddress,
        network: networkId,
        addressDetails: addrDetails,
        tokens: [],
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
          addressDetails.toCbor(),
          CborListValue.fixedLength(_tokens.map((e) => e.toCbor()).toList()),
          CborListValue.fixedLength(_nfts.map((e) => e.toCbor()).toList()),
          accountName ?? const CborNullValue()
        ]),
        WalletModelCborTagsConst.cardanoAccount);
  }

  @override
  List get variabels {
    return [keyIndex, network, networkAddress.addressType];
  }

  final CardanoAddrDetails addressDetails;

  @override
  final ADAAddress networkAddress;

  @override
  String? get type => networkAddress.addressType.name;

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
  void updateToken(TokenCore<BigInt> token, Token updatedToken) {}
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
