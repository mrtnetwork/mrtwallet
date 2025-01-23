import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:monero_dart/monero_dart.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/worker.dart';
import 'package:mrt_wallet/wallet/constant/networks/monero.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/wallet/models/balance/balance.dart';
import 'package:mrt_wallet/wallet/models/chain/address/creation_params/core/core.dart';
import 'package:mrt_wallet/wallet/models/network/core/network.dart';
import 'package:mrt_wallet/wallet/models/others/models/receipt_address.dart';

enum MoneroBlockTrackingStatus {
  failed(1),
  success(2),
  pending(3);

  final int value;
  const MoneroBlockTrackingStatus(this.value);
  static MoneroBlockTrackingStatus fromValue(int? value) {
    return values.firstWhere((e) => e.value == value,
        orElse: () => throw WalletExceptionConst.dataVerificationFailed);
  }

  bool get isFailed => this == failed;
  bool get isSuccess => this == success;
}

enum MoneroParsingBlockStatus {
  failed(1),
  noBlock(2),
  success(3);

  final int value;
  const MoneroParsingBlockStatus(this.value);
  static MoneroParsingBlockStatus fromValue(int? value) {
    return values.firstWhere((e) => e.value == value,
        orElse: () => throw WalletExceptionConst.dataVerificationFailed);
  }

  bool get isFailed => this == failed;
}

class MoneroBlockTrackingPossition with CborSerializable, Equatable {
  /// current height
  final int blockHeight;
  final int startHeight;
  final int endHeight;
  final MoneroBlockTrackingStatus status;
  int get offset => startHeight - blockHeight;
  int get totalRange => endHeight - startHeight;

  MoneroBlockTrackingPossition updateStatus(MoneroBlockTrackingStatus status) {
    assert(this.status == MoneroBlockTrackingStatus.pending, "invalid status");
    return MoneroBlockTrackingPossition(
        startHeight: startHeight,
        endHeight: endHeight,
        blockHeight: blockHeight,
        status: status);
  }

  const MoneroBlockTrackingPossition._({
    required this.startHeight,
    required this.endHeight,
    required this.status,
    required this.blockHeight,
  });
  factory MoneroBlockTrackingPossition(
      {required int startHeight,
      required int endHeight,
      required int blockHeight,
      required MoneroBlockTrackingStatus status}) {
    if (startHeight.isNegative || startHeight > endHeight) {
      throw WalletExceptionConst.dataVerificationFailed;
    }
    return MoneroBlockTrackingPossition._(
        startHeight: startHeight,
        endHeight: endHeight,
        status: status,
        blockHeight: blockHeight);
  }
  factory MoneroBlockTrackingPossition.deserialize(
      {List<int>? bytes, CborObject? cbor, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: cbor,
        hex: hex,
        tags: CborTagsConst.moneroChainTrackedOffsets);
    return MoneroBlockTrackingPossition(
        startHeight: values.elementAs(0),
        endHeight: values.elementAs(1),
        status: MoneroBlockTrackingStatus.fromValue(values.elementAs(2)),
        blockHeight: values.elementAs(3));
  }
  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [startHeight, endHeight, status.value, blockHeight]),
        CborTagsConst.moneroChainTrackedOffsets);
  }

  @override
  String toString() {
    return {'start': startHeight, 'end': endHeight, 'status': status.name}
        .toString();
  }

  @override
  List get variabels => [startHeight, endHeight];
}

enum MoneroAccountBlocksTrackerStatus {
  paused(0),
  synced(1),
  pending(2);

  bool get inProcess => this == pending;
  bool get isSynced => this == synced;

  final int value;
  const MoneroAccountBlocksTrackerStatus(this.value);
  static MoneroAccountBlocksTrackerStatus fromValue(int? value) {
    return values.firstWhere((e) => e.value == value,
        orElse: () => throw WalletExceptionConst.invalidData(
            messsage: "block tracker status does not exists."));
  }
}

class MoneroAccountBlocksTracker with CborSerializable {
  Set<MoneroSyncAccountsInfos> _accounts;
  Set<MoneroSyncAccountsInfos> get accounts => _accounts;
  MoneroAccountBlocksTrackerStatus _status;
  MoneroAccountBlocksTrackerStatus get status => _status;
  final DateTime created;
  int _startHeight;
  int get startHeight => _startHeight;
  int _endHeight;
  int get endHeight => _endHeight;
  int _currentHeight;
  int get currentHeight => _currentHeight;
  final bool isRequest;
  List<MoneroBlockTrackingPossition> _failedOffsets;
  List<MoneroBlockTrackingPossition> get failedOffsets => _failedOffsets;
  List<MoneroBlockTrackingPossition> _currentOffsets;
  List<MoneroBlockTrackingPossition> get currentOffsets =>
      _currentOffsets.clone();

  List<MoneroAccountPendingTxes> getAccountsPendingTxes() {
    final List<MoneroAccountPendingTxes> accounts = [];
    for (final i in this.accounts) {
      if (i.pendingTxes.isEmpty) continue;
      accounts.add(MoneroAccountPendingTxes(
          primaryAddress: i.primaryAccount, txIDs: i.pendingTxes));
    }
    return accounts;
  }

  List<MoneroBlockTrackingPossition> _getCurrentOffsets() {
    return _currentOffsets
        .where((e) => e.status == MoneroBlockTrackingStatus.pending)
        .toList();
  }

  static const int failedBlockSkip = 100;

  void _handleErrorOffsets(MoneroBlocksInfoResponse response) {
    _currentOffsets = [];
    int nextStep = _currentHeight + failedBlockSkip;
    if (nextStep > _endHeight) {
      nextStep = _endHeight;
    }
    final failedOffset = MoneroBlockTrackingPossition(
        startHeight: _currentHeight,
        endHeight: nextStep,
        blockHeight: _currentHeight,
        status: MoneroBlockTrackingStatus.failed);
    _failedOffsets = [..._failedOffsets, failedOffset];
    _currentHeight = nextStep;
    _checkStatus();
  }

  void _handleSucessBlockResponse(MoneroBlocksInfoResponse response) {
    if (_currentOffsets.isEmpty) {
      buildOffsets(response.totalBlock);
    } else {
      if (_currentOffsets.last.endHeight - _currentOffsets.first.startHeight >
          response.totalBlock) {
        final cloneOffsets = _currentOffsets.clone();
        buildOffsets(response.totalBlock);
        for (final i in cloneOffsets) {
          if (i.status.isSuccess) {
            final item = _currentOffsets.indexOf(i);
            if (item >= 0) {
              _currentOffsets[item] = i;
            }
          }
        }
      }
    }
  }

  MoneroSyncBlocksRequest validatePossitions(
      MoneroBlocksInfoResponse response) {
    assert(_status == MoneroAccountBlocksTrackerStatus.pending,
        "wrong tracker status $_status");
    if (synced) return MoneroSyncTrackBlocksRequest(blockPossitions: []);
    assert(response.status != MoneroParsingBlockStatus.noBlock,
        "should not be happend.");
    switch (response.status) {
      case MoneroParsingBlockStatus.failed:
        _handleErrorOffsets(response);
        if (synced) {
          return MoneroSyncTrackBlocksRequest(blockPossitions: []);
        }
        return MoneroSyncBlocksInfoRequest(height: currentHeight);
      case MoneroParsingBlockStatus.success:
        _handleSucessBlockResponse(response);
        final offsets = _getCurrentOffsets();
        return MoneroSyncTrackBlocksRequest(blockPossitions: offsets);
      default:
        return MoneroSyncTrackBlocksRequest(blockPossitions: []);
    }
  }

