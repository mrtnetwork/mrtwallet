import 'package:blockchain_utils/utils/binary/utils.dart';

enum SolanaWeb3TransactionResponseType {
  send,
  sign,
  error;

  static SolanaWeb3TransactionResponseType fromName(String name) {
    return values.firstWhere((e) => e.name == name);
  }
}

abstract class SolanaWeb3TransactionResponse {
  SolanaWeb3TransactionResponse({
    required this.id,
    required this.signer,
    required List<int> signerAddressBytes,
  }) : signerAddressBytes =
            BytesUtils.toBytes(signerAddressBytes, unmodifiable: true);
  factory SolanaWeb3TransactionResponse.fromJson(Map<String, dynamic> json) {
    final type = SolanaWeb3TransactionResponseType.fromName(json["type"]);
    switch (type) {
      case SolanaWeb3TransactionResponseType.error:
        return SolanaWeb3TransactionErrorResponse.fromJson(json);
      case SolanaWeb3TransactionResponseType.sign:
        return SolanaWeb3TransactionSignResponse.fromJson(json);
      default:
        return SolanaWeb3TransactionSendResponse.fromJson(json);
    }
  }
  abstract final SolanaWeb3TransactionResponseType type;
  final int id;
  final String signer;
  final List<int> signerAddressBytes;
  Map<String, dynamic> toJson();
  T cast<T extends SolanaWeb3TransactionResponse>() => this as T;
}

class SolanaWeb3TransactionErrorResponse extends SolanaWeb3TransactionResponse {
  SolanaWeb3TransactionErrorResponse(
      {required super.id,
      required this.message,
      required super.signer,
      required super.signerAddressBytes});
  factory SolanaWeb3TransactionErrorResponse.fromJson(
      Map<String, dynamic> json) {
    return SolanaWeb3TransactionErrorResponse(
        id: json["id"],
        message: json["message"],
        signer: json["signer"],
        signerAddressBytes: List<int>.from(json["signerAddressBytes"]));
  }
  final String message;
  @override
  Map<String, dynamic> toJson() {
    return {"type": type.name, "id": id, "message": message, "signer": signer};
  }

  @override
  SolanaWeb3TransactionResponseType get type =>
      SolanaWeb3TransactionResponseType.error;
}

class SolanaWeb3TransactionSignResponse extends SolanaWeb3TransactionResponse {
  SolanaWeb3TransactionSignResponse(
      {required super.id,
      required List<int> signature,
      required super.signer,
      required super.signerAddressBytes})
      : signature = BytesUtils.toBytes(signature);
  factory SolanaWeb3TransactionSignResponse.fromJson(
      Map<String, dynamic> json) {
    return SolanaWeb3TransactionSignResponse(
        id: json["id"],
        signature: List<int>.from(json["signature"]),
        signer: json["signer"],
        signerAddressBytes: List<int>.from(json["signerAddressBytes"]));
  }
  final List<int> signature;

  @override
  Map<String, dynamic> toJson() {
    return {
      "type": type.name,
      "id": id,
      "signature": signature,
      "signer": signer,
      "signerAddressBytes": signerAddressBytes
    };
  }

  @override
  SolanaWeb3TransactionResponseType get type =>
      SolanaWeb3TransactionResponseType.sign;
}

class SolanaWeb3TransactionSendResponse extends SolanaWeb3TransactionResponse {
  SolanaWeb3TransactionSendResponse(
      {required super.id,
      required this.txHash,
      required super.signer,
      required super.signerAddressBytes});
  factory SolanaWeb3TransactionSendResponse.fromJson(
      Map<String, dynamic> json) {
    return SolanaWeb3TransactionSendResponse(
        id: json["id"],
        txHash: json["tx_id"],
        signer: json["signer"],
        signerAddressBytes: List<int>.from(json["signerAddressBytes"]));
  }
  final String txHash;
  @override
  SolanaWeb3TransactionResponseType get type =>
      SolanaWeb3TransactionResponseType.send;
  @override
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "type": type.name,
      "tx_id": txHash,
      "signer": signer,
      "signerAddressBytes": signerAddressBytes
    };
  }
}
