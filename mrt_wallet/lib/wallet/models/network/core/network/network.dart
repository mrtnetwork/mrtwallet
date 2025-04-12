import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_native_support/platform_interface.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/app/euqatable/equatable.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/wallet/api/api.dart';
import 'package:mrt_wallet/crypto/coins/custom_coins/coins.dart';
import 'package:mrt_wallet/wallet/constant/chain/const.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/wallet/models/networks/tron/models/chain_type.dart';
import 'package:mrt_wallet/wallet/models/token/token/token.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';

abstract class WalletNetwork<PARAMS extends NetworkCoinParams>
    with Equatable, CborSerializable {
  const WalletNetwork();
  abstract final int value;
  abstract final PARAMS coinParam;
  abstract final NetworkType type;
  bool get isWalletNetwork => value >= 0;
  bool get isImportedNetwork => value >= ChainConst.importedNetworkStartId;
  bool get supportCustomNode;
  Token get token => coinParam.token;
  int get coinDecimal => token.decimal!;
  WalletNetwork copyWith({int? value, PARAMS? coinParam});
  String get networkName => token.name;
  String get networkSymbol => token.symbol;
  List<CryptoCoins> get coins;
  bool get supportImportNetwork => false;
  bool get supportWeb3 => false;
  String? get accountExplorer => ChainConst.getAddressExplorer(value);
  String? get txExplorer => ChainConst.getTxExplorer(value);

  Object get identifier;

  String? getAccountExplorer(String? address) {
    if (address == null) return null;
    return accountExplorer?.replaceAll(
        NetworkCoinParamsConst.addrArgs, address);
  }

  String? getTransactionExplorer(String txId) {
    return txExplorer?.replaceAll(NetworkCoinParamsConst.txIdArgs, txId);
  }

  T? getProvider<T extends APIProvider>(
      {String? identifier, bool allowInWeb3 = false}) {
    Iterable<T> supportedProviders = coinParam.providers.whereType<T>().where(
        (element) => element.protocol
            .supportOnThisPlatform(PlatformInterface.appPlatform));
    if (allowInWeb3) {
      supportedProviders = supportedProviders.where((e) => e.allowInWeb3);
    }
    if (supportedProviders.isEmpty) return null;

    if (identifier == null) {
      return supportedProviders.first;
    }
    return supportedProviders.firstWhere(
        (element) => element.identifier == identifier,
        orElse: () => supportedProviders.first);
  }

  T toNetwork<T extends WalletNetwork>() {
    if (this is! T) throw WalletExceptionConst.incorrectNetwork;
    return this as T;
  }

  static WalletNetwork fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final toCborTag = (obj ?? CborObject.fromCbor(bytes!)) as CborTagValue;
    final network = NetworkType.fromTag(toCborTag.tags);
    switch (network) {
      case NetworkType.bitcoinAndForked:
        return WalletBitcoinNetwork.fromCborBytesOrObject(obj: toCborTag);
      case NetworkType.bitcoinCash:
        return WalletBitcoinCashNetwork.fromCborBytesOrObject(obj: toCborTag);
      case NetworkType.xrpl:
        return WalletXRPNetwork.fromCborBytesOrObject(obj: toCborTag);
      case NetworkType.ethereum:
        return WalletEthereumNetwork.fromCborBytesOrObject(obj: toCborTag);
      case NetworkType.solana:
        return WalletSolanaNetwork.fromCborBytesOrObject(obj: toCborTag);
      case NetworkType.cardano:
        return WalletCardanoNetwork.fromCborBytesOrObject(obj: toCborTag);
      case NetworkType.cosmos:
        return WalletCosmosNetwork.fromCborBytesOrObject(obj: toCborTag);
      case NetworkType.ton:
        return WalletTonNetwork.fromCborBytesOrObject(obj: toCborTag);
      case NetworkType.tron:
        return WalletTronNetwork.fromCborBytesOrObject(obj: toCborTag);
      case NetworkType.substrate:
        return WalletSubstrateNetwork.fromCborBytesOrObject(obj: toCborTag);
      case NetworkType.stellar:
        return WalletStellarNetwork.fromCborBytesOrObject(obj: toCborTag);
      case NetworkType.monero:
        return WalletMoneroNetwork.fromCborBytesOrObject(obj: toCborTag);
      case NetworkType.aptos:
        return WalletAptosNetwork.fromCborBytesOrObject(obj: toCborTag);
      case NetworkType.sui:
        return WalletSuiNetwork.fromCborBytesOrObject(obj: toCborTag);
      default:
        throw UnimplementedError("network does not exist.");
    }
  }

  List<APIProvider> getAllProviders() {
    return [
      ...ProvidersConst.getDefaultProvider(this),
      ...coinParam.providers.where((element) =>
          element.protocol.platforms.contains(PlatformInterface.appPlatform)),
    ];
  }
}