  static const int maxBlock = 100;
  static const int maxOffset = 10;

  List<MoneroBlockTrackingPossition> buildOffsets(int totalLength) {
    if (synced) return [];
    final List<MoneroBlockTrackingPossition> newOffsets = [];
    int h = currentHeight + totalLength;
    if (h > endHeight) {
      h = endHeight;
    }
    int start = currentHeight;
    while (start <= h) {
      final offset = MoneroBlockTrackingPossition(
          startHeight: start,
          endHeight: start + maxBlock > h ? h : start + maxBlock,
          status: MoneroBlockTrackingStatus.pending,
          blockHeight: currentHeight);
      newOffsets.add(offset);
      start += maxBlock;
      if (newOffsets.length >= maxOffset) break;
    }
    _currentOffsets = newOffsets;
    return _currentOffsets;
  }

  void _checkOffsets() {
    final bool offsetsComplete = _currentOffsets
        .every((e) => e.status != MoneroBlockTrackingStatus.pending);
    if (!offsetsComplete || _currentOffsets.isEmpty) return;
    final failed = _currentOffsets.where((e) => e.status.isFailed);
    _failedOffsets = [...failed, ..._failedOffsets].immutable;
    _currentHeight = _currentOffsets.last.endHeight;
    _currentOffsets = [];
    _checkStatus();
  }

  bool updateOffset(MoneroBlockTrackingPossition offset) {
    assert(_currentOffsets.contains(offset), "invalid offset");
    assert(offset.status != MoneroBlockTrackingStatus.pending,
        "invalid offset status");
    if (!_currentOffsets.contains(offset)) return false;
    final currentOffset = _currentOffsets.indexOf(offset);
    assert(currentOffset >= 0, "index not found!");
    _currentOffsets[currentOffset] = offset;
    _checkOffsets();
    return true;
  }

  void updateHeight(int endHeight) {
    assert(!isRequest, "cannot update sync request.");
    if (isRequest) return;
    if (isStart) {
      if (_accounts.isEmpty) return;
      _setStartHeight(endHeight - 1000);
    }
    assert(endHeight >= this.endHeight, "invalid height.");
    if (this.endHeight == endHeight) {
      return;
    }

    _endHeight = endHeight;
    _checkOffsets();
    _checkStatus();
  }

  bool get synced => _status.isSynced;
  bool get hasPendingTxes {
    return _accounts.any((e) => e.pendingTxes.isNotEmpty);
  }

  void _checkStatus() {
    if (_currentHeight >= endHeight) {
      assert(_currentHeight == endHeight, "must be equal");
      _status = MoneroAccountBlocksTrackerStatus.synced;
    } else if (!isRequest) {
      _status = MoneroAccountBlocksTrackerStatus.pending;
    }
  }

  MoneroAccountBlocksTracker.start()
      : _accounts = {},
        _startHeight = 0,
        _endHeight = 0,
        _failedOffsets = [],
        isRequest = false,
        _currentOffsets = [],
        _currentHeight = 0,
        created = DateTime.now(),
        _status = MoneroAccountBlocksTrackerStatus.pending;
  bool get isStart => _startHeight == 0;

  MoneroAccountBlocksTracker.__({
    List<MoneroSyncAccountsInfos> accounts = const [],
    required List<MoneroBlockTrackingPossition> failedOffsets,
    required List<MoneroBlockTrackingPossition> currentOffsets,
    required int startHeight,
    required int endHeight,
    required int currentHeight,
    required this.created,
    required this.isRequest,
    required MoneroAccountBlocksTrackerStatus status,
  })  : _accounts = accounts.toImutableSet,
        _failedOffsets = failedOffsets.immutable,
        _endHeight = endHeight,
        _startHeight = startHeight,
        _currentOffsets = currentOffsets.clone(),
        _currentHeight = currentHeight,
        _status = status;
  factory MoneroAccountBlocksTracker(
      {List<MoneroSyncAccountsInfos> accounts = const [],
      required int startHeight,
      required int endHeight,
      required bool isRequest,
      required List<MoneroBlockTrackingPossition> failedOffsets,
      required List<MoneroBlockTrackingPossition> currentOffsets,
      required int currentHeight,
      required DateTime created,
      required MoneroAccountBlocksTrackerStatus status}) {
    return MoneroAccountBlocksTracker.__(
        accounts: accounts,
        startHeight: startHeight,
        endHeight: endHeight,
        isRequest: isRequest,
        failedOffsets: failedOffsets,
        currentOffsets: currentOffsets,
        currentHeight: currentHeight,
        created: created,
        status: status);
  }
  factory MoneroAccountBlocksTracker.sync(
      {List<MoneroSyncAccountsInfos> accounts = const [],
      required int startHeight,
      required int endHeight}) {
    if (accounts.isEmpty ||
        startHeight.isNegative ||
        startHeight >= endHeight) {
      throw WalletExceptionConst.dataVerificationFailed;
    }

    return MoneroAccountBlocksTracker(
        accounts: accounts,
        startHeight: startHeight,
        endHeight: endHeight,
        isRequest: true,
        failedOffsets: [],
        currentOffsets: [],
        currentHeight: startHeight,
        created: DateTime.now(),
        status: MoneroAccountBlocksTrackerStatus.pending);
  }

  factory MoneroAccountBlocksTracker.deserialize(
      {List<int>? bytes, CborObject? cbor, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: cbor,
        hex: hex,
        tags: CborTagsConst.moneroSyncRequestChainTracker);
    return MoneroAccountBlocksTracker(
        accounts: values
            .elementAsListOf<CborTagValue>(0)
            .map((e) => MoneroSyncAccountsInfos.deserialize(cbor: e))
            .toList(),
        startHeight: values.elementAs(1),
        endHeight: values.elementAs(2),
        isRequest: values.elementAs(3),
        failedOffsets: values
            .elementAsListOf<CborTagValue>(4)
            .map((e) => MoneroBlockTrackingPossition.deserialize(cbor: e))
            .toList(),
        currentOffsets: values
            .elementAsListOf<CborTagValue>(5)
            .map((e) => MoneroBlockTrackingPossition.deserialize(cbor: e))
            .toList(),
        currentHeight: values.elementAs(6),
        created: values.elementAs(7),
        status:
            MoneroAccountBlocksTrackerStatus.fromValue(values.elementAs(8)));
  }

