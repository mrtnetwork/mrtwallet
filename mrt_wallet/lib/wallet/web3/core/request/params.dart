import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/models.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/messages/messages.dart';
import 'package:mrt_wallet/wallet/web3/core/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/networks/aptos/params/core/request.dart';
import 'package:mrt_wallet/wallet/web3/networks/bitcoin/params/core/request.dart';
import 'package:mrt_wallet/wallet/web3/networks/cosmos/params/core/request.dart';
import 'package:mrt_wallet/wallet/web3/networks/ethereum/params/core/request.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/permission.dart';
import 'package:mrt_wallet/wallet/web3/networks/global/global.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/web3/networks/solana/solana.dart';
import 'package:mrt_wallet/wallet/web3/networks/stellar/stellar.dart';
import 'package:mrt_wallet/wallet/web3/networks/substrate/params/core/request.dart';
import 'package:mrt_wallet/wallet/web3/networks/sui/params/core/request.dart';
import 'package:mrt_wallet/wallet/web3/networks/ton/ton.dart';
import 'package:mrt_wallet/wallet/web3/networks/tron/tron.dart';
import 'web_request.dart';

abstract class Web3WalletRequestParams<RESPONSE> extends Web3MessageCore {
  abstract final Web3RequestMethods method;
  const Web3WalletRequestParams();

  Object? toJsWalletResponse(RESPONSE response) {
    return response;
  }

  Object? toPageResponse(RESPONSE response) {
    return response;
  }
}

abstract class Web3GlobalRequestParams<RESPONSE>
    extends Web3WalletRequestParams<RESPONSE> {
  @override
  Web3MessageTypes get type => Web3MessageTypes.walletGlobalRequest;
  const Web3GlobalRequestParams();
  @override
  abstract final Web3GlobalRequestMethods method;

  factory Web3GlobalRequestParams.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: Web3MessageTypes.walletGlobalRequest.tag);
    final network = Web3GlobalRequestMethods.fromId(values.elementAt(0));
    final Web3GlobalRequestParams param;
    switch (network) {
      case Web3GlobalRequestMethods.disconnect:
        param = Web3DisconnectApplication.deserialize(
            bytes: bytes, object: object, hex: hex);
        break;
      case Web3GlobalRequestMethods.connect:
        param = Web3ConnectApplication.deserialize(
            bytes: bytes, object: object, hex: hex);
        break;
      default:
        throw Web3RequestExceptionConst.internalError;
    }
    if (param is! Web3GlobalRequestParams<RESPONSE>) {
      throw Web3RequestExceptionConst.internalError;
    }
    return param;
  }
}

abstract class Web3RequestParams<
    RESPONSE,
    NETWORKADDRESS,
    CHAIN extends APPCHAINNETWORK<NETWORKADDRESS>,
    CHAINACCOUNT extends Web3ChainAccount<NETWORKADDRESS>,
    WEB3ChAIN extends Web3Chain<NETWORKADDRESS, CHAIN, CHAINACCOUNT,
        WalletNetwork>> extends Web3WalletRequestParams<RESPONSE> {
  @override
  abstract final Web3NetworkRequestMethods method;
  abstract final CHAINACCOUNT? account;

  Web3RequestParams();

  @override
  Web3MessageTypes get type => Web3MessageTypes.walletRequest;
  Web3NetworkRequest toRequest(
      {required Web3RequestApplicationInformation request,
      required Web3APPAuthentication authenticated,
      required List<APPCHAIN> chains});
  CHAIN findRequestChain(
      {required Web3RequestApplicationInformation request,
      required Web3APPAuthentication authenticated,
      required List<APPCHAIN> chains}) {
    final web3Chain =
        authenticated.getChainFromNetworkType<WEB3ChAIN>(method.network);
    if (web3Chain == null) {
      throw Web3RequestExceptionConst.bannedHost;
    }
    final networkChains = chains.whereType<CHAIN>().toList();
    return web3Chain.getCurrentPermissionChain(networkChains, account);
  }

  factory Web3RequestParams.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: Web3MessageTypes.walletRequest.tag);
    final network =
        Web3NetworkRequestMethods.fromTag(values.elementAt(0)).network;
    final Web3RequestParams param;
    switch (network) {
      case NetworkType.ethereum:
        param = Web3EthereumRequestParam.deserialize(
            bytes: bytes, object: object, hex: hex);
        break;
      case NetworkType.tron:
        param = Web3TronRequestParam.deserialize(
            bytes: bytes, object: object, hex: hex);
        break;
      case NetworkType.solana:
        param = Web3SolanaRequestParam.deserialize(
            bytes: bytes, object: object, hex: hex);
        break;
      case NetworkType.ton:
        param = Web3TonRequestParam.deserialize(
            bytes: bytes, object: object, hex: hex);
        break;
      case NetworkType.stellar:
        param = Web3StellarRequestParam.deserialize(
            bytes: bytes, object: object, hex: hex);
        break;
      case NetworkType.substrate:
        param = Web3SubstrateRequestParam.deserialize(
            bytes: bytes, object: object, hex: hex);
        break;
      case NetworkType.aptos:
        param = Web3AptosRequestParam.deserialize(
            bytes: bytes, object: object, hex: hex);
        break;
      case NetworkType.sui:
        param = Web3SuiRequestParam.deserialize(
            bytes: bytes, object: object, hex: hex);
        break;
      case NetworkType.cosmos:
        param = Web3CosmosRequestParam.deserialize(
            bytes: bytes, object: object, hex: hex);
        break;
      case NetworkType.bitcoinAndForked:
        param = Web3BitcoinRequestParam.deserialize(
            bytes: bytes, object: object, hex: hex);
        break;
      default:
        throw Web3RequestExceptionConst.internalError;
    }
    if (param is! Web3RequestParams<RESPONSE, NETWORKADDRESS, CHAIN,
        CHAINACCOUNT, WEB3ChAIN>) {
      throw Web3RequestExceptionConst.internalError;
    }
    return param;
  }
}
