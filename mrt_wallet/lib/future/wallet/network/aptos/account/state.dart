import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/wallet/global/pages/account_state.dart';
import 'package:mrt_wallet/wallet/api/api.dart';
import 'package:mrt_wallet/wallet/models/models.dart';
import 'package:on_chain/aptos/src/address/address/address.dart';

abstract class AptosAccountState<W extends StatefulWidget>
    extends ChainAccountState<
        W,
        AptosAPIProvider,
        AptosAddress,
        AptosFATokens,
        NFTCore,
        IAptosAddress,
        AptosClient,
        AptosChain,
        WalletTransaction<AptosAddress>> {}