  List<MoneroAccountKeys> getAccountsKeys() {
    return List.generate(accounts.length, (i) {
      final account = accounts.elementAt(i);
      return account.getAccountKeys();
    });
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborListValue.fixedLength(accounts.map((e) => e.toCbor()).toList()),
          startHeight,
          endHeight,
          isRequest,
          CborListValue.fixedLength(
              _failedOffsets.map((e) => e.toCbor()).toList()),
          CborListValue.fixedLength(
              _currentOffsets.map((e) => e.toCbor()).toList()),
          currentHeight,
          created,
          status.value
        ]),
        CborTagsConst.moneroSyncRequestChainTracker);
  }

  void addSyncedAccountsPaymentTx(Iterable<MoneroSyncAccountsInfos> accounts) {
    for (final i in accounts) {
      final account = _accounts.firstWhereOrNull((e) => e == i);
      assert(account != null, "account does not exist.");
      account?.addPendingTx(i.pendingTxes);
    }
  }

  void addPendingTx(MoneroAccountPendingTxes tx) {
    for (final i in accounts) {
      if (i.primaryAccount == tx.primaryAddress) {
        i.addPendingTx(tx.txIDs);
        break;
      }
    }
  }

  MoneroSyncAccountsInfos getAccountInfo(
      MoneroViewPrimaryAccountDetails primaryAccount) {
    return _accounts.firstWhere((e) => e.primaryAccount == primaryAccount);
  }

  void removePendingTxes(Iterable<MoneroSyncAccountsInfos> accounts) {
    for (final i in accounts) {
      final account = _accounts.firstWhereOrNull((e) => e == i);
      assert(account != null, "account does not exist.");
      account?.removeTxes(i.pendingTxes);
    }
  }

  void _setStartHeight(int height) {
    assert(!isRequest, "cannot update sync request.");
    assert(isStart, "default tracker already set starts.");
    assert(height > 0, "invalid height.");
    if (isRequest || !isStart || height <= 0) return;
    _startHeight = height;
    _endHeight = height;
    _currentHeight = height;
    _checkStatus();
    for (final i in _accounts) {
      i.updateStartHeights(_currentHeight);
    }
  }

  void addAccount(MoneroViewAccountDetails account) {
    final primaryAccount = account.primaryAccount();
    MoneroSyncAccountsInfos? syncAccount =
        accounts.firstWhereNullable((e) => e.primaryAccount == primaryAccount);
    if (syncAccount == null) {
      syncAccount = MoneroSyncAccountsInfos(primaryAccount: primaryAccount);
      _accounts = {..._accounts, syncAccount}.toImutableSet;
    }
    syncAccount.addIndex(MoneroSyncAccountIndexInfo(
        index: account.index, startHeight: currentHeight));
  }

  void removeAccount(
      {required MoneroViewPrimaryAccountDetails account,
      required MoneroAccountIndex index}) {
    final MoneroSyncAccountsInfos? syncAccount =
        accounts.firstWhereNullable((e) => e.primaryAccount == account);
    if (syncAccount == null) return;
    syncAccount.removeIndex(index);
    if (syncAccount.indexes.isEmpty) {
      _accounts =
          _accounts.where((e) => e.primaryAccount != account).toImutableSet;
    }
  }

  MoneroSyncBlocksRequest? getCurrentRequest() {
    if (synced || _currentOffsets.isNotEmpty) return null;
    return MoneroSyncBlocksInfoRequest(height: currentHeight);
  }

  MoneroSyncBlocksRequest? getHeightRequest() {
    if (synced || isStart) return null;
    return MoneroSyncBlocksInfoRequest(height: currentHeight);
  }

  void updateStatus(MoneroAccountBlocksTrackerStatus status) {
    assert(_status != MoneroAccountBlocksTrackerStatus.synced,
        "tracker already synced.");
    if (_status == MoneroAccountBlocksTrackerStatus.synced) {
      return;
    }
    _status = status;
  }

  @override
  String toString() {
    return {
      "offsets": _currentOffsets,
      "error": _failedOffsets,
      "height": _currentHeight,
      "start_height": startHeight,
      "end_height": endHeight
    }.toString();
  }
}

class MoneroSyncRequests with CborSerializable {
  List<MoneroAccountBlocksTracker> _requests;
  List<MoneroAccountBlocksTracker> get requests => _requests;

  List<MoneroAccountBlocksTracker> pendingRequests() {
    return _requests.where((e) => e.status.inProcess).toList();
  }

  void addSyncRequest(MoneroAccountBlocksTracker request) {
    if (!request.isRequest) return;
    if (request.startHeight.isNegative) {
      throw WalletExceptionConst.dataVerificationFailed;
    }
    _requests = [..._requests, request]
      ..sort((a, b) => a.created.compareTo(b.created));
    _requests = _requests.toImutableList;
  }

  MoneroSyncRequests(List<MoneroAccountBlocksTracker> request)
      : _requests = request.immutable;
  factory MoneroSyncRequests.deserialize(
      {List<int>? bytes, CborObject? cbor, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: cbor,
        hex: hex,
        tags: CborTagsConst.moneroSyncTrackersRequests);
    return MoneroSyncRequests(values
        .elementAsListOf<CborTagValue>(0)
        .map((e) => MoneroAccountBlocksTracker.deserialize(cbor: e))
        .toList());
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborListValue.fixedLength(_requests.map((e) => e.toCbor()).toList())
        ]),
        CborTagsConst.moneroSyncTrackersRequests);
  }
}

class MoneroChainAccountTranckerInfo with CborSerializable {
  final DateTime updateTime;
  final List<int> fetchedBlock;

  MoneroChainAccountTranckerInfo(
      {required this.updateTime, required List<int> fetchedBlock})
      : fetchedBlock = fetchedBlock.immutable;
  factory MoneroChainAccountTranckerInfo.create() {
    return MoneroChainAccountTranckerInfo(
        updateTime: DateTime.now(), fetchedBlock: []);
  }
  factory MoneroChainAccountTranckerInfo.deserialize(
      {List<int>? bytes, CborObject? cbor, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: cbor,
        hex: hex,
        tags: CborTagsConst.moneroChainTrackerInfo);
    return MoneroChainAccountTranckerInfo(
        updateTime: values.elementAs(0),
        fetchedBlock: values
            .elementAsListOf<CborIntValue>(1)
            .map((e) => e.value)
            .toList());
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborEpochIntValue(updateTime),
          CborListValue.fixedLength(
              fetchedBlock.map((e) => CborIntValue(e)).toList())
        ]),
        CborTagsConst.moneroChainTrackerInfo);
  }
}

class MoneroViewPrimaryAccountDetails with CborSerializable, Equatable {
  final List<int> viewPrivateKey;
  final List<int> spendPublicKey;
  final MoneroNetwork network;
  late final account = MoneroAccount.fromWatchOnly(
      viewPrivateKey, spendPublicKey,
      coinType: network.coin);
  late final primaryAddress = MoneroAccountAddress(account.primaryAddress,
      network: network, type: XmrAddressType.primaryAddress);
  MoneroViewPrimaryAccountDetails._(
      {required List<int> viewPrivateKey,
      required List<int> spendPublicKey,
      required this.network})
      : viewPrivateKey = viewPrivateKey.asImmutableBytes,
        spendPublicKey = spendPublicKey.asImmutableBytes;
  factory MoneroViewPrimaryAccountDetails({
    required MoneroPrivateKey viewPrivateKey,
    required MoneroPublicKey spendPublicKey,
    required MoneroNetwork network,
  }) {
    return MoneroViewPrimaryAccountDetails._(
        viewPrivateKey: viewPrivateKey.key,
        spendPublicKey: spendPublicKey.key,
        network: network);
  }

