import 'package:on_chain/on_chain.dart';

import 'transaction.dart';

typedef OnAddCardanoMemo = Future<(String, BigInt)?> Function(
    List<BigInt> existsLabel, String? currentTxt);

mixin CardanoTransactionMemoImpl on CardanoTransactionImpl {
  final Map<BigInt, TransactionMetadataText> _metadata = {};
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
      _metadata.remove(current);
      if (m == null) return;
      _metadata[m.$2] = TransactionMetadataText(value: m.$1);
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
