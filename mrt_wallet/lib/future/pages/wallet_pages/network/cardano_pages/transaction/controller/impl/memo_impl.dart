import 'package:on_chain/on_chain.dart';

import 'transaction.dart';

typedef OnAddCardanoMemo = Future<(String, BigInt)?> Function(
    List<BigInt> existsLabel, String? currentTxt);

mixin CardanoTransactionMemoImpl on CardanoTransactionImpl {
  Map<BigInt, TransactionMetadataText> _metadata =
      Map<BigInt, TransactionMetadataText>.unmodifiable({});
  Map<BigInt, TransactionMetadataText> get metadatas => _metadata;
  @override
  GeneralTransactionMetadata? get transactionMemo => _metadata.isEmpty
      ? null
      : GeneralTransactionMetadata(metadata: _metadata);

  Future<void> addMetaData(OnAddCardanoMemo addMemo, {BigInt? current}) async {
    try {
      final memo = _metadata[current]?.value;
      final labels = List<BigInt>.from(_metadata.keys.toList())
        ..removeWhere((element) => element == current);
      final m = await addMemo(labels, memo);
      final meta = Map<BigInt, TransactionMetadataText>.from(_metadata);
      meta.remove(current);
      if (m != null) {
        meta[m.$2] = TransactionMetadataText(value: m.$1);
      }
      _metadata = Map<BigInt, TransactionMetadataText>.unmodifiable(meta);
    } finally {
      notify();
      calculateFee();
    }
  }

  void onRemoveMemo(BigInt? label) {
    if (_metadata.containsKey(label)) {
      _metadata.remove(label);
      notify();
      calculateFee();
    }
  }
}