  factory MoneroViewPrimaryAccountDetails.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: CborTagsConst.moneroViewPrimaryAccountDetails);

    return MoneroViewPrimaryAccountDetails._(
        viewPrivateKey: values.elementAs(0),
        spendPublicKey: values.elementAs(1),
        network: MoneroNetwork.fromIndex(values.elementAs(2)));
  }

  MoneroAddress getPrimaryAddress(MoneroNetwork network) {
    return MoneroAccountAddress.fromPubKeys(
        pubSpendKey: account.pubSkey.key,
        pubViewKey: account.pubVkey.key,
        network: network);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue([
      CborBytesValue(viewPrivateKey),
      CborBytesValue(spendPublicKey),
      network.index
    ], CborTagsConst.moneroViewPrimaryAccountDetails);
  }

  @override
  List get variabels => [viewPrivateKey, spendPublicKey, network];

  @override
  String toString() {
    return primaryAddress.toString();
  }
}

class MoneroViewAccountDetails with Equatable, CborSerializable {
  final MoneroViewPrimaryAccountDetails viewKey;
  final MoneroAccountIndex index;
  bool get isPrimary => !index.isSubaddress;
  bool get isSubAddresss => index.isSubaddress;
  XmrAddressType get addrType =>
      isSubAddresss ? XmrAddressType.subaddress : XmrAddressType.primaryAddress;

  const MoneroViewAccountDetails._(
      {required this.viewKey, required this.index});
  factory MoneroViewAccountDetails(
      {required MoneroViewPrimaryAccountDetails viewKey,
      required int major,
      required int minor}) {
    return MoneroViewAccountDetails._(
        viewKey: viewKey,
        index: MoneroAccountIndex(minor: minor, major: major));
  }
  factory MoneroViewAccountDetails.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: NewAccountParamsType.moneroNewAddressParams.tag);
    final viewKey = MoneroViewPrimaryAccountDetails.deserialize(
        object: values.getCborTag(0));
    return MoneroViewAccountDetails(
      viewKey: viewKey,
      major: values.elementAs(1),
      minor: values.elementAs(2),
    );
  }

  MoneroViewPrimaryAccountDetails primaryAccount() {
    return viewKey;
  }

  MoneroAddress toAddress(WalletMoneroNetwork network) {
    final keys = viewKey.account.scubaddr.computeKeys(index.minor, index.major);
    return MoneroAccountAddress.fromPubKeys(
        pubSpendKey: keys.pubSKey.key,
        pubViewKey: keys.pubVKey.key,
        network: network.coinParam.network,
        type: addrType);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue([viewKey.toCbor(), index.major, index.minor],
        NewAccountParamsType.moneroNewAddressParams.tag);
  }

  @override
  List get variabels => [
        viewKey,
        index.major,
        index.minor,
      ];
}

class MoneroTxInfo with CborSerializable {
  final String txId;
  final String txHex;
  final List<BigInt> globalIndices;
  final int confirmations;
  MoneroTransaction? toTx() {
    return MethodUtils.nullOnException(
        () => MoneroTransaction.deserialize(BytesUtils.fromHexString(txHex)));
  }

  MoneroTxInfo(
      {required String txId,
      required String txHex,
      required List<BigInt> globalIndices,
      required int confirmations})
      : txId = QuickCryptoValidator.asValidHexBytes(txId,
            lengthInBytes: MoneroConst.txHashLength),
        txHex = QuickCryptoValidator.asValidHexBytes(txHex),
        globalIndices = globalIndices.immutable,
        confirmations = confirmations.asInt32;
  factory MoneroTxInfo.deserialize(
      {List<int>? bytes, CborObject? cbor, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: hex,
        object: cbor,
        tags: CborTagsConst.moneroUtxoRequestTxInfo);
    return MoneroTxInfo(
        txId: String.fromCharCodes(values.elementAs(0)),
        txHex: String.fromCharCodes(values.elementAs(1)),
        globalIndices: values
            .elementAsListOf<CborBigIntValue>(2)
            .map((e) => e.value)
            .toList(),
        confirmations: values.elementAs(3));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue([
      CborBytesValue(txId.codeUnits),
      CborBytesValue(txHex.codeUnits),
      CborListValue.fixedLength(globalIndices),
      confirmations
    ], CborTagsConst.moneroUtxoRequestTxInfo);
  }
}

class MoneroTxIDsUnlockOutputResponse with CborSerializable {
  final List<MoneroUnlockedPaymentRequestDetails> payments;
  MoneroTxIDsUnlockOutputResponse(
      List<MoneroUnlockedPaymentRequestDetails> payments)
      : payments = payments.imutable;

  factory MoneroTxIDsUnlockOutputResponse.deserialize(
      {List<int>? bytes, CborObject? obj, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: hex,
        object: obj,
        tags: CborTagsConst.moneroUtxoRequestTxId);
    return MoneroTxIDsUnlockOutputResponse(values
        .elementAsListOf<CborTagValue>(0)
        .map((e) => MoneroUnlockedPaymentRequestDetails.deserialize(cbor: e))
        .toList());
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborListValue.fixedLength(payments.map((e) => e.toCbor()).toList())
        ]),
        CborTagsConst.moneroUtxoRequestTxId);
  }
}

enum MoneroUnlockPaymentRequestStatus {
  success(1),
  error(2);

  const MoneroUnlockPaymentRequestStatus(this.value);

  final int value;
  static MoneroUnlockPaymentRequestStatus fromValue(int? value) {
    return values.firstWhere((e) => e.value == value,
        orElse: () => throw WalletExceptionConst.dataVerificationFailed);
  }

  bool get hasPayment => this == MoneroUnlockPaymentRequestStatus.success;
}

enum MoneroUnlockPaymentRequestOutputStatus {
  unknown(0),
  spent(1),
  unspent(2),
  pool(3);

  const MoneroUnlockPaymentRequestOutputStatus(this.value);

  final int value;
  static MoneroUnlockPaymentRequestOutputStatus fromValue(int? value) {
    return values.firstWhere((e) => e.value == value,
        orElse: () => throw WalletExceptionConst.dataVerificationFailed);
  }

  bool get isUnspent => this == unspent;
  bool get inPool => this == pool;
  bool get isUnknown => this == unknown;
  bool get isSpent => this == spent;
}

class MoneroOutputDetails with CborSerializable, Equatable {
  final MoneroLockedOutput lockedOutput;
  final String txId;
  final String keyImage;
  final IntegerBalance amount;
  MoneroAccountIndex get index => lockedOutput.accountIndex;
  BigInt? _globalIndex;
  BigInt? get globalIndex => _globalIndex;
  bool get hasGlobalIndex => globalIndex != null;
  int _confirmations;
  int? _height;
  int get confirmations => _confirmations;
  int? get height => _height;
  MoneroUnlockPaymentRequestOutputStatus _status;
  MoneroUnlockPaymentRequestOutputStatus get status => _status;
  bool _needUpdate = false;
  bool get needUpdate => _needUpdate;
  void _checkUpdate() {
    _needUpdate = _status.inPool ||
        (_status.isUnspent && (_confirmations < 10 || _globalIndex == null));
  }

