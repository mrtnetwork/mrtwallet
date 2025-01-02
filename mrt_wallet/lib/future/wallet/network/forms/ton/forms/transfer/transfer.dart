import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/validator/field.dart';
import 'package:mrt_wallet/future/wallet/network/forms/ton/forms/core/ton.dart';
import 'package:mrt_wallet/crypto/utils/ton/ton.dart';
import 'package:ton_dart/ton_dart.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

class TonTransferForm extends TonTransactionForm {
  final WalletTonNetwork network;

  TonTransferForm({required this.network});
  final TransactionListFormField<TonOutputWithBalance> destination =
      TransactionListFormField(
          name: "destination",
          optional: false,
          onChangeForm: (p0) {
            return p0;
          });
  final Map<TonJettonToken, BigInt> tokens = {};

  BigInt _getTokenSpenBalance(TonJettonToken token) {
    final values = destination.value
        .where((element) => element.hasToken && element.jetton == token);

    return values.fold<BigInt>(
        BigInt.zero,
        (previousValue, element) =>
            element.tokenBalance.balance + previousValue);
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
  BigInt get callValue => destination.value.fold<BigInt>(BigInt.zero,
      (previousValue, element) => previousValue + element.balance.balance);

  List<TransactionFormField> get fields => throw UnimplementedError();

  @override
  @override
  String get name => "transfer".tr;

  bool _setReceiver(ReceiptAddress<TonAddress> address) {
    final bool exists = destination.value.any(
        (element) => element.address.networkAddress == address.networkAddress);
    if (exists) {
      return false;
    }
    destination
        .addValue(TonOutputWithBalance(address: address, network: network));
    return true;
  }

  void setReceiver(
      {required List<ReceiptAddress<TonAddress>>? address,
      required DynamicVoid onExists}) {
    if (address == null || address.isEmpty) return;
    bool allAdded = true;
    for (final i in address) {
      allAdded &= _setReceiver(i);
    }
    if (!allAdded) {
      onExists.call();
    }
    onChanged?.call();
  }

  void onRemoveReceiver(TonOutputWithBalance? address, bool? remove) {
    if (address == null || remove != true) return;
    destination.removeValue(address);
    _calcTokenBalances(address.jetton);
    onChanged?.call();
  }

  void setBalance(TonOutputWithBalance address, BigInt? balance) {
    if (balance == null) return;
    address.updateBalance(balance);
    onChanged?.call();
  }

  void setForwardBalance(TonOutputWithBalance address, BigInt? balance) {
    if (balance == null) return;
    address.updateForwardBalance(balance);
    onChanged?.call();
  }

  void setQueryId(TonOutputWithBalance address, BigRational? queryId) {
    if (queryId == null) return;
    address.updateQueryId(queryId.toBigInt());
    onChanged?.call();
  }

  void setJettonBalance(TonOutputWithBalance address, BigInt? balance) {
    if (balance == null) return;
    address.updateJettonBalance(balance);
    onChanged?.call();
    _calcTokenBalances(address.jetton);
  }

  void setJetton(TonOutputWithBalance address, TonJettonToken? jetton) {
    address.setToken(jetton);
    _calcTokenBalances(jetton);
    onChanged?.call();
  }

  String? queryIdForm(String? v) {
    if (TonUtils.isValidQueryId(BigInt.parse(v ?? ""))) return null;
    return "ton_query_id_validator".tr;
  }

  void setValue<T>(TransactionFormField<T>? field, T? value) {
    onChanged?.call();
  }

  void updateMessage(bool? updated) {
    if (updated == true) {
      onChanged?.call();
    }
  }

  @override
  String? validateError({ITonAddress? account}) {
    if (destination.value.isEmpty) {
      return "add_least_one_receipt".tr;
    }
    for (final i in destination.value) {
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
    return destination.value.map((e) => e.toMessage(network, account)).toList();
  }
}
