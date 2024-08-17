import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/balance/balance.dart';

import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/wallet/models/token/token.dart';
import 'package:on_chain/tron/tron.dart';

abstract class TronToken implements TokenCore<BigInt> {}

class TronTRC20Token with Equatable implements SolidityToken, TronToken {
  TronTRC20Token._(
      this.balance, this.token, this.contractAddress, this._updated);
  factory TronTRC20Token.create(
      {required BigInt balance,
      required Token token,
      required TronAddress contractAddress}) {
    final Live<IntegerBalance> liveBalance =
        Live(IntegerBalance(balance, token.decimal!));
    return TronTRC20Token._(
        liveBalance, token, contractAddress, DateTime.now());
  }
  factory TronTRC20Token.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue cbor =
          CborSerializable.decodeCborTags(bytes, obj, CborTagsConst.trc20Token);

      final Token token = Token.fromCborBytesOrObject(obj: cbor.getCborTag(0));
      final TronAddress contractAddress = TronAddress(cbor.elementAt(1));
      final Live<IntegerBalance> balance =
          Live(IntegerBalance(cbor.elementAt(2), token.decimal!));
      final DateTime updated = cbor.elementAt(3);
      return TronTRC20Token._(balance, token, contractAddress, updated);
    } on WalletException {
      rethrow;
    } catch (e) {
      throw WalletExceptionConst.invalidTokenInformation;
    }
  }
  TronTRC20Token updateToken(Token updateToken) {
    return TronTRC20Token._(balance, updateToken, contractAddress, _updated);
  }

  @override
  final Live<IntegerBalance> balance;

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
        CborTagsConst.trc20Token);
  }

  @override
  List get variabels => [contractAddress.toAddress()];

  @override
  final Token token;

  @override
  String? get issuer => contractAddress.toAddress();

  @override
  String toHexAddress() {
    return contractAddress.toAddress(false);
  }

  @override
  late final String? type = "trc20";
}