  MoneroOutputDetails._({
    required this.txId,
    required this.keyImage,
    required this.lockedOutput,
    BigInt? globalIndex,
    int? confirmations,
    int? height,
    required MoneroUnlockPaymentRequestOutputStatus status,
  })  : _status = status,
        _confirmations = confirmations ?? 0,
        _height = height,
        amount = IntegerBalance(lockedOutput.amount, MoneroConst.decimal,
            allowNegative: false, imutable: true),
        _globalIndex = globalIndex {
    _checkUpdate();
  }
  factory MoneroOutputDetails({
    required String txId,
    required String keyImage,
    required MoneroLockedOutput lockedOut,
    BigInt? globalIndex,
    int? confirmations,
    int? height,
    MoneroUnlockPaymentRequestOutputStatus status =
        MoneroUnlockPaymentRequestOutputStatus.unknown,
  }) {
    return MoneroOutputDetails._(
        txId: QuickCryptoValidator.asValidHexBytes(txId,
            lengthInBytes: MoneroConst.txHashLength),
        keyImage: QuickCryptoValidator.asValidHexBytes(keyImage,
            lengthInBytes: MoneroConst.keyImageLength),
        confirmations: confirmations,
        height: height,
        status: status,
        lockedOutput: lockedOut,
        globalIndex: globalIndex);
  }
  factory MoneroOutputDetails.deserialize(
      {List<int>? bytes, CborObject? cbor, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: hex,
        object: cbor,
        tags: CborTagsConst.moneroUtxoDetails);
    final lockedOut = MoneroLockedOutput.deserialize(values.elementAs(5));
    return MoneroOutputDetails(
        txId: String.fromCharCodes(values.elementAs(0)),
        keyImage: String.fromCharCodes(values.elementAs(1)),
        confirmations: values.elementAs(2),
        height: values.elementAs(3),
        status: MoneroUnlockPaymentRequestOutputStatus.fromValue(
            values.elementAs(4)),
        lockedOut: lockedOut,
        globalIndex: values.elementAs(6));
  }

  void updatePaymentStatus(
      {required DaemonKeyImageSpentStatus status,
      int? confirmations,
      int? height}) {
    switch (status) {
      case DaemonKeyImageSpentStatus.unspent:
        _status = MoneroUnlockPaymentRequestOutputStatus.unspent;
        break;
      case DaemonKeyImageSpentStatus.spentInBlockchain:
        _status = MoneroUnlockPaymentRequestOutputStatus.spent;
        break;
      case DaemonKeyImageSpentStatus.spentInPool:
        _status = MoneroUnlockPaymentRequestOutputStatus.pool;
        break;
    }
    _checkUpdate();
  }

  void updateConfrimation(int confirmations) {
    assert(this.confirmations <= confirmations, "should not be happend.");
    if (this.confirmations >= confirmations) {
      return;
    }
    _confirmations = confirmations;
    _checkUpdate();
  }

  void updateIndices(List<BigInt> outputIndeces) {
    if (outputIndeces.isEmpty ||
        outputIndeces.length <= lockedOutput.realIndex) {
      return;
    }
    assert(
        _globalIndex == null ||
            _globalIndex == outputIndeces[lockedOutput.realIndex],
        "must be updated. not changed.");
    _globalIndex = outputIndeces[lockedOutput.realIndex];
    _checkUpdate();
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborBytesValue(txId.codeUnits),
          CborBytesValue(keyImage.codeUnits),
          confirmations,
          height,
          status.value,
          CborBytesValue(lockedOutput.serialize()),
          globalIndex
        ]),
        CborTagsConst.moneroUtxoDetails);
  }

  @override
  List get variabels => [keyImage, lockedOutput.realIndex];
  MoneroLockedPayment toLockedPayment() {
    if (needUpdate) {
      throw const WalletException("output_is_not_ready_for_spending");
    }
    return MoneroLockedPayment(
        output: MoneroLockedOutput(
            amount: lockedOutput.amount,
            derivation: lockedOutput.derivation,
            mask: lockedOutput.mask,
            outputPublicKey: lockedOutput.outputPublicKey,
            accountIndex: lockedOutput.accountIndex,
            unlockTime: lockedOutput.unlockTime,
            realIndex: lockedOutput.realIndex),
        txPubkey: lockedOutput.outputPublicKey,
        paymentId: null,
        encryptedPaymentid: null,
        globalIndex: globalIndex!);
  }

  MoneroUnLockedPayment toUnlockedFakePayment() {
    return MoneroUnLockedPayment(
        output: MoneroUnlockedOutput(
            amount: lockedOutput.amount,
            derivation: lockedOutput.derivation,
            ephemeralSecretKey: RCT.identity(clone: false),
            ephemeralPublicKey: lockedOutput.outputPublicKey,
            keyImage: RCT.identity(clone: false),
            mask: lockedOutput.mask,
            outputPublicKey: lockedOutput.outputPublicKey,
            accountIndex: lockedOutput.accountIndex,
            unlockTime: lockedOutput.unlockTime,
            realIndex: lockedOutput.realIndex),
        txPubkey: lockedOutput.outputPublicKey,
        paymentId: null,
        encryptedPaymentid: null,
        globalIndex: globalIndex ?? BigInt.from(1 << 31));
  }

  @override
  String toString() {
    return "UTXO: $txId";
  }
}

class MoneroUnlockedPaymentRequestDetails with CborSerializable {
  final String txID;
  final MoneroOutputDetails? output;
  final MoneroUnlockPaymentRequestStatus status;
  bool get hasPayment => output != null;

  MoneroUnlockedPaymentRequestDetails._(
      {required this.output, required this.status, required this.txID});
  factory MoneroUnlockedPaymentRequestDetails(
      {required String txid, MoneroOutputDetails? output}) {
    return MoneroUnlockedPaymentRequestDetails._(
      output: output,
      status: output == null
          ? MoneroUnlockPaymentRequestStatus.error
          : MoneroUnlockPaymentRequestStatus.success,
      txID: QuickCryptoValidator.asValidHexBytes(txid),
    );
  }
  factory MoneroUnlockedPaymentRequestDetails.deserialize(
      {List<int>? bytes, CborObject? cbor, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: cbor,
        hex: hex,
        tags: CborTagsConst.moneroUtxoPaymentInfo);
    final status =
        MoneroUnlockPaymentRequestStatus.fromValue(values.elementAs(1));
    final output = status.hasPayment
        ? MoneroOutputDetails.deserialize(cbor: values.getCborTag(0))
        : null;
    return MoneroUnlockedPaymentRequestDetails._(
      output: output,
      status: status,
      txID: QuickCryptoValidator.asValidHexBytes(
          String.fromCharCodes(values.elementAs<List<int>>(2))),
    );
  }
  factory MoneroUnlockedPaymentRequestDetails.fromUnlockOutput(
      {required String txId,
      required int? comfirmation,
      required BigInt? globalIndex,
      MoneroUnlockedOutput? output,
      MoneroAddress? address}) {
    if (output == null) return MoneroUnlockedPaymentRequestDetails(txid: txId);
    assert(address != null, "address must not be null");
    return MoneroUnlockedPaymentRequestDetails(
        txid: txId,
        output: MoneroOutputDetails(
            txId: txId,
            keyImage: output.keyImageAsHex,
            confirmations: comfirmation,
            globalIndex: globalIndex,
            lockedOut: MoneroLockedOutput(
                amount: output.amount,
                mask: output.mask,
                derivation: output.derivation,
                outputPublicKey: output.outputPublicKey,
                accountIndex: output.accountIndex,
                unlockTime: output.unlockTime,
                realIndex: output.realIndex)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [output?.toCbor(), status.value, CborBytesValue(txID.codeUnits)]),
        CborTagsConst.moneroUtxoPaymentInfo);
  }
}

