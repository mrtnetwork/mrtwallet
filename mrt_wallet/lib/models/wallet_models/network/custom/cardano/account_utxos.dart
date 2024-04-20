import 'package:blockchain_utils/bip/address/ada/ada_addres_type.dart';
import 'package:on_chain/on_chain.dart';
import 'utxo_multi_asset.dart';

class ADAAccountUTXOs {
  /// Bech32 encoded address - useful when querying by payment_cred
  final String address;

  ADAAddress get toAdddress => ADAAddress.fromAddress(address);
  ADAAddressType get type => toAdddress.addressType;

  TransactionInput get toInput => TransactionInput(
      index: outputIndex, transactionId: TransactionHash.fromHex(txHash));

  /// Transaction hash of the UTXO
  final String txHash;

  final List<ADAAmountResponse> amount;

  /// UTXO index in the transaction
  /// deprecated
  final int? txIndex;

  /// UTXO index in the transaction
  final int outputIndex;

  /// Block hash of the UTXO
  final String block;

  /// The hash of the transaction output datum
  final String? dataHash;

  /// CBOR encoded inline datum
  final String? inlineDatum;

  /// The hash of the reference script of the output
  final String? referenceScriptHash;

  TransactionInput get input => TransactionInput(
      index: outputIndex, transactionId: TransactionHash.fromHex(txHash));

  late final BigInt sumOflovelace = amount.fold(
      BigInt.zero,
      (previousValue, element) =>
          previousValue +
          (element.islovelace ? BigInt.parse(element.quantity) : BigInt.zero));

  late final UtxoMultiAsset multiAsset = UtxoMultiAsset.fromUtxo(this);
  bool get hasAsset => multiAsset.hasAsset;

  late final int totalAssets = multiAsset.assets.values.fold(
      0, (previousValue, element) => previousValue + element.assets.length);

  ADAAccountUTXOs({
    required this.address,
    required this.txHash,
    required this.txIndex,
    required this.outputIndex,
    required this.block,
    required this.dataHash,
    required this.inlineDatum,
    required this.referenceScriptHash,
    required this.amount,
  });

  factory ADAAccountUTXOs.fromJson(Map<String, dynamic> json) {
    return ADAAccountUTXOs(
        address: json['address'],
        txHash: json['tx_hash'],
        txIndex: json['tx_index'],
        outputIndex: json['output_index'],
        block: json['block'],
        dataHash: json['data_hash'],
        inlineDatum: json['inline_datum'],
        referenceScriptHash: json['reference_script_hash'],
        amount: (json["amount"] as List)
            .map((e) => ADAAmountResponse.fromJson(e))
            .toList());
  }

  Map<String, dynamic> toJson() => {
        'address': address,
        'tx_hash': txHash,
        'tx_index': txIndex,
        'output_index': outputIndex,
        'block': block,
        'data_hash': dataHash,
        'inline_datum': inlineDatum,
        'reference_script_hash': referenceScriptHash,
        "amount": amount.map((e) => e.toJson()).toList()
      };
  ADAAccountUTXOResponse toUtxoResponse() {
    return ADAAccountUTXOResponse(
        address: address,
        amount: amount,
        txHash: txHash,
        block: block,
        outputIndex: outputIndex);
  }

  @override
  String toString() {
    return "ADAAccountUTXOs${toJson()}";
  }
}

extension QuickADAAccountUTXOs on List<ADAAccountUTXOs> {
  BigInt get sumOflovelace => fold(BigInt.zero,
      (previousValue, element) => previousValue + element.sumOflovelace);
}
