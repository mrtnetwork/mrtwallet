import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/wallet/global/pages/account_state.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

abstract class SubstrateAccountState<W extends StatefulWidget>
    extends ChainAccountState<
        W,
        SubstrateAPIProvider,
        BaseSubstrateAddress,
        TokenCore,
        NFTCore,
        ISubstrateAddress,
        SubstrateClient,
        SubstrateChain,
        WalletTransaction<BaseSubstrateAddress>> {}
