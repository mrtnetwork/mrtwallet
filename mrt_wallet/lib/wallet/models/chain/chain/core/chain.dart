part of 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';

typedef APPCHAINNETWORKPROVIDER<PROVIDER extends APIProvider> = Chain<
    PROVIDER,
    NetworkCoinParams<PROVIDER>,
    dynamic,
    TokenCore,
    NFTCore,
    ChainAccount<dynamic, TokenCore, NFTCore>,
    WalletNetwork<NetworkCoinParams<PROVIDER>>,
    NetworkClient<ChainAccount<dynamic, TokenCore, NFTCore>, PROVIDER>>;

typedef APPCHAINNETWORK<NETWORKADDRESS> = Chain<
    APIProvider,
    NetworkCoinParams<APIProvider>,
    NETWORKADDRESS,
    TokenCore,
    NFTCore,
    ChainAccount<NETWORKADDRESS, TokenCore, NFTCore>,
    WalletNetwork<NetworkCoinParams<APIProvider>>,
    NetworkClient<ChainAccount<NETWORKADDRESS, TokenCore, NFTCore>,
        APIProvider>>;

typedef APPCHAINACCOUNT<CHAINACCOUNT extends ChainAccount> = Chain<
    APIProvider,
    NetworkCoinParams<APIProvider>,
    dynamic,
    TokenCore,
    NFTCore,
    CHAINACCOUNT,
    WalletNetwork<NetworkCoinParams<APIProvider>>,
    NetworkClient<CHAINACCOUNT, APIProvider>>;
typedef APPCHAIN = Chain<
    APIProvider,
    NetworkCoinParams<APIProvider>,
    dynamic,
    TokenCore,
    NFTCore,
    ChainAccount<dynamic, TokenCore, NFTCore>,
    WalletNetwork<NetworkCoinParams<APIProvider>>,
    NetworkClient<ChainAccount<dynamic, TokenCore, NFTCore>, APIProvider>>;
typedef APPCHAINTOKEN<TOKEN extends TokenCore> = Chain<
    APIProvider,
    NetworkCoinParams<APIProvider>,
    dynamic,
    TOKEN,
    NFTCore,
    ChainAccount<dynamic, TOKEN, NFTCore>,
    WalletNetwork<NetworkCoinParams<APIProvider>>,
    NetworkClient<ChainAccount<dynamic, TOKEN, NFTCore>, APIProvider>>;

typedef APPCHAINNFT<NFT extends NFTCore> = Chain<
    APIProvider,
    NetworkCoinParams<APIProvider>,
    dynamic,
    TokenCore,
    NFT,
    ChainAccount<dynamic, TokenCore, NFT>,
    WalletNetwork<NetworkCoinParams<APIProvider>>,
    NetworkClient<ChainAccount<dynamic, TokenCore, NFT>, APIProvider>>;

