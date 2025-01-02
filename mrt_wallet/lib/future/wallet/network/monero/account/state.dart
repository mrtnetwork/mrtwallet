import 'package:flutter/material.dart';
import 'package:monero_dart/monero_dart.dart';
import 'package:mrt_wallet/future/wallet/global/pages/account_state.dart';
import 'package:mrt_wallet/wallet/api/api.dart';
import 'package:mrt_wallet/wallet/models/models.dart';

abstract class MoneroAccountState<W extends StatefulWidget>
    extends ChainAccountState<
        W,
        MoneroAPIProvider,
        MoneroAddress,
        TokenCore,
        NFTCore,
        IMoneroAddress,
        MoneroClient,
        MoneroChain,
        MoneroWalletTransaction> {}
