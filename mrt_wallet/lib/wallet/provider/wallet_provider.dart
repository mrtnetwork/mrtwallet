library wallet_provier;

import 'dart:async';
import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/bip/bip/bip32/base/bip32_base.dart';
import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/global/global.dart';
import 'package:mrt_wallet/future/wallet/security/security.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/api/api.dart';
import 'package:mrt_wallet/wallet/chain/handler/chain.dart';
// import 'package:mrt_wallet/app/lifecycle/cross/life_cycle_tracker.dart';
import 'package:mrt_wallet/repository/repository.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/wallet/models/models.dart';
import 'package:mrt_wallet/wallet/utils/global/utils.dart';
import 'package:mrt_wallet/wallet/utils/ripple/ripple.dart';

import 'package:on_chain/on_chain.dart';
import 'package:on_chain/solana/solana.dart';
import 'package:ton_dart/ton_dart.dart';
import 'package:xrpl_dart/xrpl_dart.dart';
import 'package:flutter/material.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';

part 'crypto/crypto_impl.dart';
part 'network/network_imp.dart';
part 'status/status_impl.dart';
part 'core/core.dart';
part 'crypto/master_key.dart';
part 'signer/signer_impl.dart';
part 'storage/storage_impl.dart';
