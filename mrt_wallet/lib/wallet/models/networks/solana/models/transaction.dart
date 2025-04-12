import 'package:blockchain_utils/helper/helper.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/api/api.dart';
import 'package:mrt_wallet/wallet/models/balance/integer/integer.dart';
import 'package:mrt_wallet/wallet/models/others/models/receipt_address.dart';
import 'package:mrt_wallet/wallet/models/token/chains_tokens/spl_token.dart';
import 'package:mrt_wallet/wallet/models/token/token/token.dart';
import 'package:on_chain/solana/solana.dart';

// enum SolanaWeb3TransactionResponseType {
//   send,
//   sign,
//   error;

//   static SolanaWeb3TransactionResponseType fromName(String name) {
//     return values.firstWhere((e) => e.name == name);
//   }
// }

// abstract class SolanaWeb3TransactionResponse {
//   SolanaWeb3TransactionResponse({
//     required this.signer,
//     required List<int> signerAddressBytes,
//   }) : signerAddressBytes = signerAddressBytes.asImmutableBytes;
//   factory SolanaWeb3TransactionResponse.fromJson(Map<String, dynamic> json) {
//     final type = SolanaWeb3TransactionResponseType.fromName(json["type"]);
//     switch (type) {
//       case SolanaWeb3TransactionResponseType.error:
//         return SolanaWeb3TransactionErrorResponse.fromJson(json);
//       case SolanaWeb3TransactionResponseType.sign:
//         return SolanaWeb3TransactionSignResponse.fromJson(json);
//       default:
//         return SolanaWeb3TransactionSendResponse.fromJson(json);
//     }
//   }
//   abstract final SolanaWeb3TransactionResponseType type;
//   final String signer;
//   final List<int> signerAddressBytes;
//   Map<String, dynamic> toJson();
//   T cast<T extends SolanaWeb3TransactionResponse>() => this as T;
// }

// class SolanaWeb3TransactionErrorResponse extends SolanaWeb3TransactionResponse {
//   SolanaWeb3TransactionErrorResponse(
//       {required this.message,
//       required super.signer,
//       required super.signerAddressBytes});
//   factory SolanaWeb3TransactionErrorResponse.fromJson(
//       Map<String, dynamic> json) {
//     return SolanaWeb3TransactionErrorResponse(
//         message: json["message"],
//         signer: json["signer"],
//         signerAddressBytes: List<int>.from(json["signerAddressBytes"]));
//   }
//   final String message;
//   @override
//   Map<String, dynamic> toJson() {
//     return {"type": type.name, "message": message, "signer": signer};
//   }

//   @override
//   SolanaWeb3TransactionResponseType get type =>
//       SolanaWeb3TransactionResponseType.error;
// }

class SolanaWeb3TransactionSignResponse {
  SolanaWeb3TransactionSignResponse({
    required List<int> signedTransaction,
  }) : signedTransaction = signedTransaction.asImmutableBytes;
  factory SolanaWeb3TransactionSignResponse.fromJson(
      Map<String, dynamic> json) {
    return SolanaWeb3TransactionSignResponse(
        signedTransaction: List<int>.from(json["signedTransaction"]));
  }
  final List<int> signedTransaction;

  Map<String, dynamic> toJson() {
    return {"signedTransaction": signedTransaction};
  }
}

class SolanaWeb3TransactionSendResponse {
  SolanaWeb3TransactionSendResponse({required List<int> signature})
      : signature = signature.asImmutableBytes;
  factory SolanaWeb3TransactionSendResponse.fromJson(
      Map<String, dynamic> json) {
    return SolanaWeb3TransactionSendResponse(
        signature: (json["signature"] as List).cast());
  }
  final List<int> signature;

  Map<String, dynamic> toJson() {
    return {"signature": signature};
  }
}

enum SolanaAccountOwnerTypes {
  system("system_program"),
  spltoken("spl_token"),
  spltoken2022("spl_token2022"),
  unknow('unknown');

  final String value;
  const SolanaAccountOwnerTypes(this.value);
  static SolanaAccountOwnerTypes fromAddress(SolAddress address) {
    switch (address) {
      case SystemProgramConst.programId:
        return SolanaAccountOwnerTypes.system;
      case SPLTokenProgramConst.tokenProgramId:
        return SolanaAccountOwnerTypes.spltoken;
      case SPLTokenProgramConst.token2022ProgramId:
        return SolanaAccountOwnerTypes.spltoken2022;
      default:
        return SolanaAccountOwnerTypes.unknow;
    }
  }

