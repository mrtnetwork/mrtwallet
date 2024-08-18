import 'package:mrt_wallet/wallet/constant/constant.dart';
import 'package:mrt_wallet/crypto/utils/substrate/substrate.dart';
import 'package:polkadot_dart/polkadot_dart.dart';
import 'transaction.dart';

mixin SubstrateTransactionBuilderImpl on SubstrateTransactiomImpl {
  int? _nonce;

  Future<int> _readNonce() async {
    _nonce = await apiProvider.getNonce(address.networkAddress);
    return _nonce!;
  }

  @override
  Future<TransactionPayload> buildTransaction() async {
    final nonce = await _readNonce();
    final blockHash = await apiProvider.getFinalizBlock();
    final era = await apiProvider.getBlockEra(blockHash.toHex(prefix: "0x"));
    final version = api.runtimeVersion();
    final messages = validator.validator.toMessage();
    final memoMessages = SubstrateUtils.buildRemarks(memos);
    return await _buildTransfer(
        era: era,
        nonce: nonce,
        blockHash: blockHash,
        genesisHash: apiProvider.genesisBlock,
        version: version,
        messages: List<Map<String, dynamic>>.unmodifiable(
            [...messages, ...memoMessages]));
  }

  Future<TransactionPayload> _buildTransfer(
      {required SubstrateBaseEra era,
      required int nonce,
      required SubstrateBlockHash blockHash,
      required SubstrateBlockHash genesisHash,
      required RuntimeVersion version,
      required List<Map<String, dynamic>> messages}) async {
    final message = SubstrateUtils.buildMethod(messages);
    final List<int> messageBytes;
    if (messages.length == 1) {
      messageBytes = api.encodeCall(
          palletNameOrIndex: SubstrateConst.balancePalletName,
          value: message,
          fromTemplate: false);
    } else {
      messageBytes = api.encodeCall(
          palletNameOrIndex: SubstrateConst.utilityPalletName,
          value: message,
          fromTemplate: false);
    }
    return TransactionPayload(
        blockHash: blockHash,
        era: era,
        genesisHash: genesisHash,
        method: messageBytes,
        nonce: nonce,
        specVersion: version.specVersion,
        transactionVersion: version.transactionVersion,
        tip: BigInt.zero);
  }
}
