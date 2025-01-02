import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/wallet/api/api.dart';
import 'package:mrt_wallet/wallet/models/models.dart';

abstract class ChainAccountState<
        W extends StatefulWidget,
        PROVIDER extends APIProvider,
        NETWORKADDRESS,
        T extends TokenCore,
        N extends NFTCore,
        ADDRESS extends ChainAccount<NETWORKADDRESS, T, N>,
        CL extends NetworkClient<ADDRESS, PROVIDER>,
        CHAIN extends APPCHAINACCOUNTCLIENT<ADDRESS, PROVIDER, CL, T, N>,
        TRANSACTION extends WalletTransaction<NETWORKADDRESS>> extends State<W>
    with SafeState<W> {
  CHAIN get account;
  ADDRESS get address => account.address;
  List<ADDRESS> get addresses => account.addresses;
  List<T> get addressTokens => address.tokens;
  CL get client => account.client;
  Future<List<TRANSACTION>> readTxes() async {
    final txes = await account.getTransactions(address);
    return txes.transactions.cast();
  }
}
