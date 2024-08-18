import 'package:blockchain_utils/bip/mnemonic/mnemonic.dart';
import 'package:blockchain_utils/bip/ton/ton.dart';
import 'package:blockchain_utils/utils/binary/binary_operation.dart';
import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/crypto/utils/global/utils.dart';
import 'package:ton_dart/ton_dart.dart';

class TonUtils {
  static WalletContract fromVersion({
    required List<int> publicKey,
    required int workChain,
    required WalletVersion version,
    required bool bouncable,
    int? subWalletId,
  }) {
    switch (version) {
      case WalletVersion.v1R1:
        return WalletV1R1.create(
          workChain: workChain,
          publicKey: publicKey,
          bounceableAddress: bouncable,
        );
      case WalletVersion.v1R2:
        return WalletV1R2.create(
          workChain: workChain,
          publicKey: publicKey,
          bounceableAddress: bouncable,
        );
      case WalletVersion.v1R3:
        return WalletV1R3.create(
          workChain: workChain,
          publicKey: publicKey,
          bounceableAddress: bouncable,
        );
      case WalletVersion.v2R1:
        return WalletV2R1.create(
          workChain: workChain,
          publicKey: publicKey,
          bounceableAddress: bouncable,
        );
      case WalletVersion.v2R2:
        return WalletV2R2.create(
          workChain: workChain,
          publicKey: publicKey,
          bounceableAddress: bouncable,
        );
      case WalletVersion.v3R1:
        return WalletV3R1.create(
          workChain: workChain,
          publicKey: publicKey,
          subWalletId: subWalletId,
          bounceableAddress: bouncable,
        );
      case WalletVersion.v3R2:
        return WalletV3R2.create(
          workChain: workChain,
          publicKey: publicKey,
          subWalletId: subWalletId,
          bounceableAddress: bouncable,
        );
      case WalletVersion.v4:
        return WalletV4.create(
          workChain: workChain,
          publicKey: publicKey,
          subWalletId: subWalletId,
          bounceableAddress: bouncable,
        );
      default:
        throw WalletExceptionConst.unsuportedFeature;
    }
  }

  static bool isValidTonMnemonicLength(String? mnemonic) {
    if (mnemonic == null) return false;
    final List<String> toList = BlockchainUtils.normalizeMnemonic(mnemonic);
    return toList.length >= 8 && toList.length <= 48;
  }

  static TonPrivateKey generateTonPrivateKeyFromSeed(
      {required String mnemonic,
      String? password,
      bool validateTonMnemonic = true}) {
    try {
      final mn = Mnemonic.fromString(mnemonic);
      final seed = TonSeedGenerator(mn).generate(
          password: password ?? "", validateTonMnemonic: validateTonMnemonic);
      return TonPrivateKey.fromBytes(seed);
    } catch (e) {
      throw WalletExceptionConst.invalidMnemonic;
    }
  }

  static String generateTonMnemonic({String? password, required int wordsNum}) {
    try {
      return TonMnemonicGenerator()
          .fromWordsNumber(wordsNum, password: password ?? "")
          .toStr();
    } catch (e) {
      throw WalletExceptionConst.invalidMnemonic;
    }
  }

  static bool isValidCell(String? v) {
    return TonHelper.tryToCell(v) != null;
  }

  static bool isValidQueryId(BigInt? v) {
    if (v == null) return false;
    return !v.isNegative && v < maxU64;
  }

  static Cell toBinaryCommetBody(String hexBytes) {
    List<int>? toBytes = BytesUtils.tryFromHexString(hexBytes);
    if (toBytes != null) {
      if (toBytes[0] != mask8) {
        toBytes = [mask8, ...toBytes];
        return beginCell()
            .storeUint(0, 32)
            .storeBytesRefTail(toBytes)
            .endCell();
      }
    }
    throw WalletException("Invalid hex string.");
  }

  static Cell toCell(String v) {
    return TonHelper.toCell(v);
  }

  static Cell toComment(String comment) {
    return beginCell().storeUint(0, 32).storeStringRefTail(comment).endCell();
  }

  static MessageRelaxed createJettonTransaferBody(
      {required TonAddress walletAddress,
      required BigInt amount,
      required BigInt jettonAmount,
      required BigInt forwardTonAmount,
      required TonAddress responseAddress,
      required TonAddress destination,
      BigInt? queryId,
      Cell? payload}) {
    return TransactioUtils.internal(
        destination: walletAddress,
        amount: amount,
        bounce: false,
        body: beginCell()
            .storeUint(0xf8a7ea5, 32)
            .storeUint(queryId ?? BigInt.zero, 64)
            .storeCoins(jettonAmount)
            .storeAddress(responseAddress)
            .storeAddress(destination)
            .storeMaybeRef()
            .storeCoins(forwardTonAmount)
            .storeMaybeRef(cell: payload)
            .endCell());
  }
}