abstract class Chain<
    PROVIDER extends APIProvider,
    NETWORKPARAMS extends NetworkCoinParams<APIProvider>,
    NETWORKADDRESS,
    CHAINTOKEN extends TokenCore,
    NFT extends NFTCore,
    ADDRESS extends ChainAccount<NETWORKADDRESS, CHAINTOKEN, NFT>,
    NETWORK extends WalletNetwork<NETWORKPARAMS>,
    CLIENT extends NetworkClient<ADDRESS, PROVIDER>> with CborSerializable {
  final NETWORK network;
  CLIENT? _client;
  List<ADDRESS> _addresses;
  int _addressIndex;
  final Live<IntegerBalance> totalBalance;
  late final List<String> services = List.unmodifiable(_services(network));
  List<ContactCore<NETWORKADDRESS>> _contacts;
  List<ADDRESS> get addresses => _addresses;
  bool get haveAddress => addresses.isNotEmpty;
  List<ContactCore<NETWORKADDRESS>> get contacts => _contacts;
  ADDRESS get address => addresses.elementAt(_addressIndex);
  final String id;

  factory Chain.deserialize(
      {String? id, String? hex, CborObject? obj, List<int>? bytes}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: obj, hex: hex, tags: CborTagsConst.iAccount);
    final int networkId = values.elementAt(0);
    WalletNetwork? network = MethodUtils.nullOnException(
        () => WalletNetwork.fromCborBytesOrObject(obj: values.getCborTag(6)));
    network = ChainConst.updateNetwork(networkId: networkId, network: network);
    final provider = MethodUtils.nullOnException(() {
      return APIProvider.fromCborBytesOrObject(network!,
          obj: values.getCborTag(7));
    });
    final String walletId = values.elementAt<String>(8);
    return Chain._fromNetwork(
        network: network, values: values, provider: provider, id: walletId);
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
      case NetworkType.polkadot:
      case NetworkType.kusama:
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
      default:
        throw UnimplementedError("network does not eixst. ");
    }
  }

  factory Chain._fromNetwork({
    required WalletNetwork network,
    required CborListValue values,
    required String id,
    APIProvider? provider,
  }) {
    final Chain chain;
    switch (network.type) {
      case NetworkType.bitcoinCash:
      case NetworkType.bitcoinAndForked:
        chain = BitcoinChain.deserialize(
            network: network.toNetwork(),
            cbor: values,
            client: APIUtils.createApiClient(network, service: provider),
            id: id);
        break;
      case NetworkType.polkadot:
      case NetworkType.kusama:
        chain = SubstrateChain.deserialize(
            network: network.toNetwork(),
            cbor: values,
            id: id,
            client: APIUtils.createApiClient(network, service: provider));
        break;
      case NetworkType.ethereum:
        chain = EthereumChain.deserialize(
            network: network.toNetwork(),
            cbor: values,
            id: id,
            client: APIUtils.createApiClient(network, service: provider));
        break;
      case NetworkType.cosmos:
        chain = CosmosChain.deserialize(
            network: network.toNetwork(),
            cbor: values,
            id: id,
            client: APIUtils.createApiClient(network, service: provider));
        break;
      case NetworkType.ton:
        chain = TheOpenNetworkChain.deserialize(
            network: network.toNetwork(),
            cbor: values,
            id: id,
            client: APIUtils.createApiClient(network, service: provider));
        break;
      case NetworkType.tron:
        chain = TronChain.deserialize(
            network: network.toNetwork(),
            cbor: values,
            id: id,
            client: APIUtils.createApiClient(network, service: provider));
        break;
      case NetworkType.xrpl:
        chain = RippleChain.deserialize(
            network: network.toNetwork(),
            cbor: values,
            id: id,
            client: APIUtils.createApiClient(network, service: provider));
        break;
      case NetworkType.solana:
        chain = SolanaChain.deserialize(
            network: network.toNetwork(),
            cbor: values,
            id: id,
            client: APIUtils.createApiClient(network, service: provider));
        break;
      case NetworkType.stellar:
        chain = StellarChain.deserialize(
            network: network.toNetwork(),
            cbor: values,
            id: id,
            client: APIUtils.createApiClient(network, service: provider));
        break;

      case NetworkType.cardano:
        chain = ADAChain.deserialize(
            network: network.toNetwork(),
            cbor: values,
            id: id,
            client: APIUtils.createApiClient(network, service: provider));
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
      List<ADDRESS> addresses = const [],
      List<ContactCore<NETWORKADDRESS>> contacts = const [],
      required int addressIndex,
      required CLIENT? client})
      : _addresses = addresses.imutable,
        _addressIndex = addressIndex,
        _contacts = contacts.imutable,
        _client = client;

  Chain copyWith(
      {NETWORK? network,
      Live<IntegerBalance>? totalBalance,
      List<ADDRESS>? addresses,
      List<ContactCore<NETWORKADDRESS>>? contacts,
      int? addressIndex,
      String? id});

  AddressDerivationIndex nextDerive(
      CryptoCoins coin, SeedTypes seedGeneration) {
    return BipDerivationUtils.generateAccountNextKeyIndex(
        coin: coin,
        addresses: addresses,
        seedGenerationType: seedGeneration,
        coinType: network.coinParam.bip32CoinType);
  }

  ADDRESS addNewAddress(
      List<int> publicKey, NewAccountParams<NETWORKADDRESS> accountParams) {
    if (!network.coins.contains(accountParams.coin)) {
      throw WalletExceptionConst.invalidCoin;
    }
    final ChainAccount<NETWORKADDRESS, TokenCore, NFTCore> newAddress =
        accountParams.toAccount(network, publicKey);
    if (newAddress is! ADDRESS) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
    final any = addresses.any((element) => element.isEqual(newAddress));
    if (any) {
      throw WalletExceptionConst.addressAlreadyExist;
    }
    _addresses = List.unmodifiable([..._addresses, newAddress]);
    return newAddress;
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          network.value,
          CborListValue.fixedLength(addresses.map((e) => e.toCbor()).toList()),
          const CborNullValue(),
          CborListValue.fixedLength(contacts.map((e) => e.toCbor()).toList()),
          totalBalance.value.balance,
          _addressIndex,
          network.toCbor(),
          _client?.service.provider.toCbor(),
          id
        ]),
        CborTagsConst.iAccount);
  }

  ADDRESS? getAddress(String address) {
    return MethodUtils.nullOnException(() => _addresses
        .firstWhere((element) => element.address.toAddress == address));
  }

  ContactCore<NETWORKADDRESS>? getContact(String address) {
    return MethodUtils.nullOnException(() {
      return _contacts.firstWhere((element) {
        return element.address == address;
      });
    });
  }

  ReceiptAddress<NETWORKADDRESS>? getReceiptAddress(String address) {
    final isAccount = getAddress(address);
    if (isAccount != null) {
      return ReceiptAddress<NETWORKADDRESS>(
          account: isAccount,
          view: isAccount.address.toAddress,
          type: isAccount.type,
          networkAddress: isAccount.networkAddress);
    }
    final contact = getContact(address);
    if (contact != null) {
      return ReceiptAddress<NETWORKADDRESS>(
          contact: contact,
          view: contact.address,
          type: contact.type,
          networkAddress: contact.addressObject);
    }
    return null;
  }

  void refreshTotalBalance() {
    Map<String, BigInt> total = {
      for (final i in addresses) i.orginalAddress: i.address.currencyBalance
    };
    final totalBalances = total.values
        .fold(BigInt.zero, (previousValue, element) => previousValue + element);
    totalBalance.value.updateBalance(totalBalances);
  }

  List<CHAINTOKEN> tokens() {
    return addresses.map((e) => e.tokens).expand((e) => e).toList();
  }

  static List<String> _services(WalletNetwork network) {
    switch (network.type) {
      case NetworkType.xrpl:
        return ["services", "tokens"];
      case NetworkType.tron:
        return ["services", "trc20_tokens", "trc10_tokens"];
      case NetworkType.ethereum:
        return ["tokens"];
      case NetworkType.solana:
        return ["services", "tokens"];
      case NetworkType.ton:
        return ["services", "jettons"];
      case NetworkType.stellar:
        return ["services", "tokens"];
      default:
        return ["services"];
    }
  }

  CLIENT? provider() {
    return _client;
  }

  void disposeProvider() {
    _client?.service.tracker.notify();
    _client?.service.disposeService();
  }

  void initProvider() {
    _client?.service.tracker.notify();
    _client?.init();
  }

  void addContact(ContactCore<NETWORKADDRESS> newContact) {
    final validate = MethodUtils.nullOnException(() {
      if (newContact.name.length < 3) return null;
      return ContactCore.newContact(
          network: network,
          address: newContact.addressObject,
          name: newContact.name);
    });
    if (validate == null || validate.address != newContact.address) {
      throw WalletExceptionConst.invalidContactDetails;
    }
    final exist = getContact(newContact.address);
    if (exist != null) {
      throw WalletExceptionConst.contactExists;
    }
    _contacts = List.unmodifiable([newContact, ..._contacts]);
  }

  void removeContact(ContactCore<NETWORKADDRESS> contact) {
    final findContact = getContact(contact.address);
    if (findContact == null) return;
    final newContacts =
        _contacts.where((element) => element != findContact).toList();
    _contacts = List.unmodifiable(newContacts);
  }

  void switchAccount(ADDRESS address) {
    final index = addresses.indexOf(address);
    if (index < 0 || index == _addressIndex) return;
    _addressIndex = index;
  }

  bool removeAccount(ADDRESS address) {
    if (!haveAddress || !addresses.contains(address)) {
      return false;
    }
    final currentAddress = address;
    final currentAccounts = List<ADDRESS>.from(_addresses);
    currentAccounts.remove(address);
    _addresses = currentAccounts;
    _addressIndex = _addresses.indexOf(currentAddress);
    if (_addressIndex < 0) {
      _addressIndex = 0;
    }
    refreshTotalBalance();
    return true;
  }

  void setProvider(PROVIDER service, {Duration? requestTimeout}) {
    final currentProvider = _client;
    _client = APIUtils.createApiClient<CLIENT>(network,
        service: service, requestTimeut: requestTimeout);
    currentProvider?.service.tracker.notify();
    currentProvider?.service.disposeService();
    initProvider();
  }

  CLIENT? getWeb3Provider({PROVIDER? service, Duration? requestTimeout}) {
    final cl = _client;
    if (cl?.service.provider.allowInWeb3 ?? false) return cl;
    return APIUtils.createApiClient<CLIENT>(
      network,
      service: service,
      requestTimeut: requestTimeout,
      allowInWeb3: true,
    );
  }

  T cast<T extends APPCHAIN>() {
    if (this is! T) {
      throw WalletExceptionConst.invalidArgruments("$runtimeType", "$T");
    }
    return this as T;
  }

  String get storageId =>
      "${StorageConst.walletStorageKey}${id}_${network.value.toString()}";
}
