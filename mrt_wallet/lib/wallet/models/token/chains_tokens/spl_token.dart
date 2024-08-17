import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/balance/balance.dart';

import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/wallet/models/token/token.dart';
import 'package:on_chain/solana/solana.dart';

class SolanaSPLToken with Equatable implements TokenCore<BigInt> {
  SolanaSPLToken._(this.balance, this.token, this.mint, this.tokenAccount,
      this._updated, this.tokenOwner);
  factory SolanaSPLToken.create({
    required BigInt balance,
    required Token token,
    required SolAddress mint,
    required SolAddress tokenAccount,
    required SolAddress tokenOwner,
  }) {
    final Live<IntegerBalance> liveBalance =
        Live(IntegerBalance(balance, token.decimal!));
    return SolanaSPLToken._(
        liveBalance, token, mint, tokenAccount, DateTime.now(), tokenOwner);
  }
  factory SolanaSPLToken.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue cbor =
          CborSerializable.decodeCborTags(bytes, obj, CborTagsConst.spltoken);

      final Token token = Token.fromCborBytesOrObject(obj: cbor.getCborTag(0));
      final String mint = cbor.elementAt(1);
      final Live<IntegerBalance> balance =
          Live(IntegerBalance(cbor.elementAt(2), token.decimal!));
      final DateTime updated = cbor.elementAt(3);
      final String tokenAccount = cbor.elementAt(4);
      final String tokenOwner = cbor.elementAt(5);
      return SolanaSPLToken._(
        balance,
        token,
        SolAddress(mint),
        SolAddress(tokenAccount),
        updated,
        SolAddress(tokenOwner),
      );
    } on WalletException {
      rethrow;
    } catch (e) {
      throw WalletExceptionConst.invalidTokenInformation;
    }
  }

  SolanaSPLToken updateToken(Token updateToken) {
    return SolanaSPLToken._(
        Live(IntegerBalance(balance.value.balance, updateToken.decimal!)),
        updateToken,
        mint,
        tokenAccount,
        _updated,
        tokenOwner);
  }

  @override
  final Live<IntegerBalance> balance;

  DateTime _updated;

  @override
  DateTime get updated => _updated;

  final SolAddress mint;
  final SolAddress tokenAccount;
  final SolAddress tokenOwner;
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
          mint.address,
          balance.value.balance,
          CborEpochIntValue(_updated),
          tokenAccount.address,
          tokenOwner.address
        ]),
        CborTagsConst.spltoken);
  }

  @override
  List get variabels => [mint.address, tokenAccount.address];

  @override
  final Token token;

  @override
  String? get issuer => mint.address;

  @override
  late final String? type = "SPL";
}