class WalletBitcoinNetwork extends WalletNetwork<BitcoinParams> {
  @override
  final int value;
  @override
  final BitcoinParams coinParam;
  @override
  bool get supportWeb3 => true;

  factory WalletBitcoinNetwork.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CborTagsConst.bitconNetwork);
    return WalletBitcoinNetwork(cbor.elementAt(0),
        BitcoinParams.fromCborBytesOrObject(obj: cbor.getCborTag(1)));
  }

  const WalletBitcoinNetwork(this.value, this.coinParam);

  bool get isBitcoin => true;

  @override
  NetworkType get type => NetworkType.bitcoinAndForked;

  @override
  List<BipCoins> get coins => coinParam.transacationNetwork.coins;

  CryptoCoins findCOinFromBitcoinAddressType(BitcoinAddressType type) {
    if (type.isP2sh) {
      return coins
          .firstWhere((element) => element.proposal == BipProposal.bip49);
    }
    switch (type) {
      case P2pkhAddressType.p2pkh:
      case P2pkhAddressType.p2pkhwt:
      case PubKeyAddressType.p2pk:
        return coins
            .firstWhere((element) => element.proposal == BipProposal.bip44);
      case SegwitAddressType.p2wsh:
      case SegwitAddressType.p2wpkh:
        return coins
            .firstWhere((element) => element.proposal == BipProposal.bip84);
      default:
        return coins
            .firstWhere((element) => element.proposal == BipProposal.bip86);
    }
  }

  @override
  List get variabels => [value];

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([value, coinParam.toCbor()]),
        CborTagsConst.bitconNetwork);
  }

  @override
  bool get supportCustomNode => true;

  @override
  WalletBitcoinNetwork copyWith({int? value, BitcoinParams? coinParam}) {
    return WalletBitcoinNetwork(
        value ?? this.value, coinParam ?? this.coinParam);
  }

  String get genesisBlock => ChainConst.getDefaultGenesisBlock(value);

  @override
  Object get identifier => genesisBlock;
}

class WalletBitcoinCashNetwork extends WalletBitcoinNetwork {
  @override
  WalletBitcoinCashNetwork copyWith({int? value, BitcoinParams? coinParam}) {
    return WalletBitcoinCashNetwork(
        value ?? this.value, coinParam ?? this.coinParam);
  }

  const WalletBitcoinCashNetwork(super.value, super.coinParam);
  @override
  bool get isBitcoin => false;

  @override
  NetworkType get type => NetworkType.bitcoinCash;

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([value, coinParam.toCbor()]),
        CborTagsConst.bitcoinCashNetwork);
  }

  factory WalletBitcoinCashNetwork.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CborTagsConst.bitcoinCashNetwork);
    return WalletBitcoinCashNetwork(
      cbor.elementAt(0),
      BitcoinParams.fromCborBytesOrObject(obj: cbor.getCborTag(1)),
    );
  }
}

class WalletXRPNetwork extends WalletNetwork<RippleNetworkParams> {
  @override
  final int value;
  @override
  final RippleNetworkParams coinParam;

