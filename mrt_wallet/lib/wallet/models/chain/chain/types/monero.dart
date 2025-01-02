part of 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';

enum MoneroChainStatus {
  none(value: 0, height: 0),
  outputReceived(value: 1, height: 70);

  const MoneroChainStatus({required this.value, required this.height});
  final int value;
  final double height;
  static MoneroChainStatus fromValue(int? value) {
    return values.firstWhere((e) => e.value == value,
        orElse: () => throw WalletExceptionConst.invalidAccountDetails);
  }
}

enum MoneroChainStorage implements ChainStorageKey {
  defaultTracker(0),
  syncRequests(1),
  transaction(2),
  walletRPC(3);

  @override
  final int storageId;
  const MoneroChainStorage(this.storageId);
}

class MoneroChainConfig extends ChainConfig<MoneroChainStorage> {
  MoneroChainConfig(
      {MoneroChainStatus status = MoneroChainStatus.none,
      bool showInitializeAlert = true})
      : _status = status,
        _showInitializeAlert = showInitializeAlert;
  factory MoneroChainConfig.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: CborTagsConst.moneroChainConfig);
    return MoneroChainConfig(
        status: MoneroChainStatus.fromValue(values.elementAs(0)),
        showInitializeAlert: values.elementAs<bool?>(1) ?? true);
  }
  MoneroChainStatus _status;

  MoneroChainStatus get status => _status;

  MoneroChainConfig copyWith(
      {MoneroChainStatus? status, bool? showInitializeAlert}) {
    return MoneroChainConfig(
        showInitializeAlert: showInitializeAlert ?? this.showInitializeAlert,
        status: status ?? this.status);
  }

  @override
  double get appbarHeight => _status.height;

  @override
  bool get hasAction => _status != MoneroChainStatus.none;
  bool _showInitializeAlert;
  bool get showInitializeAlert => _showInitializeAlert;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([_status.value, _showInitializeAlert]),
        CborTagsConst.moneroChainConfig);
  }

  @override
  List<MoneroChainStorage> get storageKeys => MoneroChainStorage.values;

  @override
  String toString() {
    return _status.name;
  }
}
