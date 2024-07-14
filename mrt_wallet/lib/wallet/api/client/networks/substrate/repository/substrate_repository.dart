import 'package:mrt_wallet/app/dev/logging.dart';
import 'package:mrt_wallet/wallet/api/client/core/client.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/substrate.dart';
import 'package:mrt_wallet/wallet/models/account/address/networks/substrate/substrate.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

class _SubstrateRepositoryConst {
  static const String metadata = "metadata";
  static const String genesis = "genesis";
}

mixin SubstrateRepository
    on NetworkClient<ISubstrateAddress, SubstrateAPIProvider> {
  Future<void> writeMetadata(String metada) async {
    await write(key: _SubstrateRepositoryConst.metadata, value: metada);
  }

  Future<MetadataApi?> loadApi() async {
    try {
      final data = await read(_SubstrateRepositoryConst.metadata);
      if (data != null) {
        final versioned = VersionedMetadata.fromHex(data);
        return versioned.toApi();
      }
    } catch (e) {
      WalletLogging.debugPrint("cannot load api from storage $e");
    }
    return null;
  }

  Future<void> writeGenesis(String genesis) async {
    await write(key: _SubstrateRepositoryConst.genesis, value: genesis);
  }

  Future<String?> loadGenesis() async {
    return await read(_SubstrateRepositoryConst.genesis);
  }
}
