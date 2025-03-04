import 'package:mrt_wallet/app/constant/global/repository.dart';
import 'package:mrt_wallet/app/live_listener/live.dart';
import 'package:mrt_wallet/app/synchronized/basic_lock.dart';
import 'package:mrt_wallet/app/utils/method/utiils.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/repository/repository.dart';
import 'package:mrt_wallet/wallet/api/provider/core/provider.dart';
import 'package:mrt_wallet/wallet/api/services/service.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
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
abstract class NetworkClient<T extends ChainAccount, P extends APIProvider>
    with BaseRepository {
  NetworkClient();
  abstract final WalletNetwork? network;
  Future<void> updateBalance(T address, APPCHAINACCOUNT<T> chain);
  abstract final BaseServiceProtocol<P> service;
  NetworkType get networkType;
  ProviderIdentifier get serviceIdentifier => DefaultProviderIdentifier(
      identifier: service.provider.identifier, network: networkType);
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

  Future<bool> _init() async {
    if (_status.value.isConnect) return true;
    _status.value = NodeClientStatus.pending;
    final init = await MethodUtils.call(() async => await onInit());
    if (init.hasResult && init.result) {
      _status.value = NodeClientStatus.connect;
    } else {
      _status.value = NodeClientStatus.disconnect;
    }
    return init.hasResult && init.result;
  }

  Future<bool> init() async {
    return await _lock.synchronized(() async => await _init());
  }

  void dispose() {
    service.disposeService();
  }

  @override
  String toString() {
    return "Client: ${network?.token.name}";
  }
}
