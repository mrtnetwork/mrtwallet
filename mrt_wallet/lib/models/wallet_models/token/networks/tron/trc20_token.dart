import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';
import 'package:on_chain/on_chain.dart';

class TronTRC20Token with Equatable implements SolidityToken {
  TronTRC20Token._(
      this.balance, this.token, this.contractAddress, this._updated);
  factory TronTRC20Token.create(
      {required BigInt balance,
      required Token token,
      required TronAddress contractAddress}) {
    final Live<NoneDecimalBalance> liveBalance =
        Live(NoneDecimalBalance(balance, token.decimal!));
    return TronTRC20Token._(
        liveBalance, token, contractAddress, DateTime.now());
  }
  factory TronTRC20Token.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue cbor = CborSerializable.decodeCborTags(
          bytes, obj, WalletModelCborTagsConst.trc20Token);

      final Token token = Token.fromCborBytesOrObject(obj: cbor.getCborTag(0));
      final TronAddress contractAddress = TronAddress(cbor.getIndex(1));
      final Live<NoneDecimalBalance> balance =
          Live(NoneDecimalBalance(cbor.getIndex(2), token.decimal!));
      final DateTime updated = cbor.getIndex(3);
      return TronTRC20Token._(balance, token, contractAddress, updated);
    } on WalletException {
      rethrow;
    } catch (e) {
      throw WalletExceptionConst.invalidTokenInformation;
    }
  }

  @override
  final Live<NoneDecimalBalance> balance;

  DateTime _updated;

  @override
  DateTime get updated => _updated;

  final TronAddress contractAddress;
  @override
  void updateBalance([BigInt? updateBalance]) {
    balance.value.updateBalance(updateBalance);
    if (updateBalance != null) {
      _updated = DateTime.now().toLocal();
      balance.notify();
    }
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          token.toCbor(),
          contractAddress.toAddress(),
          balance.value.balance,
          CborEpochIntValue(_updated)
        ]),
        WalletModelCborTagsConst.trc20Token);
  }

  @override
  List get variabels => [token, contractAddress.toAddress()];

  @override
  final Token token;

  @override
  String? get issuer => contractAddress.toAddress();

  @override
  String toHex() {
    return contractAddress.toAddress(false);
  }

  @override
  late final String? type = "trc20";
}
