import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';
import 'package:mrt_wallet/wallet/models/balance/balance.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/models/chain/address/networks/cosmos/cosmos.dart';
import 'package:mrt_wallet/wallet/models/networks/cosmos/cosmos.dart';
import 'package:mrt_wallet/wallet/models/others/models/receipt_address.dart';
import 'package:mrt_wallet/wallet/models/token/chains_tokens/cw20.dart';

// enum IbcTransferPage{}
class CosmosIbcTransferForm extends CosmosTransactionForm {
  BigInt _callValue = BigInt.zero;
  Map<CW20Token, IntegerBalance> remindTokenAmounts = {};
  CosmosTransactionFeeInfo? _feeInfo;
  @override
  void setFeeToken(CosmosTransactionFeeInfo fee) {
    _feeInfo = fee;
    _checkValue();
  }

  @override
  BigInt get callValue => _callValue;
  void _checkValue() {
    _callValue = destinations.value.fold<BigInt>(BigInt.zero,
        (previousValue, element) => previousValue + element.nativeAmount);
    final tokens = remindTokenAmounts.keys.toList();
    for (final i in tokens) {
      final tokenDestinations = destinations.value.where((e) => e.token == i);
      BigInt amount =
          tokenDestinations.fold(BigInt.zero, (p, c) => p + c.balance.balance);
      if (_feeInfo?.customFeeToken == i) {
        amount += _feeInfo?.feeAmount.balance ?? BigInt.zero;
      }
      remindTokenAmounts[i]!.updateBalance(i.balance.value.balance - amount);
    }
  }

  final TransactionListFormField<CosmosIbcOutputWithBalance> destinations =
      TransactionListFormField(
          name: "destination",
          optional: false,
          onChangeForm: (p0) {
            return p0;
          });

  void setDestinationChain(CosmosIbcChainData chain) {
    destinations.addValue(
        CosmosIbcOutputWithBalance(chainData: chain, network: network));
    notify();
  }

  void setReceiver(CosmosIbcOutputWithBalance destination,
      ReceiptAddress<CosmosBaseAddress>? address) {
    if (address == null) return;
    destination.setAddress(address);
    notify();
  }

  void onRemoveReceiver(CosmosIbcOutputWithBalance? address) {
    final r = destinations.removeValue(address);
    if (!r) return;
    _checkValue();
    notify();
  }

  void setBalance(CosmosIbcOutputWithBalance destination, BigInt? balance) {
    if (balance == null || !destinations.value.contains(destination)) return;
    destination.updateBalance(balance);
    _checkValue();
    notify();
  }

  void setMemo(CosmosIbcOutputWithBalance destination, String? memo) {
    if (!destinations.value.contains(destination)) return;
    destination.setMemo(memo);
    notify();
  }

  void setChannelId(CosmosIbcOutputWithBalance destination, String? channelId) {
    if (!destinations.value.contains(destination)) return;
    destination.setChannelId(channelId);
    notify();
  }

  void setTimeout(CosmosIbcOutputWithBalance destination, TimeOfDay? time) {
    if (!destinations.value.contains(destination)) return;
    if (time == null) return;
    DateTime dateTime = DateTime.now();
    if (time.isBefore(DateTime.now().toLocal().timeOfDay())) {
      dateTime = DateTime.now().toLocal().add(const Duration(days: 1));
    }
    dateTime = dateTime.copyWith(hour: time.hour, minute: time.minute);
    destination.setTimeout(dateTime);
    notify();
  }

  @override
  String get name => "ibc_transfer";

  Future<void> onTapMemo(
      CosmosIbcOutputWithBalance destination, OnAddCosmosMemo onAddMemo) async {
    final String? currentMemo = destination.memo;
    final memo = await onAddMemo(currentMemo);
    if (memo != currentMemo) {
      destination.setMemo(memo);
      notify();
    }
  }

  void setToken(CosmosIbcOutputWithBalance destination, CW20Token? token) {
    if (token == null) return;
    destination.setToken(token, network);
    if (destination.isTokenTransfer) {
      remindTokenAmounts[destination.token!] ??=
          IntegerBalance.zero(token.token.decimal!);
    }
    _checkValue();
    notify();
  }

  @override
  String? validateError({ICosmosAddress? account}) {
    if (destinations.value.isEmpty) {
      return "add_least_one_receipt".tr;
    }
    for (final i in remindTokenAmounts.values) {
      if (i.isNegative) return "insufficient_token_balance".tr;
    }
    for (final i in destinations.value) {
      if (!i.hasAmount) {
        return "the_amount_is_unspecified".tr;
      }
      if (i.channelId == null) {
        return "channel_id_required".tr;
      }
      if (i.address == null) {
        return "receipt_address_is_required".tr;
      }
    }

    return null;
  }

  BigInt max(
      {required ICosmosAddress address,
      required BigInt fee,
      required CosmosIbcOutputWithBalance destination}) {
    if (destination.isTokenTransfer) {
      return remindTokenAmounts[destination.token]!.balance +
          destination.balance.balance;
    }

    return (address.address.currencyBalance -
        callValue -
        fee +
        destination.balance.balance);
  }

  @override
  List<ServiceMessage> messages(CosmosBaseAddress signer) {
    return destinations.value.map((e) => e.toMessage(signer, network)).toList();
  }

  @override
  void close() {
    _callValue = BigInt.zero;
    remindTokenAmounts.clear();
    _feeInfo = null;
    destinations.clear();
    super.close();
  }
}
