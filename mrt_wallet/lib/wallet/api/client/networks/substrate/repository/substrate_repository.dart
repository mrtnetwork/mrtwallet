import 'package:mrt_wallet/wallet/api/client/core/client.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/substrate.dart';
import 'package:mrt_wallet/wallet/models/chain/address/networks/substrate/substrate.dart';

mixin SubstrateRepository
    on NetworkClient<ISubstrateAddress, SubstrateAPIProvider> {}
