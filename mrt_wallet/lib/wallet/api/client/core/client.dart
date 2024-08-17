import 'package:mrt_wallet/app/constant/global/repository.dart';
import 'package:mrt_wallet/app/live_listener/live.dart';
import 'package:mrt_wallet/app/synchronized/basic_lock.dart';
import 'package:mrt_wallet/app/utils/method/utiils.dart';
import 'package:mrt_wallet/repository/repository.dart';
import 'package:mrt_wallet/wallet/api/provider/core/provider.dart';
import 'package:mrt_wallet/wallet/api/services/service.dart';
import 'package:mrt_wallet/wallet/models/network/core/network/network.dart';

enum NodeClientStatus {
  connect,
  disconnect,
  pending;

  bool get isConnect => this == NodeClientStatus.connect;
  bool get isPending => this == NodeClientStatus.pending;
  bool get isDisconnect => this == NodeClientStatus.disconnect;
}

/// with BaseRepository
abstract class NetworkClient<T, P extends APIProvider> with BaseRepository {
  NetworkClient();
  abstract final WalletNetwork network;
  Future<void> updateBalance(T account);
  abstract final BaseServiceProtocol<P> service;
  @override
  String get repositoryStorageId =>
      RepositoryConst.providerStorageKeyId + network.toString();

  final Live<NodeClientStatus> _status = Live(NodeClientStatus.disconnect);
  Live<NodeClientStatus> get status => _status;

  bool get isConnect => _status.value.isConnect;

  Future<bool> onInit() async {
    return true;
  }

  final _lock = SynchronizedLock();

  Future<void> _init() async {
    if (_status.value.isConnect || _status.value.isPending) return;
    _status.value = NodeClientStatus.pending;
    final init = await MethodUtils.call(() async => await onInit());
    if (init.hasResult && init.result) {
      _status.value = NodeClientStatus.connect;
    } else {
      _status.value = NodeClientStatus.disconnect;
    }
  }

  Future<void> init() async {
    await _lock.synchronized(() async => await _init());
  }

  void dispose() {
    service.disposeService();
  }

  @override
  String toString() {
    return "Client: ${network.token.name}";
  }
}
