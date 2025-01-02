import 'dart:async';

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:monero_dart/monero_dart.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/requets/argruments/argruments.dart';
import 'package:mrt_wallet/crypto/requets/messages/core/message.dart';
import 'package:mrt_wallet/wallet/api/api.dart';
import 'package:mrt_wallet/wallet/models/networks/monero/models/account_related.dart';

class StreamRequestMoneroBlockTracking extends IsolateStreamRequest<
    MoneroSyncBlocksResponse, MoneroSyncBlocksRequest> {
  StreamRequestMoneroBlockTracking({required this.provider})
      : client = APIUtils.buildMoneroClient(
            provider: provider, network: null, isolate: APPIsolate.current);
  final MoneroAPIProvider provider;
  final MoneroClient client;
  factory StreamRequestMoneroBlockTracking.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: StreamIsolateMethod.moneroAccountTracker.tag);
    return StreamRequestMoneroBlockTracking(
        provider:
            MoneroAPIProvider.fromCborBytesOrObject(obj: values.getCborTag(0)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([provider.toCbor()]), method.tag);
  }

  (MoneroSyncBlocksResponse, List<DaemonBlockCompleteEntryResponse>)
      getBlockInfo(List<int> blockData) {
    try {
      final json = MoneroStorageSerializer.deserialize(blockData);
      final b = DaemonBaseResponse.fromJson(json);
      if (!b.isOk) {
        return (
          MoneroBlocksInfoResponse(
              totalBlock: 0,
              totalTxes: 0,
              status: MoneroParsingBlockStatus.noBlock),
          []
        );
      }
      final blocks = DaemonGetBlockBinResponse.fromJson(json).blocks;
      final totalTxes = blocks.fold(0, (p, c) => p + c.txs.length);
      return (
        MoneroBlocksInfoResponse(
            totalBlock: blocks.length,
            totalTxes: totalTxes,
            status: MoneroParsingBlockStatus.success),
        blocks
      );
    } catch (_) {
      assert(false, "should not be here ? !");
      return (
        MoneroBlocksInfoResponse(
            totalBlock: 0,
            totalTxes: 0,
            status: MoneroParsingBlockStatus.failed),
        []
      );
    }
  }

  Future<MoneroSyncAccountResponse?> proccessBlock(
      {required MoneroBlockTrackingPossition blockPossiton,
      required List<DaemonBlockCompleteEntryResponse> blocks,
      required MoneroAccountBlocksTracker accounts}) async {
    final offset = blockPossiton.offset;
    final totalRange = blockPossiton.totalRange + offset;
    try {
      final viewAccounts = accounts.accounts;
      final accountsKeys = accounts.getAccountsKeys();
      assert(totalRange <= blocks.length,
          "invalid range ${blocks.length} $totalRange");
      for (int i = offset; i < totalRange; i++) {
        await Future.delayed(const Duration(microseconds: 1));

        if (closed) {
          return null;
        }
        final block = blocks[i];
        MoneroBlock? moneroBlock;
        for (int t = 0; t < block.txs.length; t++) {
          MoneroTransaction tx;
          try {
            tx = block.txs[t].toTx();
          } catch (_) {
            assert(false, "should not be faild.");
            continue;
          }
          for (int realIndex = 0; realIndex < tx.vout.length; realIndex++) {
            for (int a = 0; a < accountsKeys.length; a++) {
              final account = accountsKeys[a];
              final unlock = MoneroTransactionHelper.getLockedOutputs(
                  realIndex: realIndex, tx: tx, account: account);
              if (unlock != null) {
                moneroBlock ??= block.toBlock();
                final txid = BytesUtils.toHexString(moneroBlock.txHashes[t]);
                viewAccounts.elementAt(a).addPendingTx({txid});
              }
            }
          }
        }
      }

      return MoneroSyncAccountResponse(
          txIds: accounts.accounts,
          blockPosition:
              blockPossiton.updateStatus(MoneroBlockTrackingStatus.success));
    } catch (e) {
      return MoneroSyncAccountResponse(
        txIds: {},
        blockPosition:
            blockPossiton.updateStatus(MoneroBlockTrackingStatus.failed),
      );
    }
  }

  @override
  StreamIsolateMethod get method => StreamIsolateMethod.moneroAccountTracker;
  Future<List<int>> _fetchBlocks(MoneroSyncBlocksInfoRequest request) async {
    int tryFetchBlock = 1;
    while (true) {
      final blockData = await MethodUtils.call(
          () => client.getBlocksByRangeBinary(request.height),
          waitAtError: APPConst.oneSecoundDuration * tryFetchBlock);
      if (blockData.hasError) {
        if (tryFetchBlock < 3) {
          tryFetchBlock++;
        }
        continue;
      }
      return blockData.result;
    }
  }

  List<DaemonBlockCompleteEntryResponse> blocks = [];

  void _sendResult(
      {required EventSink<MessageArgsStream> sink,
      required MessageArgsStream data}) {
    if (closed) return;
    sink.add(data);
  }

  @override
  void handleIsolateData(
      {required MoneroSyncBlocksRequest param,
      required EventSink<MessageArgsStream> sink,
      required String streamId,
      List<int>? encryptedPart}) async {
    final accounts =
        MoneroAccountBlocksTracker.deserialize(bytes: encryptedPart);
    if (param.type == MoneroSyncBlockRequestType.blocksInfo) {
      final blockRequest = param.cast<MoneroSyncBlocksInfoRequest>();
      List<int>? blocksData = await _fetchBlocks(blockRequest);
      final blockInfos = getBlockInfo(blocksData);
      blocks = blockInfos.$2;
      _sendResult(
          data: MessageArgsStream(
              data: blockInfos.$1.toCbor().encode(), streamId: streamId),
          sink: sink);
      blocksData = null;
      return;
    }
    final request = param.cast<MoneroSyncTrackBlocksRequest>();
    final List<MoneroBlockTrackingPossition> offsets = request.blockPossitions;
    if (offsets.isEmpty) {
      return;
    }
    for (final i in offsets) {
      final result = await proccessBlock(
          blockPossiton: i, blocks: blocks, accounts: accounts);
      if (result == null) return;
      _sendResult(
          data: MessageArgsStream(
              data: result.toCbor().encode(), streamId: streamId),
          sink: sink);
    }
  }

  @override
  Map<String, dynamic> toJson() {
    throw UnimplementedError();
  }

  @override
  void add(MessageArgsStream args) {
    super.add(args);
    switch (args.method) {
      case MessageArgsStreamMethod.data:
        streamController
            ?.add(MoneroSyncBlocksRequest.deserialize(bytes: args.data));
        break;
      default:
    }
  }

  @override
  MoneroSyncBlocksResponse parsResult(MessageArgsStream result) {
    return MoneroSyncBlocksResponse.deserialize(bytes: result.data!);
  }

  @override
  MessageArgsStream toRequest(
      {required MoneroSyncBlocksRequest message, required String streamId}) {
    return MessageArgsStream(
        data: message.toCbor().encode(), streamId: streamId);
  }

  @override
  void handleData(
      {required MoneroSyncBlocksRequest param,
      required EventSink<MoneroSyncBlocksResponse> sink,
      required String streamId,
      List<int>? encryptedPart}) {}
}
