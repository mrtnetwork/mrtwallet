import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:monero_dart/monero_dart.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/keys/keys.dart';
import 'package:mrt_wallet/crypto/requets/argruments/argruments.dart';
import 'package:mrt_wallet/crypto/requets/messages/core/message.dart';
import 'package:mrt_wallet/wallet/models/networks/monero/monero.dart';

class WalletRequestMoneroOutputUnlocker
    extends WalletRequest<MoneroBatchProcessTxesResponse, MessageArgsOneBytes> {
  final List<MoneroProcessTxIdsRequest> requests;
  WalletRequestMoneroOutputUnlocker(List<MoneroProcessTxIdsRequest> requests)
      : requests = requests.immutable;

  factory WalletRequestMoneroOutputUnlocker.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: WalletRequestMethod.moneroOutputUnlocker.tag);
    return WalletRequestMoneroOutputUnlocker(values
        .elementAsListOf<CborTagValue>(0)
        .map((e) => MoneroProcessTxIdsRequest.deserialize(cbor: e))
        .toList());
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborListValue.fixedLength(requests.map((e) => e.toCbor()).toList()),
        ]),
        method.tag);
  }

  @override
  WalletRequestMethod get method => WalletRequestMethod.moneroOutputUnlocker;

  @override
  MessageArgsOneBytes getResult(
      {required WalletMasterKeys wallet, required List<int> key}) {
    final response = result(wallet: wallet, key: key);
    return MessageArgsOneBytes(keyOne: response.toCbor().encode());
  }

  @override
  MoneroBatchProcessTxesResponse result(
      {required WalletMasterKeys wallet, required List<int> key}) {
    final List<MoneroPrivateKeyData> keys = wallet
        .readKeys(requests
            .map((e) => AccessCryptoPrivateKeyRequest(index: e.index))
            .toList())
        .cast<MoneroPrivateKeyData>();
    final accounts = List.generate(keys.length, (i) {
      final key = keys[i];
      return MoneroAccountKeys(
          account: key.toMoneroAccount(),
          network: MoneroNetwork.mainnet,
          indexes: requests[i].keyIndexes);
    });
    final List<MoneroProcessTxesResponse> payments = [];
    for (int i = 0; i < requests.length; i++) {
      final request = requests[i];
      final account = accounts[i];
      final txes = request.txes;
      final unlockedOuts = unlockOuts(txes: txes, account: account);
      final payment = MoneroProcessTxesResponse(
          responses: unlockedOuts, address: requests[i].primaryAddress);
      payments.add(payment);
    }
    final response = MoneroBatchProcessTxesResponse(payments);
    return response;
  }

  List<MoneroUnlockedPaymentRequestDetails> unlockOuts(
      {required List<MoneroTxInfo> txes, required MoneroAccountKeys account}) {
    final List<MoneroUnlockedPaymentRequestDetails> payments = [];
    for (int i = 0; i < txes.length; i++) {
      final txData = txes[i];
      final tx = txData.toTx();
      final txId = txData.txId;
      if (tx == null) {
        payments.add(MoneroUnlockedPaymentRequestDetails(txid: txId));
        continue;
      }
      for (int i = 0; i < tx.vout.length; i++) {
        final getOut = MoneroTransactionHelper.getUnlockOut(
            tx: tx, account: account, realIndex: i);
        if (getOut == null) continue;
        final address = account.indexAddress(getOut.accountIndex);
        BigInt? globalIndex;
        if (tx.vout.length == txData.globalIndices.length) {
          globalIndex = txData.globalIndices[getOut.realIndex];
        }
        payments.add(MoneroUnlockedPaymentRequestDetails.fromUnlockOutput(
            output: getOut,
            txId: txId,
            address: address,
            comfirmation: txData.confirmations,
            globalIndex: globalIndex));
      }
    }
    return payments;
  }

  @override
  MoneroBatchProcessTxesResponse parsResult(MessageArgsOneBytes result) {
    return MoneroBatchProcessTxesResponse.deserialize(bytes: result.keyOne);
  }
}