  const WalletXRPNetwork(this.value, this.coinParam);
  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([value, coinParam.toCbor()]),
        CborTagsConst.xrpNetwork);
  }

  factory WalletXRPNetwork.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor =
        CborSerializable.decodeCborTags(bytes, obj, CborTagsConst.xrpNetwork);
    return WalletXRPNetwork(
      cbor.elementAt(0),
      RippleNetworkParams.fromCborBytesOrObject(obj: cbor.getCborTag(1)),
    );
  }

  @override
  List<BipCoins> get coins {
    if (coinParam.mainnet) {
      return [Bip44Coins.ripple, Bip44Coins.rippleEd25519];
    }
    return [Bip44Coins.rippleTestnet, Bip44Coins.rippleTestnetED25519];
  }

  @override
  List get variabels => [value];

  @override
  bool get supportCustomNode => true;

  @override
  NetworkType get type => NetworkType.xrpl;

  @override
  WalletXRPNetwork copyWith({int? value, RippleNetworkParams? coinParam}) {
    return WalletXRPNetwork(value ?? this.value, coinParam ?? this.coinParam);
  }

  @override
  Object get identifier => coinParam.identifier;
}
//

class WalletEthereumNetwork extends WalletNetwork<EthereumNetworkParams> {
  @override
  final int value;
  @override
  final EthereumNetworkParams coinParam;

  @override
  bool get supportWeb3 => true;

  const WalletEthereumNetwork(this.value, this.coinParam);
  factory WalletEthereumNetwork.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor =
        CborSerializable.decodeCborTags(bytes, obj, CborTagsConst.evmNetwork);
    return WalletEthereumNetwork(
      cbor.elementAt(0),
      EthereumNetworkParams.fromCborBytesOrObject(obj: cbor.getCborTag(1)),
    );
  }
  @override
  WalletEthereumNetwork copyWith(
      {int? value, EthereumNetworkParams? coinParam, int? slip44}) {
    return WalletEthereumNetwork(
        value ?? this.value, coinParam ?? this.coinParam);
  }

  @override
  List<BipCoins> get coins {
    if (coinParam.mainnet) {
      return [Bip44Coins.ethereum];
    }
    return [Bip44Coins.ethereumTestnet];
  }

  @override
  List get variabels => [value];
  @override
  bool get supportImportNetwork => true;
  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([value, coinParam.toCbor()]),
        CborTagsConst.evmNetwork);
  }

  @override
  bool get supportCustomNode => true;
  @override
  NetworkType get type => NetworkType.ethereum;

  static WalletEthereumNetwork create() {
    return WalletEthereumNetwork(
      -1,
      EthereumNetworkParams(
          transactionExplorer: null,
          addressExplorer: null,
          defaultNetwork: false,
          token: Token(name: "", symbol: "", decimal: 18),
          providers: [],
          chainId: BigInt.zero,
          supportEIP1559: false,
          chainType: ChainType.testnet),
    );
  }

  @override
  Object get identifier => coinParam.identifier;

  @override
  String? get accountExplorer =>
      coinParam.addressExplorer ?? ChainConst.getAddressExplorer(value);
  @override
  String? get txExplorer =>
      coinParam.transactionExplorer ?? ChainConst.getTxExplorer(value);
}

class WalletTronNetwork extends WalletNetwork<TronNetworkParams> {
  @override
  final int value;
  @override
  final TronNetworkParams coinParam;
  const WalletTronNetwork(this.value, this.coinParam);
  @override
  bool get supportWeb3 => true;
  TronChainType get tronNetworkType => TronChainType.fromId(value);

  factory WalletTronNetwork.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor =
        CborSerializable.decodeCborTags(bytes, obj, CborTagsConst.tvmNetwork);
    return WalletTronNetwork(
      cbor.elementAt(0),
      TronNetworkParams.fromCborBytesOrObject(obj: cbor.getCborTag(1)),
    );
  }
  @override
  List<BipCoins> get coins {
    if (coinParam.mainnet) {
      return [Bip44Coins.tron];
    }
    return [Bip44Coins.tronTestnet];
  }

  @override
  List get variabels => [value];
  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([value, coinParam.toCbor()]),
        CborTagsConst.tvmNetwork);
  }

  @override
  bool get supportCustomNode => true;

  @override
  NetworkType get type => NetworkType.tron;

  @override
  WalletTronNetwork copyWith({int? value, TronNetworkParams? coinParam}) {
    return WalletTronNetwork(value ?? this.value, coinParam ?? this.coinParam);
  }

  String get genesisBlock => ChainConst.getDefaultGenesisBlock(value);
  @override
  Object get identifier => genesisBlock;
}

