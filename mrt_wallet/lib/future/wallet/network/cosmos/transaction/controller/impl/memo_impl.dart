import 'transaction.dart';

typedef OnAddCosmosMemo = Future<String?> Function(String?);
mixin CosmosMemoImpl on CosmosTransactiomImpl {
  String? _memo;
  @override
  String? get memo => _memo;
  bool get hasMemo => _memo != null;

  Future<void> onTapMemo(OnAddCosmosMemo onAddMemo) async {
    _memo = await onAddMemo(_memo);
  }
}
