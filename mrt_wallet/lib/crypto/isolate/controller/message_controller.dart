import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/requets/argruments/argruments.dart';
import 'package:mrt_wallet/crypto/requets/messages/core/message.dart';
import 'package:mrt_wallet/crypto/requets/messages/models/models.dart';

class IsolateMessageController {
  const IsolateMessageController();
  static const MessageArgsException verificationFailed =
      MessageArgsException("data_verification_failed");

  static T toArgs<T extends MessageArgs>(MessageArgs args) {
    if (args is! T) {
      throw WalletExceptionConst.dataVerificationFailed;
    }
    return args;
  }

  WorkerResponseMessage handleMessage(List<int> message, int id) {
    MessageArgs result;
    try {
      final workerMessage = WorkerRequestMessage.deserialize(message);
      final type = workerMessage.message;
      switch (type) {
        case CryptoMessageType.cryptoRequest:
          final CryptoArgs msg = toArgs(workerMessage.args);
          result = msg.args.getResult();
        case CryptoMessageType.walletRequest:
          final WalletArgs msg = toArgs(workerMessage.args);
          result = msg.getResult();
        default:
          result = verificationFailed;
          break;
      }
    } on WalletException catch (e) {
      result = MessageArgsException(e.message);
    } catch (e) {
      result = verificationFailed;
    }
    return WorkerResponseMessage(args: result, id: id);
  }
}