class WalletSolanaNetwork extends WalletNetwork<SolanaNetworkParams> {
  @override
  final int value;
  @override
  final SolanaNetworkParams coinParam;
  String get genesisBlock => ChainConst.getDefaultGenesisBlock(value);
  @override
  bool get supportWeb3 => true;
  const WalletSolanaNetwork(this.value, this.coinParam);
  factory WalletSolanaNetwork.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CborTagsConst.solanaNetwork);
    return WalletSolanaNetwork(
      cbor.elementAt(0),
      SolanaNetworkParams.fromCborBytesOrObject(obj: cbor.getCborTag(1)),
    );
  }
  @override
  WalletSolanaNetwork copyWith({int? value, SolanaNetworkParams? coinParam}) {
    return WalletSolanaNetwork(
        value ?? this.value, coinParam ?? this.coinParam);
  }

  @override
  List<BipCoins> get coins {
    if (coinParam.mainnet) {
      return [Bip44Coins.solana];
    }
    return [Bip44Coins.solanaTestnet];
  }

  @override
  List get variabels => [value];

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([value, coinParam.toCbor()]),
        CborTagsConst.solanaNetwork);
  }

  @override
  bool get supportCustomNode => true;

  @override
  NetworkType get type => NetworkType.solana;
  @override
  Object get identifier => genesisBlock;
}

class WalletCardanoNetwork extends WalletNetwork<CardanoNetworkParams> {
  @override
  final int value;
  @override
  final CardanoNetworkParams coinParam;
  const WalletCardanoNetwork(this.value, this.coinParam);
  factory WalletCardanoNetwork.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CborTagsConst.cardanoNetwork);
    return WalletCardanoNetwork(
      cbor.elementAt(0),
      CardanoNetworkParams.fromCborBytesOrObject(obj: cbor.getCborTag(1)),
    );
  }

  ADANetwork get toCardanoNetwork =>
      coinParam.mainnet ? ADANetwork.mainnet : ADANetwork.testnetPreprod;

  @override
  List<BipCoins> get coins {
    return [
      if (coinParam.mainnet) ...[
        Bip44Coins.cardanoByronLedger,
        Bip44Coins.cardanoByronIcarus,
        Cip1852Coins.cardanoIcarus,
        Cip1852Coins.cardanoLedger,
        CustomCoins.byronLegacy
      ] else ...[
        Bip44Coins.cardanoByronIcarusTestnet,
        Bip44Coins.cardanoByronLedgerTestnet,
        Cip1852Coins.cardanoIcarusTestnet,
        Cip1852Coins.cardanoLedgerTestnet,
        CustomCoins.byronLegacyTestnet
      ]
    ];
  }

  @override
  List get variabels => [value];

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([value, coinParam.toCbor()]),
        CborTagsConst.cardanoNetwork);
  }

  @override
  bool get supportCustomNode => true;

  @override
  NetworkType get type => NetworkType.cardano;

  @override
  WalletCardanoNetwork copyWith({int? value, CardanoNetworkParams? coinParam}) {
    return WalletCardanoNetwork(
        value ?? this.value, coinParam ?? this.coinParam);
  }

  @override
  Object get identifier => coinParam.identifier;
}

class WalletCosmosNetwork extends WalletNetwork<CosmosNetworkParams> {
  @override
  final int value;
  @override
  final CosmosNetworkParams coinParam;
  @override
  bool get supportWeb3 => true;
  const WalletCosmosNetwork(this.value, this.coinParam);
  factory WalletCosmosNetwork.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CborTagsConst.cosmosNetwork);
    return WalletCosmosNetwork(
      cbor.elementAt(0),
      CosmosNetworkParams.fromCborBytesOrObject(obj: cbor.getCborTag(1)),
    );
  }

  @override
  List<BipCoins> get coins {
    return coinParam.coins();
  }

  @override
  List get variabels => [value];

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([value, coinParam.toCbor()]),
        CborTagsConst.cosmosNetwork);
  }

  @override
  bool get supportCustomNode => true;
  @override
  bool get supportImportNetwork => true;

  @override
  NetworkType get type => NetworkType.cosmos;

  @override
  WalletCosmosNetwork copyWith({int? value, CosmosNetworkParams? coinParam}) {
    return WalletCosmosNetwork(
        value ?? this.value, coinParam ?? this.coinParam);
  }

  @override
  Object get identifier => coinParam.identifier;

  @override
  String? get accountExplorer =>
      coinParam.addressExplorer ?? ChainConst.getAddressExplorer(value);
  @override
  String? get txExplorer =>
      coinParam.transactionExplorer ?? ChainConst.getTxExplorer(value);
}

