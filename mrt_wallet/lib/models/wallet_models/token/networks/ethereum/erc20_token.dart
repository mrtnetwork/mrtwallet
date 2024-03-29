import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';
import 'package:on_chain/on_chain.dart';

class ETHERC20Token with Equatable implements SolidityToken {
  ETHERC20Token._(
      this.balance, this.token, this.contractAddress, this._updated);
  factory ETHERC20Token.create(
      {required BigInt balance,
      required Token token,
      required ETHAddress contractAddress}) {
    final Live<NoneDecimalBalance> liveBalance =
        Live(NoneDecimalBalance(balance, token.decimal!));
    return ETHERC20Token._(liveBalance, token, contractAddress, DateTime.now());
  }
  factory ETHERC20Token.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue cbor = CborSerializable.decodeCborTags(
          bytes, obj, WalletModelCborTagsConst.erc20Token);

      final Token token = Token.fromCborBytesOrObject(obj: cbor.getCborTag(0));
      final ETHAddress contractAddress = ETHAddress(cbor.getIndex(1));
      final Live<NoneDecimalBalance> balance =
          Live(NoneDecimalBalance(cbor.getIndex(2), token.decimal!));
      final DateTime updated = cbor.getIndex(3);
      return ETHERC20Token._(balance, token, contractAddress, updated);
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

  final ETHAddress contractAddress;
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
          contractAddress.address,
          balance.value.balance,
          CborEpochIntValue(_updated)
        ]),
        WalletModelCborTagsConst.erc20Token);
  }

  @override
  List get variabels => [token, contractAddress.address];

  @override
  final Token token;

  @override
  String? get issuer => contractAddress.address;

  @override
  String toHex() {
    return contractAddress.toHex();
  }

  @override
  late final String? type = "erc20";
}
