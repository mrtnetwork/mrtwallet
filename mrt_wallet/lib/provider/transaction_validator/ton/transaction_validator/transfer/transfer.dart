import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/app/utility/blockchin_utils/ton/ton_utils.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/provider/transaction_validator/core/validator_fields.dart';
import 'package:mrt_wallet/provider/transaction_validator/ton/transaction_validator/core/core.dart';
import 'package:mrt_wallet/types/typedef.dart';
import 'package:ton_dart/ton_dart.dart';

class TonTransferValidator extends TonTransactionValidator {
  final APPTonNetwork network;

  TonTransferValidator({required this.network});
  final ValidatorField<List<TonOutputWithBalance>> destination = ValidatorField(
      name: "destination",
      optional: false,
      onChangeValidator: (p0) {
        return p0;
      });
  final Map<TonJettonToken, BigInt> tokens = {};

  BigInt _getTokenSpenBalance(TonJettonToken token) {
    final values = destination.value
        ?.where((element) => element.hasToken && element.jetton == token);

    return values?.fold<BigInt>(
            BigInt.zero,
            (previousValue, element) =>
                element.tokenBalance.balance + previousValue) ??
        BigInt.zero;
  }

  void _calcTokenBalances(TonJettonToken? token) {
    if (token == null) return;
    final newBlanace =
        _getTokenSpenBalance(token) + (tokens[token] ?? BigInt.zero);
    tokens[token] = newBlanace;
  }

  BigInt getActiveTokenBalance(TonOutputWithBalance output) {
    final spendedValue = tokens[output.jetton]! - output.tokenBalance.balance;
    return output.jetton!.balance.value.balance - spendedValue;
  }

  @override
  BigInt get callValue =>
      destination.value?.fold(
          BigInt.zero,
          (previousValue, element) =>
              previousValue! + element.balance.balance) ??
      BigInt.zero;

  @override
  List<ValidatorField> get fields => throw UnimplementedError();

  @override
  @override
  String get name => "transfer".tr;

  void setReceiver(
      {required ReceiptAddress<TonAddress>? address,
      required DynamicVoid onExists}) {
    if (address == null) return;

    final bool exists = destination.value?.any((element) =>
            element.address.networkAddress == address.networkAddress) ??
        false;
    if (exists) {
      onExists.call();
      return;
    }
    if (destination.setValue([
      ...destination.value ?? <TonOutputWithBalance>[],
      TonOutputWithBalance(address: address, network: network),
    ])) {
      onChanged?.call();
    }
  }

  void onRemoveReceiver(TonAddress? address, bool? remove) {
    if (address == null || remove != true) return;
    final dest = MethodCaller.nullOnException(() => destination.value
        ?.firstWhere((element) => element.address.networkAddress == address));
    if (dest == null) return;
    destination.setValue(List.from(destination.value
            ?.where((element) => element.address.networkAddress != address)
            .toList() ??
        []));
    _calcTokenBalances(dest.jetton);
    onChanged?.call();
    final isValid = validateError();
    if (isValid == null) {
      final int hashCode = destination.value.hashCode;
      onReadyField?.call(hashCode.toString());
    }
  }

  void setBalance(TonAddress address, BigInt? balance) {
    if (balance == null) return;
    try {
      final des = MethodCaller.nullOnException(() => destination.value
          ?.firstWhere((element) => element.address.networkAddress == address));
      if (des == null) return;
      des.updateBalance(balance);
      onChanged?.call();
      final isValid = validateError();
      if (isValid == null) {
        final int hashCode = destination.value.hashCode;
        onReadyField?.call(hashCode.toString());
      }
      // ignore: empty_catches
    } on StateError {}
  }

  void setForwardBalance(TonAddress address, BigInt? balance) {
    if (balance == null) return;
    try {
      final des = MethodCaller.nullOnException(() => destination.value
          ?.firstWhere((element) => element.address.networkAddress == address));
      if (des == null) return;
      des.updateForwardBalance(balance);
      onChanged?.call();
      final isValid = validateError();
      if (isValid == null) {
        final int hashCode = destination.value.hashCode;
        onReadyField?.call(hashCode.toString());
      }
      // ignore: empty_catches
    } on StateError {}
  }

  void setQueryId(TonAddress address, BigRational? queryId) {
    if (queryId == null) return;
    try {
      final des = MethodCaller.nullOnException(() => destination.value
          ?.firstWhere((element) => element.address.networkAddress == address));
      if (des == null) return;
      des.updateQueryId(queryId.toBigInt());
      onChanged?.call();
      final isValid = validateError();
      if (isValid == null) {
        final int hashCode = destination.value.hashCode;
        onReadyField?.call(hashCode.toString());
      }
      // ignore: empty_catches
    } on StateError {}
  }

  void setJettonBalance(TonAddress address, BigInt? balance) {
    if (balance == null) return;
    try {
      final des = MethodCaller.nullOnException(() => destination.value
          ?.firstWhere((element) => element.address.networkAddress == address));
      if (des == null) return;
      des.updateJettonBalance(balance);
      onChanged?.call();
      _calcTokenBalances(des.jetton);
      final isValid = validateError();
      if (isValid == null) {
        final int hashCode = destination.value.hashCode;
        onReadyField?.call(hashCode.toString());
      }
      // ignore: empty_catches
    } on StateError {}
  }

  void setJetton(TonAddress address, TonJettonToken? jetton) {
    try {
      final des = MethodCaller.nullOnException(() => destination.value
          ?.firstWhere((element) => element.address.networkAddress == address));
      if (des == null) return;
      des.setToken(jetton);
      _calcTokenBalances(jetton);
      onChanged?.call();
      final isValid = validateError();
      if (isValid == null) {
        final int hashCode = destination.value.hashCode;
        onReadyField?.call(hashCode.toString());
      }
      // ignore: empty_catches
    } on StateError {}
  }

  String? queryIdValidator(String? v) {
    if (TonUtils.isValidQueryId(BigInt.parse(v ?? ""))) return null;
    return "ton_query_id_validator".tr;
  }

  @override
  void setValue<T>(ValidatorField<T>? field, T? value) {
    onChanged?.call();
  }

  void updateMessage(bool? updated) {
    if (updated == true) {
      onChanged?.call();
      final isValid = validateError();
      if (isValid == null) {
        final int hashCode = destination.value.hashCode;
        onReadyField?.call(hashCode.toString());
      }
    }
  }

  @override
  String? validateError({ITonAddress? account}) {
    if (destination.value?.isEmpty ?? true) {
      return "add_least_one_receipt".tr;
    }
    for (final i in destination.value!) {
      if (!i.hasAmount) {
        return "the_amount_is_unspecified".tr;
      }
      if (i.hasToken && !i.hasTokenAmount) {
        return "the_jetton_amount_is_unspecified".tr;
      }
      if (i.hasToken) {
        if (i.balance.balance <= i.forwardBalance.balance) {
          return "ton_total_amount_validator".tr;
        }
      }
    }

    return null;
  }

  @override
  List<MessageRelaxed> toMessages(TonAddress account) {
    return destination.value!
        .map((e) => e.toMessage(network, account))
        .toList();
  }
}