class WalletTonNetwork extends WalletNetwork<TonNetworkParams> {
  @override
  final int value;
  @override
  final TonNetworkParams coinParam;
  @override
  bool get supportWeb3 => true;

  const WalletTonNetwork(this.value, this.coinParam);
  factory WalletTonNetwork.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor =
        CborSerializable.decodeCborTags(bytes, obj, CborTagsConst.tonNetwork);
    return WalletTonNetwork(
      cbor.elementAt(0),
      TonNetworkParams.fromCborBytesOrObject(obj: cbor.getCborTag(1)),
    );
  }

  @override
  List<BipCoins> get coins {
    if (coinParam.mainnet) {
      return [Bip44Coins.tonMainnet];
    }
    return [Bip44Coins.tonTestnet];
  }

  @override
  List get variabels => [value];

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([value, coinParam.toCbor()]),
        CborTagsConst.tonNetwork);
  }

  @override
  bool get supportCustomNode => true;
  @override
  NetworkType get type => NetworkType.ton;

  @override
  WalletTonNetwork copyWith({int? value, TonNetworkParams? coinParam}) {
    return WalletTonNetwork(value ?? this.value, coinParam ?? this.coinParam);
  }

  @override
  Object get identifier => coinParam.identifier;
}

class WalletSubstrateNetwork extends WalletNetwork<SubstrateNetworkParams> {
  @override
  final int value;
  @override
  final SubstrateNetworkParams coinParam;
  const WalletSubstrateNetwork(this.value, this.coinParam);
  factory WalletSubstrateNetwork.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CborTagsConst.substrateNetwork);
    return WalletSubstrateNetwork(cbor.elementAt(0),
        SubstrateNetworkParams.fromCborBytesOrObject(obj: cbor.getCborTag(1)));
  }

  @override
  List<CryptoCoins> get coins {
    return [
      SubstrateCoins.genericEd25519,
      SubstrateCoins.genericSecp256k1,
      SubstrateCoins.genericSr25519,
      if (coinParam.mainnet) ...[
        Bip44Coins.polkadotEd25519Slip,
        Bip44Coins.ethereum
      ] else ...[
        Bip44Coins.polkadotTestnetEd25519Slip,
        Bip44Coins.ethereumTestnet
      ]
    ];
  }

  @override
  List get variabels => [value];

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([value, coinParam.toCbor()]),
        CborTagsConst.substrateNetwork);
  }

  @override
  bool get supportCustomNode => true;

  @override
  NetworkType get type => NetworkType.substrate;

  @override
  WalletSubstrateNetwork copyWith(
      {int? value, SubstrateNetworkParams? coinParam}) {
    return WalletSubstrateNetwork(
        value ?? this.value, coinParam ?? this.coinParam);
  }

  String get genesisBlock =>
      coinParam.gnesisBlock ?? ChainConst.getDefaultGenesisBlock(value);

  @override
  Object get identifier => genesisBlock;

  @override
  bool get supportImportNetwork => true;

  @override
  bool get supportWeb3 => true;
}

class WalletStellarNetwork extends WalletNetwork<StellarNetworkParams> {
  @override
  final int value;
  @override
  final StellarNetworkParams coinParam;

  @override
  bool get supportWeb3 => true;

  const WalletStellarNetwork(this.value, this.coinParam);
  factory WalletStellarNetwork.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CborTagsConst.stellarNetwork);
    return WalletStellarNetwork(
      cbor.elementAt(0),
      StellarNetworkParams.fromCborBytesOrObject(obj: cbor.getCborTag(1)),
    );
  }

  @override
  List<BipCoins> get coins {
    if (coinParam.mainnet) {
      return [Bip44Coins.stellar];
    }
    return [Bip44Coins.stellarTestnet];
  }

  @override
  List get variabels => [value];

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([value, coinParam.toCbor()]),
        CborTagsConst.stellarNetwork);
  }

  @override
  bool get supportCustomNode => false;
  @override
  NetworkType get type => NetworkType.stellar;

  @override
  WalletStellarNetwork copyWith({int? value, StellarNetworkParams? coinParam}) {
    return WalletStellarNetwork(
        value ?? this.value, coinParam ?? this.coinParam);
  }

  @override
  Object get identifier => coinParam.identifier;
}

