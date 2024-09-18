import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/exception/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/messages/models/models.dart';
import 'package:mrt_wallet/wallet/web3/core/request/params.dart';
import 'message_types.dart';

abstract class Web3MessageCore with CborSerializable, JsonSerialization {
  abstract final Web3MessageTypes type;

  const Web3MessageCore();
  factory Web3MessageCore.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    try {
      final CborTagValue cbor =
          CborSerializable.decode(cborBytes: bytes, hex: hex, object: object);
      final Web3MessageTypes type = Web3MessageTypes.fromTag(cbor.tags);
      switch (type) {
        case Web3MessageTypes.chains:
          return Web3ChainMessage.deserialize(object: cbor);
        case Web3MessageTypes.response:
          return Web3ResponseMessage.deserialize(object: cbor);
        case Web3MessageTypes.walletResponse:
          return Web3WalletResponseMessage.deserialize(object: cbor);
        case Web3MessageTypes.walletRequest:
          return Web3RequestParams.deserialize(object: cbor);
        case Web3MessageTypes.walletGlobalRequest:
          return Web3GlobalRequestParams.deserialize(object: cbor);
        case Web3MessageTypes.error:
          return Web3ExceptionMessage.deserialize(object: cbor);

        default:
          throw Web3RequestExceptionConst.internalError;
      }
    } on Web3RequestException {
      rethrow;
    } catch (_) {
      throw Web3RequestExceptionConst.internalError;
    }
  }
  T cast<T extends Web3MessageCore>() {
    if (this is! T) {
      throw Web3RequestExceptionConst.internalError;
    }
    return this as T;
  }
}
