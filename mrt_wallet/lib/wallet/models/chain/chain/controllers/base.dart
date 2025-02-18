part of 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';

mixin BaseChainController<
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
    on
        BaseChain<PROVIDER, NETWORKPARAMS, NETWORKADDRESS, CHAINTOKEN, NFT,
            ADDRESS, NETWORK, CLIENT, STORAGE, CONFIG, TRANSACTION>,
        ChainStorageManager<NETWORK, STORAGE, CONFIG> {
  @override
  late final List<String> services = ChainConst.services(network);
  void updateConfig(CONFIG status) {
    _config.value = status;
    _config.notify();
  }

  void hideStatus() {}

  AddressDerivationIndex nextDerive(
      CryptoCoins coin, SeedTypes seedGeneration) {
    return BipDerivationUtils.generateAccountNextKeyIndex(
        coin: coin,
        addresses: addresses,
        seedGenerationType: seedGeneration,
        coinType: network.coinParam.bip32CoinType);
  }

  Future<ADDRESS> addNewAddress(CryptoPublicKeyData? publicKey,
      NewAccountParams<NETWORKADDRESS> accountParams) async {
    return _lock.synchronized(() {
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
    });
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
    final contact = getContact(address);
    if (isAccount != null) {
      return ReceiptAddress<NETWORKADDRESS>(
          account: isAccount,
          view: isAccount.address.toAddress,
          type: isAccount.type,
          networkAddress: isAccount.networkAddress,
          contact: contact);
    }

    if (contact != null) {
      return ReceiptAddress<NETWORKADDRESS>(
          contact: contact,
          view: contact.address,
          type: contact.type,
          networkAddress: contact.addressObject);
    }
    return null;
  }

  void _refreshTotalBalance() {
    final Map<String, BigInt> total = {
      for (final i in addresses) i.orginalAddress: i.address.currencyBalance
    };
    final totalBalances = total.values
        .fold(BigInt.zero, (previousValue, element) => previousValue + element);
    totalBalance.value.updateBalance(totalBalances);
  }

  List<CHAINTOKEN> tokens() {
    return addresses.map((e) => e.tokens).expand((e) => e).toList();
  }

  CLIENT get client {
    if (_client == null) {
      throw WalletExceptionConst.noActiveProvider;
    }
    return _client!;
  }

  CLIENT? get clientNullable {
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

  Future<bool> removeAccount(ADDRESS address) async {
    return _lock.synchronized(() {
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
      _refreshTotalBalance();
      return true;
    });
  }

  Future<void> setProvider(ProviderIdentifier service,
      {Duration? requestTimeout}) async {
    if (service.network != network.type) return;
    final currentProvider = _client;
    _client = APIUtils.createApiClient<CLIENT>(network,
        identifier: service, requestTimeut: requestTimeout);
    currentProvider?.service.tracker.notify();
    currentProvider?.service.disposeService();
    initProvider();
    await save();
  }

  CLIENT? getWeb3Provider(
      {ProviderIdentifier? service, Duration? requestTimeout}) {
    final cl = _client;
    if (cl?.service.provider.allowInWeb3 ?? false) return cl;
    return APIUtils.createApiClient<CLIENT>(network,
        identifier: service,
        requestTimeut: requestTimeout,
        allowInWeb3: true,
        isolate: APPIsolate.current);
  }

  T cast<T extends APPCHAIN>() {
    if (this is! T) {
      throw WalletExceptionConst.invalidArgruments("$runtimeType", "$T");
    }
    return this as T;
  }

  void updateAddressBalance(
      {required ADDRESS address, required BigInt? updateBalance}) {
    if (updateBalance == null) return;
    if (!addresses.contains(address)) return;
    address.address.updateAddressBalance(updateBalance);
    _refreshTotalBalance();
  }

  Future<MRTWalletChainBackup> toBackup() async {
    final repositoies = await _readAllRepositories();
    return MRTWalletChainBackup(
        chain: this as Chain, repositories: repositoies);
  }

  Future<void> save() async {
    await _save();
  }

  Future<WalletAccountTransactions<TRANSACTION>> getTransactions(
      ADDRESS address) async {
    throw UnimplementedError();
  }

  Future<void> saveTransaction(
      {required ADDRESS address, required TRANSACTION transaction}) async {
    throw UnimplementedError();
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
          const CborNullValue(),
          id,
          config.toCbor(),
          _client?.serviceIdentifier.toCbor()
        ]),
        CborTagsConst.iAccount);
  }

  Future<void> init() async {
    initProvider();
  }
}