class MoneroProcessTxesResponse with CborSerializable {
  final MoneroViewPrimaryAccountDetails address;
  final List<MoneroUnlockedPaymentRequestDetails> responses;
  MoneroUpdatePaymentRequest? toPayment() {
    final successOuts = responses.where((e) => e.hasPayment);
    if (successOuts.isEmpty) return null;
    return MoneroUpdatePaymentRequest(
        payments: successOuts.map((e) => e.output!).toList(),
        primaryAddress: address);
  }

  MoneroProcessTxesResponse(
      {required List<MoneroUnlockedPaymentRequestDetails> responses,
      required this.address})
      : responses = responses.immutable;
  factory MoneroProcessTxesResponse.deserialize(
      {List<int>? bytes, CborObject? cbor, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: cbor,
        hex: hex,
        tags: CborTagsConst.moneroProcessTxesResponse);
    return MoneroProcessTxesResponse(
        responses: values
            .elementAsListOf<CborTagValue>(0)
            .map(
                (e) => MoneroUnlockedPaymentRequestDetails.deserialize(cbor: e))
            .toList(),
        address: MoneroViewPrimaryAccountDetails.deserialize(
            object: values.getCborTag(1)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborListValue.fixedLength(responses.map((e) => e.toCbor()).toList()),
          address.toCbor()
        ]),
        CborTagsConst.moneroProcessTxesResponse);
  }
}

class MoneroBatchProcessTxesResponse with CborSerializable {
  final List<MoneroProcessTxesResponse> payments;

  List<MoneroUpdatePaymentRequest> successPaymets() {
    return payments
        .map((e) => e.toPayment())
        .whereType<MoneroUpdatePaymentRequest>()
        .toList();
  }

  MoneroBatchProcessTxesResponse(List<MoneroProcessTxesResponse> payments)
      : payments = payments.immutable;
  factory MoneroBatchProcessTxesResponse.deserialize(
      {List<int>? bytes, CborObject? cbor, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: cbor,
        hex: hex,
        tags: CborTagsConst.moneroBatchProcessTxesResponse);
    return MoneroBatchProcessTxesResponse(values
        .elementAsListOf<CborTagValue>(0)
        .map((e) => MoneroProcessTxesResponse.deserialize(cbor: e))
        .toList());
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborListValue.fixedLength(payments.map((e) => e.toCbor()).toList()),
        ]),
        CborTagsConst.moneroBatchProcessTxesResponse);
  }
}

class MoneroAccountWithUtxo {
  final ReceiptAddress<MoneroAddress> address;
  final List<MoneroOutputDetails> utxos;
  MoneroAccountWithUtxo(
      {required this.address, required List<MoneroOutputDetails> utxos})
      : utxos = utxos.immutable;
  @override
  String toString() {
    return {"address": address.view, "Utxos": utxos}.toString();
  }
}

class MoneroOutputWithBalance {
  final ReceiptAddress<MoneroAddress> address;
  final IntegerBalance amount;
  MoneroOutputWithBalance(
      {required this.address, required WalletMoneroNetwork network})
      : amount = IntegerBalance.zero(network.coinDecimal);
  bool _hasAmount = false;
  bool get hasAmount => _hasAmount;

  MoneroTxDestination toMoneroDestination() {
    return MoneroTxDestination(
        amount: amount.balance, address: address.networkAddress);
  }

  void updateBalance([BigInt? updateBalance]) {
    amount.updateBalance(updateBalance);
    _hasAmount = amount.largerThanZero;
  }

  bool get isIntegratedRecipient => address.networkAddress.isIntegratedAddress;
}

class MoneroChainTrackerResponse with CborSerializable {
  final List<String> txIds;
  final int blockLength;
  final int startHeight;
  int get height => startHeight + blockLength;
  final MoneroBlockTrackingStatus status;
  MoneroChainTrackerResponse(
      {required List<String> txIds,
      required this.blockLength,
      required this.startHeight,
      required this.status})
      : txIds = txIds
            .map((e) => QuickCryptoValidator.asValidHexBytes(e,
                lengthInBytes: MoneroConst.txHashLength))
            .toImutableList;

  factory MoneroChainTrackerResponse.deserialize(
      {List<int>? bytes, CborObject? cbor, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: cbor,
        hex: hex,
        tags: CborTagsConst.moneroChainTrackingResponse);
    return MoneroChainTrackerResponse(
        txIds: values
            .elementAsListOf<CborBytesValue>(0)
            .map((e) => String.fromCharCodes(e.value))
            .toList(),
        blockLength: values.elementAs(1),
        startHeight: values.elementAs(2),
        status: MoneroBlockTrackingStatus.fromValue(values.elementAs(3)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborListValue.fixedLength(
              txIds.map((e) => CborBytesValue(e.codeUnits)).toList()),
          blockLength,
          startHeight,
          status.value
        ]),
        CborTagsConst.moneroChainTrackingResponse);
  }
}

class MoneroUpdatePaymentRequest {
  final List<MoneroOutputDetails> payments;
  final MoneroViewPrimaryAccountDetails primaryAddress;
  MoneroUpdatePaymentRequest(
      {required List<MoneroOutputDetails> payments,
      required this.primaryAddress})
      : payments = payments.imutable;
}

class MoneroAccountPendingTxes with CborSerializable, Equatable {
  List<String> _txIDs;
  List<String> get txIDs => _txIDs;
  final MoneroViewPrimaryAccountDetails primaryAddress;
  MoneroAccountPendingTxes(
      {Iterable<String> txIDs = const [], required this.primaryAddress})
      : _txIDs = txIDs.toImutableList;

  factory MoneroAccountPendingTxes.deserialize(
      {List<int>? bytes, CborObject? obj, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: hex,
        object: obj,
        tags: CborTagsConst.moneroAccountPendingTxes);
    return MoneroAccountPendingTxes(
        primaryAddress: MoneroViewPrimaryAccountDetails.deserialize(
            object: values.getCborTag(0)),
        txIDs: values
            .elementAsListOf<CborStringValue>(1)
            .map((e) => e.value)
            .toList());
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          primaryAddress.toCbor(),
          txIDs.map((e) => CborStringValue(e)).toList()
        ]),
        CborTagsConst.moneroAccountPendingTxes);
  }

  void addTxes(Iterable<String> txs) {
    _txIDs = <String>{..._txIDs, ...txs}.toImutableList;
  }

  @override
  List get variabels => [primaryAddress];

  @override
  String toString() {
    return {"address": primaryAddress, "txIds": _txIDs}.toString();
  }
}