  bool get isUnknown => this == SolanaAccountOwnerTypes.unknow;
}

class SolanaTransferDestinationInfo {
  final bool isOnCurve;
  final SolanaAccountOwnerTypes ownedBy;
  final bool executable;
  final SolAddress owner;
  final String ownerTag;
  const SolanaTransferDestinationInfo._(
      {required this.isOnCurve,
      required this.ownedBy,
      required this.executable,
      required this.owner,
      required this.ownerTag});
  factory SolanaTransferDestinationInfo(
      {required SolanaAccountInfo account, required SolAddress address}) {
    final ownedBy = SolanaAccountOwnerTypes.fromAddress(account.owner);
    return SolanaTransferDestinationInfo._(
        isOnCurve: address.isOnCurve,
        ownedBy: ownedBy,
        executable: account.executable,
        owner: account.owner,
        ownerTag: ownedBy.isUnknown ? account.owner.address : ownedBy.value);
  }
}

enum SolanaAccountStatus {
  unknown,
  initialized,
  uninitialized,
  error;

  bool get isInitialized => this == initialized;
  bool get isUnknown => this == unknown;
}

class SolanaOutputWithBalance with Equatable {
  SolanaOutputWithBalance({
    required this.address,
    required Token token,
  })  : balance = IntegerBalance.zero(token.decimal!, allowNegative: false),
        isPubKey = address.networkAddress.isOnCurve;
  final IntegerBalance balance;
  final ReceiptAddress<SolAddress> address;
  final bool isPubKey;
  SolanaAccountStatus _status = SolanaAccountStatus.unknown;
  SolanaAccountStatus get status => _status;
  bool get hasAmount => balance.largerThanZero;
  bool get hasError => _status == SolanaAccountStatus.error;
  bool get isReady => hasAmount && !hasError;

  @override
  List get variabels => [address.networkAddress];

  void updateBalance(BigInt balance) {
    this.balance.updateBalance(balance);
  }

  SolAddress getPdaAddress(SolAddress mint) {
    return isPubKey
        ? AssociatedTokenAccountProgramUtils.associatedTokenAccount(
                mint: mint, owner: address.networkAddress)
            .address
        : address.networkAddress;
  }

  Future<List<TransactionInstruction>> instruction(
      {required SolAddress owner,
      required SolanaClient client,
      required SolanaSPLToken? token}) async {
    SolAddress? pda;
    SolanaAccountStatus status = SolanaAccountStatus.initialized;
    if (_status.isUnknown) {
      try {
        if (token != null) {
          pda = getPdaAddress(token.mint);
          final exist = await client.getTokenAccount(pda);
          if (exist == null) {
            status = SolanaAccountStatus.uninitialized;
            if (!isPubKey) {
              status = SolanaAccountStatus.error;
              throw WalletException("solana_spl_token_required_public_key");
            }
          } else if (exist.mint != token.mint) {
            status = SolanaAccountStatus.error;
            throw WalletException(
                "spl_token_invalid_associated_account_address");
          }
        } else {
          final account = await client.getAccountInfo(address.networkAddress);
          if (account == null) {
            status = SolanaAccountStatus.uninitialized;
          }
        }
      } finally {
        _status = status;
      }
    }
    if (token != null) {
      pda ??= getPdaAddress(token.mint);
      TransactionInstruction? ascAccout;
      if (!_status.isInitialized) {
        ascAccout = AssociatedTokenAccountProgram.associatedTokenAccount(
            payer: owner,
            associatedToken: pda,
            owner: address.networkAddress,
            mint: token.mint);
      }
      return [
        if (ascAccout != null) ascAccout,
        SPLTokenProgram.transferChecked(
            layout: SPLTokenTransferCheckedLayout(
                amount: balance.balance, decimals: token.token.decimal!),
            owner: owner,
            source: token.tokenAccount,
            mint: token.mint,
            destination: pda)
      ];
    }
    return [
      SystemProgram.transfer(
          layout: SystemTransferLayout(lamports: balance.balance),
          from: owner,
          to: address.networkAddress)
    ];
  }
}
