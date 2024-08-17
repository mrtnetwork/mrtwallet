import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/request/params.dart';
import 'package:mrt_wallet/wallet/web3/networks/ethereum/permission/models/permission.dart';
import 'package:mrt_wallet/wroker/models/networks.dart';
import 'account.dart';
import '../models/activity.dart';

typedef Web3ChainNetwork<NETWORKADDRESS> = Web3Chain<NETWORKADDRESS,
    APPCHAINNETWORK<NETWORKADDRESS>, Web3ChainAccount<NETWORKADDRESS>>;

abstract class Web3Chain<
        NETWORKADDRESS,
        CHAIN extends APPCHAINNETWORK<NETWORKADDRESS>,
        CHAINACCOUT extends Web3ChainAccount<NETWORKADDRESS>>
    with CborSerializable {
  List<CHAINACCOUT> _accounts;
  List<CHAINACCOUT> get accounts => _accounts;
  List<CHAINACCOUT> currentChainAccounts(CHAIN chain);
  List<Web3AccountAcitvity> _activities;
  List<Web3AccountAcitvity> get activities => _activities;
  abstract final NetworkType network;
  bool hasPermission(CHAIN chain);
  Web3Chain(
      {required List<CHAINACCOUT> accounts,
      required List<Web3AccountAcitvity> activities})
      : _accounts = accounts.imutable,
        _activities = activities.imutable;

  factory Web3Chain.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborTagValue decode =
        CborSerializable.decode(cborBytes: bytes, hex: hex, object: object);
    final network = NetworkType.fromTag(decode.tags);
    Web3Chain chain;
    switch (network) {
      case NetworkType.ethereum:
        chain = Web3EthereumChain.deserialize(object: decode);
        break;
      default:
        throw WalletExceptionConst.unsuportedFeature;
    }
    if (chain is! Web3Chain<NETWORKADDRESS, CHAIN, CHAINACCOUT>) {
      throw WalletExceptionConst.dataVerificationFailed;
    }
    return chain;
  }
  NETWORKCHAINACCOUNT<NETWORKADDRESS> getAccountPermission(
      {required NETWORKADDRESS address, required CHAIN chain});
  CHAINACCOUT? getPermission(NETWORKADDRESS address);

  Web3Chain clone();

  Web3Chain disconnect();

  void addActivity({required Web3RequestParams param, String? url}) {
    String? address;
    if (param.account != null) {
      address = getPermission(param.account)?.addressStr;
      if (address == null) {
        throw Web3RequestExceptionConst.internalError;
      }
    }
    final newAcctivity = Web3AccountAcitvity(
        method: param.method.name, url: url, address: address);
    _activities = [newAcctivity, ..._activities].imutable;
  }

  void updateChainAccount(List<CHAINACCOUT> updatedAccounts) {
    _accounts = updatedAccounts.imutable;
  }
}
