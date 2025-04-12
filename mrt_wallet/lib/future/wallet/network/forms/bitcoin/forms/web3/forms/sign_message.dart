import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/signer/bitcoin/bitcoin_signer.dart';
import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/network/forms/bitcoin/forms/core/bitcoin.dart';
import 'package:mrt_wallet/wallet/models/chain/address/networks/bitcoin/addresses/bitcoin.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/web3/networks/bitcoin/bitcoin.dart';

class Web3BitcoinSignMessageForm
    extends BitcoinWeb3Form<Web3BitcoinSignMessage> {
  Web3BitcoinSignMessageForm({required this.request});

  @override
  Web3BitcoinRequest<Web3BitcoinSignMessageResponse, Web3BitcoinSignMessage>
      request;
  List<int> challengeBytes() {
    return BytesUtils.fromHexString(request.params.message);
  }

  String get message => request.params.message;
  String? get content => request.params.content;
  late final String messagePrefix =
      request.params.messagePrefix ?? BitcoinSignerUtils.signMessagePrefix;
  BIP137Mode _mode = BIP137Mode.p2pkhCompressed;
  BIP137Mode get mode => _mode;

  Future<void> signMessage(FuncFutureNullableBoold confirm) async {
    final accept = await confirm();
    if (accept != true) return;
    onCompleteForm?.call(_mode);
  }

  @override
  Future<void> initForm(
      {required BitcoinChain account,
      required IBitcoinAddress? address}) async {
    await super.initForm(account: account, address: address);
    switch (this.address.networkAddress.type) {
      case P2pkhAddressType.p2pkh:
      case P2pkhAddressType.p2pkhwt:
        if (!this.address.keyType.isCompressed) {
          _mode = BIP137Mode.p2pkhUncompressed;
        }
        break;
      case P2shAddressType.p2wpkhInP2sh:
        _mode = BIP137Mode.p2shP2wpkh;
        break;
      case SegwitAddressType.p2wpkh:
        _mode = BIP137Mode.p2wpkh;
        break;
      default:
        throw Web3BitcoinExceptionConstant.invalidSignMessageAccount(
            this.address.orginalAddress);
    }
  }
}
