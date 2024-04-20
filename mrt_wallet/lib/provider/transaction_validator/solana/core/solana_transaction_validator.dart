import 'package:mrt_wallet/models/wallet_models/address/address.dart';
import 'package:mrt_wallet/provider/api/networks/solana/api_provider.dart';
import 'package:mrt_wallet/provider/transaction_validator/core/validator.dart';
import 'package:mrt_wallet/types/typedef.dart';
import 'package:on_chain/solana/solana.dart';

import 'solana_transaction_type.dart';

abstract class SolanaTransactionValidator implements TransactionValidator {
  BigInt get transferValue;
  SolanaTransactionType get mode;
  @override
  String? validateError({ISolanaAddress? account});
  DynamicVoid? onStimateChanged;
  SolanaApiProvider? _apiProvider;
  SolanaApiProvider? get provider => _apiProvider;
  void setProvider(SolanaApiProvider? rpc) {
    _apiProvider = rpc;
  }

  Future<List<TransactionInstruction>> instructions(SolAddress owner);
}
