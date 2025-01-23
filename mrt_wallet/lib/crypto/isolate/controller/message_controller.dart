import 'dart:async';

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/requets/argruments/argruments.dart';
import 'package:mrt_wallet/crypto/requets/messages/messages.dart';

typedef OnStreamMessage = Function(CborMessageArgs message, int id);

class EncryptedIsolateMessageController {
  EncryptedIsolateMessageController(this.onStreamCallBack);
  final OnStreamMessage onStreamCallBack;
  static const MessageArgsException verificationFailed =
      MessageArgsException("data_verification_failed");

  static T toArgs<T extends CborMessageArgs>(CborMessageArgs args) {
    if (args is! T) {
      throw WalletExceptionConst.dataVerificationFailed;
    }
    return args;
  }

  // String streamId = 0;

  final Map<String, IsolateStreamRequest> streams = {};

  // Map<Subcrive>

  Future<CborMessageArgs> handleMessage(
      {required CborMessageArgs args,
      required int id,
      List<int>? encryptedPart}) async {
    CborMessageArgs result;
    try {
      switch (args.type) {
        case ArgsType.nonEncrypted:
          final NoneEncryptedCryptoRequest msg = toArgs(args);
          result = await msg.getResult(encryptedPart: encryptedPart);
          break;
        case ArgsType.crypto:
          final CryptoRequest msg = toArgs(args);
          result = msg.getResult();
          break;
        case ArgsType.streamRequest:
          final streamId = UUID.generateUUIDv4();
          final IsolateStreamRequest msg = toArgs(args);
          StreamSubscription<MessageArgsStream>? subscription;
          subscription = msg
              .getIsolateResult(
                  streamId: streamId, encryptedPart: encryptedPart)
              .listen(
            (e) {
              onStreamCallBack(e, id);
            },
            onDone: () {
              subscription?.cancel();
              subscription = null;
              final r = streams.remove(streamId);
              assert(r?.closed ?? true, "stream muset be closed!.");
              r?.close();
            },
          );
          streams[streamId] = msg;
          result = MessageArgsStreamId(streamId);
          break;
        case ArgsType.streamArgs:
          final MessageArgsStream msg = toArgs(args);
          final controller = streams[msg.streamId];
          if (controller == null) {
            result = MessageArgsException("stream_does_not_exists");
            break;
          }
          controller.add(msg);
          result = MessageArgsMessage();
          break;
        case ArgsType.wallet:
          final WalletArgs msg = toArgs(args);
          result = msg.getResult();
          break;
        default:
          result = verificationFailed;
          break;
      }
    } on WalletException catch (e) {
      result = MessageArgsException(e.toString());
    } on ApiProviderException catch (e) {
      result = MessageArgsException(e.toString());
    } on BlockchainUtilsException catch (e) {
      result = MessageArgsException(e.message);
    } catch (e) {
      result = verificationFailed;
    }
    return result;
  }
}
