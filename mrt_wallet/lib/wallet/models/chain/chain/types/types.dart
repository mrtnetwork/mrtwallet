part of 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';

enum WalletChainStatus { init, ready }

abstract class ChainConfig<STORAGE extends ChainStorageKey>
    with CborSerializable {
  abstract final double appbarHeight;
  abstract final bool hasAction;
  abstract final List<STORAGE> storageKeys;
  const ChainConfig();
}

abstract class ChainStorageKey {
  abstract final int storageId;
}

abstract class ChainStorageItem<STORAGEKEY extends ChainStorageKey>
    with CborSerializable {
  abstract final STORAGEKEY extraKey;
}

class DefaultChainConfig extends ChainConfig<ChainStorageKey> {
  const DefaultChainConfig() : storageKeys = const [];
  static const none = DefaultChainConfig();
  @override
  final List<ChainStorageKey> storageKeys;
  factory DefaultChainConfig.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    CborSerializable.cborTagValue<CborNullValue>(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: CborTagsConst.defaultChainConfig);
    return const DefaultChainConfig();
  }
  @override
  double get appbarHeight => 0;
  @override
  bool get hasAction => false;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        const CborNullValue(), CborTagsConst.defaultChainConfig);
  }
}

typedef APPCHAINNETWORKPROVIDER<PROVIDER extends APIProvider> = Chain<
    PROVIDER,
    NetworkCoinParams<PROVIDER>,
    dynamic,
    TokenCore,
    NFTCore,
    ChainAccount<dynamic, TokenCore, NFTCore>,
    WalletNetwork<NetworkCoinParams<PROVIDER>>,
    NetworkClient<ChainAccount<dynamic, TokenCore, NFTCore>, PROVIDER>,
    ChainStorageKey,
    ChainConfig,
    WalletTransaction<dynamic>>;

typedef APPCHAINNETWORK<NETWORKADDRESS> = Chain<
    APIProvider,
    NetworkCoinParams<APIProvider>,
    NETWORKADDRESS,
    TokenCore,
    NFTCore,
    ChainAccount<NETWORKADDRESS, TokenCore, NFTCore>,
    WalletNetwork<NetworkCoinParams<APIProvider>>,
    NetworkClient<ChainAccount<NETWORKADDRESS, TokenCore, NFTCore>,
        APIProvider>,
    ChainStorageKey,
    ChainConfig,
    WalletTransaction<NETWORKADDRESS>>;

typedef APPCHAINACCOUNT<CHAINACCOUNT extends ChainAccount> = Chain<
    APIProvider,
    NetworkCoinParams<APIProvider>,
    dynamic,
    TokenCore,
    NFTCore,
    CHAINACCOUNT,
    WalletNetwork<NetworkCoinParams<APIProvider>>,
    NetworkClient<CHAINACCOUNT, APIProvider>,
    ChainStorageKey,
    ChainConfig,
    WalletTransaction<dynamic>>;

typedef APPCHAIN = Chain<
    APIProvider,
    NetworkCoinParams<APIProvider>,
    dynamic,
    TokenCore,
    NFTCore,
    ChainAccount<dynamic, TokenCore, NFTCore>,
    WalletNetwork<NetworkCoinParams<APIProvider>>,
    NetworkClient<ChainAccount<dynamic, TokenCore, NFTCore>, APIProvider>,
    ChainStorageKey,
    ChainConfig,
    WalletTransaction<dynamic>>;
typedef APPCHAINTOKEN<TOKEN extends TokenCore> = Chain<
    APIProvider,
    NetworkCoinParams<APIProvider>,
    dynamic,
    TOKEN,
    NFTCore,
    ChainAccount<dynamic, TOKEN, NFTCore>,
    WalletNetwork<NetworkCoinParams<APIProvider>>,
    NetworkClient<ChainAccount<dynamic, TOKEN, NFTCore>, APIProvider>,
    ChainStorageKey,
    ChainConfig,
    WalletTransaction<dynamic>>;

typedef APPCHAINNFT<NFT extends NFTCore> = Chain<
    APIProvider,
    NetworkCoinParams<APIProvider>,
    dynamic,
    TokenCore,
    NFT,
    ChainAccount<dynamic, TokenCore, NFT>,
    WalletNetwork<NetworkCoinParams<APIProvider>>,
    NetworkClient<ChainAccount<dynamic, TokenCore, NFT>, APIProvider>,
    ChainStorageKey,
    ChainConfig,
    WalletTransaction<dynamic>>;

typedef APPCHAINACCOUNTCLIENT<
        CHAINACCOUNT extends ChainAccount,
        P extends APIProvider,
        CL extends NetworkClient<CHAINACCOUNT, P>,
        T extends TokenCore,
        N extends NFTCore>
    = Chain<
        P,
        NetworkCoinParams<P>,
        dynamic,
        TokenCore,
        NFTCore,
        CHAINACCOUNT,
        WalletNetwork<NetworkCoinParams<P>>,
        CL,
        ChainStorageKey,
        ChainConfig,
        WalletTransaction<dynamic>>;

abstract class BaseChain<
        PROVIDER extends APIProvider,
        NETWORKPARAMS extends NetworkCoinParams<APIProvider>,
        NETWORKADDRESS,
        CHAINTOKEN extends TokenCore,
        NFT extends NFTCore,
        ADDRESS extends ChainAccount<NETWORKADDRESS, CHAINTOKEN, NFT>,
        NETWORK extends WalletNetwork<NETWORKPARAMS>,
        CLIENT extends NetworkClient<ADDRESS, PROVIDER>,
        STORAGE extends ChainStorageKey,
        CONFIG extends ChainConfig<STORAGE>,
        TRANSACTION extends WalletTransaction<NETWORKADDRESS>>
    with CborSerializable {
  abstract final NETWORK network;
  abstract final Live<IntegerBalance> totalBalance;
  abstract final String id;
  abstract CLIENT? _client;

  abstract List<ADDRESS> _addresses;
  abstract int _addressIndex;
  abstract final List<String> services;
  abstract List<ContactCore<NETWORKADDRESS>> _contacts;
  List<ADDRESS> get addresses => _addresses;
  bool get haveAddress => addresses.isNotEmpty;
  List<ContactCore<NETWORKADDRESS>> get contacts => _contacts;
  ADDRESS get address => addresses.elementAt(_addressIndex);
  abstract Live<CONFIG> _config;
  CONFIG get config => _config.value;
  abstract final SynchronizedLock _lock;
}
