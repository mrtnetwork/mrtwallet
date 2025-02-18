import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/core.dart';
import 'package:mrt_wallet/app/models/models/typedef.dart';
import 'package:mrt_wallet/wallet/web3/networks/sui/sui.dart';
import 'package:on_chain/on_chain.dart';

enum SuiTransactionType {
  transfer,
  tokenTransfer;

  bool get isTokenTransfer => this == tokenTransfer;
}

abstract class SuiTransactionForm extends TransactionForm {
  BigInt get transferValue;
  SuiChain? _account;
  ISuiAddress? _address;
  DynamicVoid? onStimateChanged;
  SuiClient? _apiProvider;
  SuiClient get client => _apiProvider!;
  SuiChain get account => _account!;
  ISuiAddress get address => _address!;
  WalletSuiNetwork get network => _account!.network;
  SuiTransactionType get transactionType;

  @override
  String? validateError({ISuiAddress? account});

  void initForm({SuiChain? account, ISuiAddress? address}) {
    _account = account;
    _address = address;
    _apiProvider = account?.clientNullable;
  }

  Future<SuiProgrammableTransaction> createTransaction(ISuiAddress address);

  @override
  void close() {
    _account = null;
    _address = null;
    _apiProvider = null;
    super.close();
  }
}

abstract class SuiWeb3Form<PARAMS extends Web3SuiRequestParam> extends Web3Form<
    SuiAddress, SuiChain, Web3SuiChainAccount, Web3SuiChain, PARAMS> {
  @override
  abstract final Web3SuiRequest<dynamic, PARAMS> request;

  DynamicVoid? onStimateChanged;

  @override
  String get name => request.params.method.name;

  void confirmRequest({Object? response}) {
    onCompleteForm?.call(response);
  }

  SuiClient? _client;
  SuiClient get client => _client!;
  ISuiAddress? _address;
  ISuiAddress get address => _address!;
  SuiChain? _account;
  SuiChain get account => _account!;
  WalletSuiNetwork get network => _account!.network;

  Future<void> initForm(
      {required SuiChain account, required ISuiAddress? address}) async {
    _account = account;
    _address = address;
    _client = account.clientNullable;
  }

  @override
  void close() {
    super.close();
    onCompleteForm = null;
    _client = null;
    _address = null;
    _account = null;
  }
}
