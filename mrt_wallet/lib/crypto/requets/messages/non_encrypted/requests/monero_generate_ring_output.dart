import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:monero_dart/monero_dart.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/requets/argruments/argruments.dart';
import 'package:mrt_wallet/crypto/requets/messages/core/message.dart';
import 'package:mrt_wallet/wallet/models/networks/monero/monero.dart';

class NoneEncryptedRequestGenerateRingOutput
    extends NoneEncryptedCryptoRequest<MoneroRignOutput, MessageArgsOneBytes> {
  final List<int> rctOffsetData;
  final List<MoneroPayment> payments;
  final int fakeOutsLength;
  final BigInt maxGlobalIndex;
  NoneEncryptedRequestGenerateRingOutput(
      {required List<int> rctOffsetData,
      required List<MoneroPayment> payments,
      required this.maxGlobalIndex,
      this.fakeOutsLength = 15})
      : rctOffsetData = rctOffsetData.asImmutableBytes,
        payments = payments.immutable;
  factory NoneEncryptedRequestGenerateRingOutput.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: NoneEncryptedCryptoRequestMethod.generateRingOutput.tag);

    return NoneEncryptedRequestGenerateRingOutput(
        rctOffsetData: values.elementAs(0),
        payments: values
            .elementAsListOf<CborBytesValue>(1)
            .map((e) => MoneroPayment.deserialize(e.value))
            .toList()
            .cast(),
        fakeOutsLength: values.elementAs(2),
        maxGlobalIndex: values.elementAs(3));
  }

  @override
  Future<MessageArgsOneBytes> getResult({List<int>? encryptedPart}) async {
    final result = await this.result();
    return MessageArgsOneBytes(keyOne: result.toCbor().encode());
  }

  @override
  MoneroRignOutput parsResult(MessageArgsOneBytes result) {
    return MoneroRignOutput.deserialize(bytes: result.keyOne);
  }

  @override
  NoneEncryptedCryptoRequestMethod get method =>
      NoneEncryptedCryptoRequestMethod.generateRingOutput;

  List<BigInt> getAbsoluteDistribution() {
    final distributions = OutputDistributionResponse.fromJson(
        MoneroStorageSerializer.deserialize(rctOffsetData));
    if (distributions.distributions.length != 1) {
      throw const WalletException("invalid_daemon_distribution_response");
    }
    final List<BigInt> offsets =
        List<BigInt>.from(distributions.distributions[0].distribution);
    for (int i = 1; i < offsets.length; i++) {
      offsets[i] = offsets[i] + offsets[i - 1];
    }
    if (offsets.length < MoneroNetworkConst.cryptonoteDefaultTxSpendableAge) {
      throw const WalletException("generate_rct_faild");
    }
    if (offsets.last < maxGlobalIndex) {
      throw const WalletException("generate_rct_faild");
    }
    return offsets;
  }

  @override
  Future<MoneroRignOutput> result({List<int>? encryptedPart}) async {
    final rctOffsets = getAbsoluteDistribution();
    final int baseRequestCount = ((fakeOutsLength + 1) * 1.5 + 1).ceil();
    final List<BigInt> outKeysRequestOrder = [];
    List<BigInt> outKeysRequests = [];

    void addOuts(BigInt out) {
      outKeysRequestOrder.add(out);
      outKeysRequests.add(out);
    }

    final gamma = Gamma(rctOffsets: rctOffsets);
    for (final i in payments) {
      final Set<BigInt> indices = {};
      const defaultOutCount =
          MoneroNetworkConst.cryptonoteMinedMoneyUnlockWindow -
              MoneroNetworkConst.cryptonoteDefaultTxSpendableAge;
      final int outputsCount = baseRequestCount + defaultOutCount;
      final int start = outKeysRequests.length;
      final BigInt numOuts = gamma.numRctOuts;
      BigInt numFound = BigInt.zero;
      if (numOuts <= BigInt.from(outputsCount)) {
        for (BigInt i = BigInt.zero; i < numOuts; i += BigInt.one) {
          addOuts(i);
        }
        for (BigInt i = numOuts;
            i < BigInt.from(outputsCount);
            i += BigInt.one) {
          addOuts(i);
        }
      } else {
        if (numFound == BigInt.zero) {
          numFound = BigInt.one;
          indices.add(i.globalIndex);
          addOuts(i.globalIndex);
        }
        BigInt usableOuts = numOuts;
        bool blackballed = false;
        while (numFound < BigInt.from(outputsCount)) {
          if (BigInt.from(indices.length) == usableOuts) {
            if (blackballed) break;
            blackballed = true;
            usableOuts = numOuts;
          }
          BigInt i;
          do {
            i = gamma.pick();
          } while (i >= numOuts);
          if (indices.contains(i)) {
            continue;
          }
          indices.add(i);
          addOuts(i);
          numFound += BigInt.one;
        }
        while (numFound < BigInt.from(outputsCount)) {
          addOuts(BigInt.zero);
          numFound += BigInt.one;
        }
      }
      final lastPart = outKeysRequests.sublist(start)
        ..sort((a, b) => a.compareTo(b));
      outKeysRequests = [...outKeysRequests.sublist(0, start), ...lastPart];
    }
    return MoneroRignOutput(
        orderedIndexes: outKeysRequestOrder, indexes: outKeysRequests);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborBytesValue(rctOffsetData),
          CborListValue.fixedLength(payments
              .map((e) => CborBytesValue(e.toVariantSerialize()))
              .toList()),
          fakeOutsLength,
          maxGlobalIndex,
        ]),
        method.tag);
  }
}