class WalletMoneroNetwork extends WalletNetwork<MoneroNetworkParams> {
  @override
  final int value;
  @override
  final MoneroNetworkParams coinParam;

  const WalletMoneroNetwork(this.value, this.coinParam);
  factory WalletMoneroNetwork.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CborTagsConst.moneroNetwork);
    return WalletMoneroNetwork(
      cbor.elementAt(0),
      MoneroNetworkParams.fromCborBytesOrObject(obj: cbor.getCborTag(1)),
    );
  }

  @override
  List<BipCoins> get coins {
    if (coinParam.mainnet) {
      return [Bip44Coins.moneroEd25519Slip];
    }
    return [Bip44Coins.moneroEd25519Slip];
  }

  @override
  List get variabels => [value];

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([value, coinParam.toCbor()]),
        CborTagsConst.moneroNetwork);
  }

  @override
  bool get supportCustomNode => true;
  @override
  NetworkType get type => NetworkType.monero;

  @override
  WalletMoneroNetwork copyWith({int? value, MoneroNetworkParams? coinParam}) {
    return WalletMoneroNetwork(
        value ?? this.value, coinParam ?? this.coinParam);
  }

  String get genesisBlock => ChainConst.getDefaultGenesisBlock(value);
  @override
  Object get identifier => genesisBlock;
}

class WalletAptosNetwork extends WalletNetwork<AptosNetworkParams> {
  @override
  final int value;
  @override
  final AptosNetworkParams coinParam;
  @override
  bool get supportWeb3 => true;
  const WalletAptosNetwork(this.value, this.coinParam);
  factory WalletAptosNetwork.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor =
        CborSerializable.decodeCborTags(bytes, obj, CborTagsConst.aptosNetwork);
    return WalletAptosNetwork(
      cbor.elementAt(0),
      AptosNetworkParams.fromCborBytesOrObject(obj: cbor.getCborTag(1)),
    );
  }
  @override
  WalletAptosNetwork copyWith({int? value, AptosNetworkParams? coinParam}) {
    return WalletAptosNetwork(value ?? this.value, coinParam ?? this.coinParam);
  }

  @override
  List<BipCoins> get coins {
    return [
      Bip44Coins.aptos,
      Bip44Coins.aptosEd25519SingleKey,
      Bip44Coins.aptosSecp256k1SingleKey,
    ];
  }

  @override
  List get variabels => [value];

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([value, coinParam.toCbor()]),
        CborTagsConst.aptosNetwork);
  }

  @override
  bool get supportCustomNode => true;

  @override
  NetworkType get type => NetworkType.aptos;
  @override
  Object get identifier => coinParam.aptosChainType;
}

class WalletSuiNetwork extends WalletNetwork<SuiNetworkParams> {
  @override
  final int value;
  @override
  final SuiNetworkParams coinParam;
  @override
  bool get supportWeb3 => true;
  const WalletSuiNetwork(this.value, this.coinParam);
  factory WalletSuiNetwork.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor =
        CborSerializable.decodeCborTags(bytes, obj, CborTagsConst.suiNetwork);
    return WalletSuiNetwork(
      cbor.elementAt(0),
      SuiNetworkParams.fromCborBytesOrObject(obj: cbor.getCborTag(1)),
    );
  }
  @override
  WalletSuiNetwork copyWith({int? value, SuiNetworkParams? coinParam}) {
    return WalletSuiNetwork(value ?? this.value, coinParam ?? this.coinParam);
  }

  @override
  List<BipCoins> get coins {
    return [
      Bip44Coins.sui,
      Bip44Coins.suiSecp256k1,
      Bip44Coins.suiSecp256r1,
    ];
  }

  @override
  List get variabels => [value];

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([value, coinParam.toCbor()]),
        CborTagsConst.suiNetwork);
  }

  @override
  bool get supportCustomNode => true;

  @override
  NetworkType get type => NetworkType.sui;
  @override
  Object get identifier => coinParam.identifier;
}