class MoneroFetchTxIdsResponse {
  final List<MoneroTxInfo> txes;
  final MoneroViewPrimaryAccountDetails primaryAddress;
  MoneroFetchTxIdsResponse(
      {required List<MoneroTxInfo> txes, required this.primaryAddress})
      : txes = txes.imutable;
}

class MoneroProcessTxIdsRequest with CborSerializable {
  final List<MoneroTxInfo> txes;
  final MoneroViewPrimaryAccountDetails primaryAddress;
  final List<MoneroAccountIndex> keyIndexes;
  final Bip32AddressIndex index;
  MoneroProcessTxIdsRequest(
      {required List<MoneroTxInfo> txes,
      required this.primaryAddress,
      required List<MoneroAccountIndex> keyIndexes,
      required this.index})
      : txes = txes.immutable,
        keyIndexes = keyIndexes.immutable;
  factory MoneroProcessTxIdsRequest.deserialize(
      {List<int>? bytes, CborObject? cbor, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: cbor,
        hex: hex,
        tags: CborTagsConst.moneroProcessTxIdRequest);
    return MoneroProcessTxIdsRequest(
        txes: values
            .elementAsListOf<CborTagValue>(0)
            .map((e) => MoneroTxInfo.deserialize(cbor: e))
            .toList(),
        primaryAddress: MoneroViewPrimaryAccountDetails.deserialize(
            object: values.getCborTag(1)),
        keyIndexes: values
            .elementAsListOf<CborBytesValue>(2)
            .map((e) => MoneroAccountIndex.deserialize(e.value))
            .toList(),
        index:
            Bip32AddressIndex.fromCborBytesOrObject(obj: values.getCborTag(3)));
  }
  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborListValue.fixedLength(txes.map((e) => e.toCbor()).toList()),
          primaryAddress.toCbor(),
          CborListValue.fixedLength(
              keyIndexes.map((e) => CborBytesValue(e.serialize())).toList()),
          index.toCbor(),
        ]),
        CborTagsConst.moneroProcessTxIdRequest);
  }
}

class MoneroWalletRPCAddress {
  final MoneroAddress address;
  final int addressIndex;
  final int accountIndex;
  const MoneroWalletRPCAddress(
      {required this.address,
      required this.addressIndex,
      required this.accountIndex});
}

class MoneroWalletRPCAccounts {
  final MoneroAddress primary;

  final List<MoneroWalletRPCAddress> addresses;
  MoneroWalletRPCAccounts(
      {required this.primary, required List<MoneroWalletRPCAddress> addresses})
      : addresses = addresses.immutable;
  @override
  String toString() {
    return "$primary $addresses";
  }
}

class MoneroSyncAccountsInfos with CborSerializable, Equatable {
  final MoneroViewPrimaryAccountDetails primaryAccount;
  Set<MoneroSyncAccountIndexInfo> _indexes;
  Set<MoneroSyncAccountIndexInfo> get indexes => _indexes;
  Set<String> _pendingTxes;
  Set<String> get pendingTxes => _pendingTxes;

  List<MoneroSyncAccountInfo> getAddresses() {
    return _indexes
        .map((e) => MoneroSyncAccountInfo(
            address: MoneroAddress(primaryAccount.account
                .subaddress(e.index.minor, majorIndex: e.index.major)),
            startHeight: e.startHeight))
        .toList();
  }

  MoneroAccountKeys getAccountKeys() {
    return MoneroAccountKeys(
        account: primaryAccount.account,
        network: primaryAccount.network,
        indexes: _indexes.map((e) => e.index).toList());
  }

  MoneroSyncAccountsInfos(
      {List<MoneroSyncAccountIndexInfo> indexes = const [],
      required this.primaryAccount,
      List<String> pendingTxes = const []})
      : _indexes = indexes.toImutableSet,
        _pendingTxes = pendingTxes.toImutableSet;
  factory MoneroSyncAccountsInfos.deserialize(
      {List<int>? bytes, CborObject? cbor, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: cbor,
        hex: hex,
        tags: CborTagsConst.moneroProcessTxesResponse);
    return MoneroSyncAccountsInfos(
        primaryAccount: MoneroViewPrimaryAccountDetails.deserialize(
            object: values.getCborTag(0)),
        indexes: values
            .elementAsListOf<CborTagValue>(1)
            .map((e) => MoneroSyncAccountIndexInfo.deserialize(cbor: e))
            .toList(),
        pendingTxes: values
            .elementAsListOf<CborStringValue>(2)
            .map((e) => e.value)
            .toList());
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          primaryAccount.toCbor(),
          CborListValue.fixedLength(_indexes.map((e) => e.toCbor()).toList()),
          CborListValue.fixedLength(
              _pendingTxes.map((e) => CborStringValue(e)).toList()),
        ]),
        CborTagsConst.moneroProcessTxesResponse);
  }

  bool removeIndex(MoneroAccountIndex index) {
    final indexes = this.indexes.clone();
    indexes.removeWhere((e) => e.index == index);
    _indexes = indexes.toImutableSet;
    return _indexes.isNotEmpty;
  }

  void updateStartHeights(int startHeight) {
    assert(startHeight >= 0, "invalid start height.");
    _indexes = _indexes.map((e) => e.updateHeight(startHeight)).toImutableSet;
  }

  void addIndex(MoneroSyncAccountIndexInfo index) {
    if (_indexes.contains(index)) return;
    _indexes = {..._indexes, index}.toImutableSet;
  }

  void addPendingTx(Iterable<String> txes) {
    _pendingTxes = {..._pendingTxes, ...txes}.toImutableSet;
  }

  void removeTxes(Iterable<String> txes) {
    _pendingTxes = _pendingTxes.where((e) => !txes.contains(e)).toImutableSet;
  }

  @override
  List get variabels => [primaryAccount];

  @override
  String toString() {
    return {
      "index": indexes.toString(),
      "address": primaryAccount.primaryAddress,
      "pending_txes": pendingTxes
    }.toString();
  }
}

class MoneroSyncAccountIndexInfo with CborSerializable, Equatable {
  final MoneroAccountIndex index;
  final int startHeight;

  MoneroSyncAccountIndexInfo({required this.index, required this.startHeight});
  factory MoneroSyncAccountIndexInfo.deserialize(
      {List<int>? bytes, CborObject? cbor, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: cbor,
        hex: hex,
        tags: CborTagsConst.moneroSyncAccountIndexInfo);
    return MoneroSyncAccountIndexInfo(
        index: MoneroAccountIndex.deserialize(values.elementAs(0)),
        startHeight: values.elementAs(1));
  }

  MoneroSyncAccountIndexInfo updateHeight(int height) {
    assert(startHeight == 0, "the start height already updated.");
    return MoneroSyncAccountIndexInfo(index: index, startHeight: height);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [CborBytesValue(index.serialize()), startHeight]),
        CborTagsConst.moneroSyncAccountIndexInfo);
  }

  @override
  List get variabels => [index];

  @override
  String toString() {
    return {"index": index.toString(), "startHeight": startHeight}.toString();
  }
}

class MoneroSyncAccountInfo {
  final MoneroAddress address;
  final int startHeight;
  const MoneroSyncAccountInfo(
      {required this.address, required this.startHeight});
}

