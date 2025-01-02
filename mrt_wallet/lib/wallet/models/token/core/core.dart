import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/error/exception.dart';
import 'package:mrt_wallet/app/live_listener/live.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/wallet/constant/constant.dart';
import 'package:mrt_wallet/wallet/models/balance/core/balance.dart';
import 'package:mrt_wallet/wallet/models/token/chains_tokens/trc10.dart';
import 'package:mrt_wallet/wallet/models/token/chains_tokens/trc20.dart';
import 'package:mrt_wallet/wallet/models/token/token/token.dart';

abstract class TokenCore<T> with CborSerializable {
  abstract final Token token;
  abstract final Live<BalanceCore<T>> balance;
  void updateBalance([T? updateBalance]);
  abstract final DateTime updated;
  String? get issuer;
  String? get type;
}

abstract class SolidityToken implements TokenCore<BigInt> {
  String toHexAddress();
}

enum TronTokenTypes {
  trc20(CborTagsConst.trc20Token),
  trc10(CborTagsConst.trc10Token);

  final List<int> tag;
  const TronTokenTypes(this.tag);
  static TronTokenTypes fromTag(List<int>? tag) {
    return values.firstWhere(
      (e) => BytesUtils.bytesEqual(e.tag, tag),
      orElse: () => throw WalletExceptionConst.invalidAccountDetails,
    );
  }

  bool get isTrc10 => this == TronTokenTypes.trc10;
}

abstract class TronToken implements TokenCore<BigInt> {
  TronToken updateToken(Token updateToken);
  @override
  String get issuer;
  TronTokenTypes get tronTokenType;
  factory TronToken.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborTagValue decode =
        CborSerializable.decode(cborBytes: bytes, object: object, hex: hex);
    final type = TronTokenTypes.fromTag(decode.tags);
    return switch (type) {
      TronTokenTypes.trc10 => TronTRC10Token.fromCborBytesOrObject(obj: decode),
      TronTokenTypes.trc20 => TronTRC20Token.fromCborBytesOrObject(obj: object)
    };
  }
}
