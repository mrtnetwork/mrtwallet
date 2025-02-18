part of 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';

abstract class Chain<
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
    extends BaseChain<PROVIDER, NETWORKPARAMS, NETWORKADDRESS, CHAINTOKEN, NFT,
        ADDRESS, NETWORK, CLIENT, STORAGE, CONFIG, TRANSACTION>
    with
        ChainStorageManager<NETWORK, STORAGE, CONFIG>,
        BaseChainController<PROVIDER, NETWORKPARAMS, NETWORKADDRESS, CHAINTOKEN,
            NFT, ADDRESS, NETWORK, CLIENT, STORAGE, CONFIG, TRANSACTION>,
        CborSerializable {
  @override
  final NETWORK network;
  @override
  CLIENT? _client;
  @override
  List<ADDRESS> _addresses;
  @override
  int _addressIndex;
  @override
  final Live<IntegerBalance> totalBalance;
  @override
  List<ContactCore<NETWORKADDRESS>> _contacts;
  @override
  List<ADDRESS> get addresses => _addresses;
  @override
  bool get haveAddress => addresses.isNotEmpty;
  @override
  List<ContactCore<NETWORKADDRESS>> get contacts => _contacts;
  @override
  ADDRESS get address => addresses.elementAt(_addressIndex);
  @override
  final String id;
  @override
  Live<CONFIG> _config;
  @override
  CONFIG get config => _config.value;

  bool get transferEnabled => true;

  @override
  final _lock = SynchronizedLock();

  WalletChainStatus _chainStatus;
  WalletChainStatus get chainStatus => _chainStatus;

  factory Chain.deserialize({String? hex, CborObject? obj, List<int>? bytes}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: obj, hex: hex, tags: CborTagsConst.iAccount);
    final int networkId = values.elementAs(0);
    WalletNetwork? network = MethodUtils.nullOnException(() {
      return WalletNetwork.fromCborBytesOrObject(obj: values.getCborTag(6));
    });
    network = ChainConst.updateNetwork(networkId: networkId, network: network);
    final ProviderIdentifier? providerId = MethodUtils.nullOnException(() {
      final CborTagValue? identifier = values.elementAs(10);
      if (identifier == null) return null;
      return ProviderIdentifier.deserialize(cbor: identifier);
    });
    return Chain._fromNetwork(
        network: network, values: values, provider: providerId);
  }
  static Chain setup({required WalletNetwork network, required String id}) {
    switch (network.type) {
      case NetworkType.ethereum:
        return EthereumChain.setup(
            network: network.toNetwork(),
            client: APIUtils.createApiClient(network),
            id: id);
      case NetworkType.tron:
        return TronChain.setup(
            network: network.toNetwork(),
            client: APIUtils.createApiClient(network),
            id: id);
      case NetworkType.xrpl:
        return RippleChain.setup(
            network: network.toNetwork(),
            client: APIUtils.createApiClient(network),
            id: id);
      case NetworkType.solana:
        return SolanaChain.setup(
            network: network.toNetwork(),
            client: APIUtils.createApiClient(network),
            id: id);
      case NetworkType.stellar:
        return StellarChain.setup(
            network: network.toNetwork(),
            client: APIUtils.createApiClient(network),
            id: id);

      case NetworkType.cardano:
        return ADAChain.setup(
            network: network.toNetwork(),
            client: APIUtils.createApiClient(network),
            id: id);
      case NetworkType.cosmos:
        return CosmosChain.setup(
            network: network.toNetwork(),
            client: APIUtils.createApiClient(network),
            id: id);
      case NetworkType.ton:
        return TheOpenNetworkChain.setup(
            network: network.toNetwork(),
            client: APIUtils.createApiClient(network),
            id: id);
      case NetworkType.monero:
        return MoneroChain.setup(
            network: network.toNetwork(),
            client: APIUtils.createApiClient(network),
            id: id);
      case NetworkType.substrate:
        return SubstrateChain.setup(
            network: network.toNetwork(),
            client: APIUtils.createApiClient(network),
            id: id);
      case NetworkType.bitcoinAndForked:
      case NetworkType.bitcoinCash:
        return BitcoinChain.setup(
            network: network.toNetwork(),
            client: APIUtils.createApiClient(network),
            id: id);
      case NetworkType.sui:
        return SuiChain.setup(
            network: network.toNetwork(),
            client: APIUtils.createApiClient(network),
            id: id);
      case NetworkType.aptos:
        return AptosChain.setup(
            network: network.toNetwork(),
            client: APIUtils.createApiClient(network),
            id: id);
      default:
        throw UnimplementedError("network does not eixst.");
    }
  }

  factory Chain._fromNetwork(
      {required WalletNetwork network,
      required CborListValue values,
      ProviderIdentifier? provider}) {
    final Chain chain;
    switch (network.type) {
      case NetworkType.bitcoinCash:
      case NetworkType.bitcoinAndForked:
        chain = BitcoinChain.deserialize(
            network: network.toNetwork(),
            cbor: values,
            client: APIUtils.createApiClient(network, identifier: provider));
        break;
      case NetworkType.substrate:
        chain = SubstrateChain.deserialize(
            network: network.toNetwork(),
            cbor: values,
            client: APIUtils.createApiClient(network, identifier: provider));
        break;
      case NetworkType.ethereum:
        chain = EthereumChain.deserialize(
            network: network.toNetwork(),
            cbor: values,
            client: APIUtils.createApiClient(network, identifier: provider));
        break;
      case NetworkType.cosmos:
        chain = CosmosChain.deserialize(
            network: network.toNetwork(),
            cbor: values,
            client: APIUtils.createApiClient(network, identifier: provider));
        break;
      case NetworkType.ton:
        chain = TheOpenNetworkChain.deserialize(
            network: network.toNetwork(),
            cbor: values,
            client: APIUtils.createApiClient(network, identifier: provider));
        break;
      case NetworkType.tron:
        chain = TronChain.deserialize(
            network: network.toNetwork(),
            cbor: values,
            client: APIUtils.createApiClient(network, identifier: provider));
        break;
      case NetworkType.xrpl:
        chain = RippleChain.deserialize(
            network: network.toNetwork(),
            cbor: values,
            client: APIUtils.createApiClient(network, identifier: provider));
        break;
      case NetworkType.solana:
        chain = SolanaChain.deserialize(
            network: network.toNetwork(),
            cbor: values,
            client: APIUtils.createApiClient(network, identifier: provider));
        break;
      case NetworkType.stellar:
        chain = StellarChain.deserialize(
            network: network.toNetwork(),
            cbor: values,
            client: APIUtils.createApiClient(network, identifier: provider));
        break;
      case NetworkType.monero:
        chain = MoneroChain.deserialize(
            network: network.toNetwork(),
            cbor: values,
            client: APIUtils.createApiClient(network, identifier: provider));
        break;

      case NetworkType.cardano:
        chain = ADAChain.deserialize(
            network: network.toNetwork(),
            cbor: values,
            client: APIUtils.createApiClient(network, identifier: provider));
        break;
      case NetworkType.sui:
        chain = SuiChain.deserialize(
            network: network.toNetwork(),
            cbor: values,
            client: APIUtils.createApiClient(network, identifier: provider));
        break;
      case NetworkType.aptos:
        chain = AptosChain.deserialize(
            network: network.toNetwork(),
            cbor: values,
            client: APIUtils.createApiClient(network, identifier: provider));
        break;
      default:
        throw UnimplementedError("Network does not exist");
    }
    return chain.cast();
  }

  Chain._(
      {required this.network,
      required this.totalBalance,
      required this.id,
      required CONFIG config,
      List<ADDRESS> addresses = const [],
      List<ContactCore<NETWORKADDRESS>> contacts = const [],
      required int addressIndex,
      required CLIENT? client,
      required WalletChainStatus status})
      : _addresses = addresses.imutable,
        _addressIndex = addressIndex,
        _contacts = contacts.imutable,
        _client = client,
        _config = Live(config),
        _chainStatus = status;

  Chain copyWith(
      {NETWORK? network,
      Live<IntegerBalance>? totalBalance,
      List<ADDRESS>? addresses,
      List<ContactCore<NETWORKADDRESS>>? contacts,
      int? addressIndex,
      String? id});
}