enum MoneroSyncBlockResponseType {
  blockInfo(CborTagsConst.moneroBlockInfoResponse),
  trackInfo(CborTagsConst.moneroSyncAccountResponse);

  const MoneroSyncBlockResponseType(this.tag);
  final List<int> tag;
  static MoneroSyncBlockResponseType fromTag(List<int>? tag) {
    return values.firstWhere((e) => BytesUtils.bytesEqual(e.tag, tag),
        orElse: () => throw WalletExceptionConst.invalidData(
            messsage: "Invalid sync block data."));
  }
}

abstract class MoneroSyncBlocksResponse with CborSerializable {
  final MoneroSyncBlockResponseType type;
  const MoneroSyncBlocksResponse._({required this.type});
  factory MoneroSyncBlocksResponse.deserialize(
      {List<int>? bytes, CborObject? cbor, String? hex}) {
    final CborTagValue values =
        CborSerializable.decode(cborBytes: bytes, object: cbor, hex: hex);
    final type = MoneroSyncBlockResponseType.fromTag(values.tags);
    return switch (type) {
      MoneroSyncBlockResponseType.blockInfo =>
        MoneroBlocksInfoResponse.deserialize(cbor: values),
      MoneroSyncBlockResponseType.trackInfo =>
        MoneroSyncAccountResponse.deserialize(cbor: values)
    };
  }

  T cast<T extends MoneroSyncBlocksResponse>() {
    if (this is! T) {
      throw WalletException.invalidArgruments(["$T", "$runtimeType"]);
    }
    return this as T;
  }
}

class MoneroBlocksInfoResponse extends MoneroSyncBlocksResponse {
  final int totalBlock;
  final int totalTxes;
  final MoneroParsingBlockStatus status;

  MoneroBlocksInfoResponse(
      {required this.totalBlock, required this.totalTxes, required this.status})
      : super._(type: MoneroSyncBlockResponseType.blockInfo);

  factory MoneroBlocksInfoResponse.deserialize(
      {List<int>? bytes, CborObject? cbor, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: cbor,
        hex: hex,
        tags: MoneroSyncBlockResponseType.blockInfo.tag);
    return MoneroBlocksInfoResponse(
        totalBlock: values.elementAs(0),
        totalTxes: values.elementAs(1),
        status: MoneroParsingBlockStatus.fromValue(values.elementAs(2)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([totalBlock, totalTxes, status.value]),
        type.tag);
  }

  @override
  String toString() {
    return {
      "type": type.name,
      "totalBlock": totalBlock,
      "totalTxes": totalTxes,
      "status": status.name
    }.toString();
  }
}

class MoneroSyncAccountResponse extends MoneroSyncBlocksResponse {
  final Set<MoneroSyncAccountsInfos> txIds;
  final MoneroBlockTrackingPossition blockPosition;
  MoneroSyncAccountResponse(
      {required Iterable<MoneroSyncAccountsInfos> txIds,
      required this.blockPosition})
      : txIds = txIds.toImutableSet,
        super._(type: MoneroSyncBlockResponseType.trackInfo);

  factory MoneroSyncAccountResponse.deserialize(
      {List<int>? bytes, CborObject? cbor, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: cbor,
        hex: hex,
        tags: MoneroSyncBlockResponseType.trackInfo.tag);
    return MoneroSyncAccountResponse(
      txIds: values
          .elementAsListOf<CborTagValue>(0)
          .map((e) => MoneroSyncAccountsInfos.deserialize(cbor: e))
          .toList(),
      blockPosition:
          MoneroBlockTrackingPossition.deserialize(cbor: values.getCborTag(1)),
    );
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborListValue.fixedLength(txIds.map((e) => e.toCbor()).toList()),
          blockPosition.toCbor()
        ]),
        type.tag);
  }

  @override
  String toString() {
    return {
      "type": type.name,
      "blockPosition": blockPosition,
      "txids": txIds,
    }.toString();
  }
}

enum MoneroSyncBlockRequestType {
  blocksInfo(CborTagsConst.moneroSyncBlocksInfoRequest),
  trackBlocks(CborTagsConst.moneroSyncTrackBlocksRequest);

  const MoneroSyncBlockRequestType(this.tag);
  final List<int> tag;
  static MoneroSyncBlockRequestType fromTag(List<int>? tag) {
    return values.firstWhere((e) => BytesUtils.bytesEqual(e.tag, tag),
        orElse: () => throw WalletExceptionConst.invalidData(
            messsage: "Invalid sync block request data."));
  }
}

abstract class MoneroSyncBlocksRequest with CborSerializable {
  final MoneroSyncBlockRequestType type;
  const MoneroSyncBlocksRequest._({required this.type});

  factory MoneroSyncBlocksRequest.deserialize(
      {List<int>? bytes, CborObject? cbor, String? hex}) {
    final CborTagValue values =
        CborSerializable.decode(cborBytes: bytes, object: cbor, hex: hex);
    final type = MoneroSyncBlockRequestType.fromTag(values.tags);
    return switch (type) {
      MoneroSyncBlockRequestType.blocksInfo =>
        MoneroSyncBlocksInfoRequest.deserialize(cbor: values),
      MoneroSyncBlockRequestType.trackBlocks =>
        MoneroSyncTrackBlocksRequest.deserialize(cbor: values)
    };
  }
  T cast<T extends MoneroSyncBlocksRequest>() {
    if (this is! T) {
      throw WalletException.invalidArgruments(["$T", "$runtimeType"]);
    }
    return this as T;
  }
}

class MoneroSyncTrackBlocksRequest extends MoneroSyncBlocksRequest {
  final List<MoneroBlockTrackingPossition> blockPossitions;
  MoneroSyncTrackBlocksRequest(
      {required List<MoneroBlockTrackingPossition> blockPossitions})
      : blockPossitions = blockPossitions.immutable,
        super._(type: MoneroSyncBlockRequestType.trackBlocks);

  factory MoneroSyncTrackBlocksRequest.deserialize(
      {List<int>? bytes, CborObject? cbor, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: cbor,
        hex: hex,
        tags: MoneroSyncBlockRequestType.trackBlocks.tag);
    return MoneroSyncTrackBlocksRequest(
        blockPossitions: values
            .elementAsListOf<CborTagValue>(0)
            .map((e) => MoneroBlockTrackingPossition.deserialize(cbor: e))
            .toList());
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborListValue.fixedLength(
              blockPossitions.map((e) => e.toCbor()).toList())
        ]),
        type.tag);
  }

  @override
  String toString() {
    return {"type": type.name, "blockPossitions": blockPossitions}.toString();
  }
}

class MoneroSyncBlocksInfoRequest extends MoneroSyncBlocksRequest {
  final int height;
  MoneroSyncBlocksInfoRequest({
    required this.height,
  }) : super._(type: MoneroSyncBlockRequestType.blocksInfo);

  factory MoneroSyncBlocksInfoRequest.deserialize(
      {List<int>? bytes, CborObject? cbor, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: cbor,
        hex: hex,
        tags: MoneroSyncBlockRequestType.blocksInfo.tag);
    return MoneroSyncBlocksInfoRequest(height: values.elementAs(0));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([height]), type.tag);
  }

  @override
  String toString() {
    return {"type": type.name, "height": height}.toString();
  }
}
