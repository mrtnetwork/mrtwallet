import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/core.dart';
import 'package:mrt_wallet/app/models/models/typedef.dart';
import 'package:mrt_wallet/wallet/web3/networks/aptos/aptos.dart';
import 'package:on_chain/on_chain.dart';

enum AptosTransactionType {
  transfer,
  tokenTransfer;

  bool get isTokenTransfer => this == tokenTransfer;
}

abstract class AptosTransactionForm extends TransactionForm {
  BigInt get transferValue;

  IAptosAddress? _address;
  DynamicVoid? onStimateChanged;
  AptosClient? _apiProvider;
  AptosClient? get provider => _apiProvider;
  AptosChain get account => _account!;
  IAptosAddress get address => _address!;
  AptosChain? _account;
  WalletAptosNetwork get network => _account!.network;
  AptosTransactionType get transactionType;

  @override
  String? validateError({IAptosAddress? account});

  void initForm({AptosChain? account, IAptosAddress? address}) {
    _account = account;
    _address = address;
    _apiProvider = account?.clientNullable;
  }

  AptosTransactionPayload createTransaction(IAptosAddress address);

  @override
  void close() {
    _account = null;
    _address = null;
    _apiProvider = null;
    super.close();
  }
}

abstract class AptosWeb3Form<PARAMS extends Web3AptosRequestParam>
    extends Web3Form<AptosAddress, AptosChain, Web3AptosChainAccount,
        Web3AptosChain, PARAMS> {
  @override
  abstract final Web3AptosRequest<dynamic, PARAMS> request;

  DynamicVoid? onStimateChanged;
  @override
  String get name => request.params.method.name;

  void confirmRequest({Object? response}) {
    onCompleteForm?.call(response);
  }

  AptosClient? _client;
  AptosClient get client => _client!;
  IAptosAddress? _address;
  IAptosAddress get address => _address!;
  AptosChain? _account;
  WalletAptosNetwork get network => _account!.network;

  void initForm(
      {required AptosChain account, required IAptosAddress? address}) {
    _account = account;
    _client = account.clientNullable;
  }

  @override
  void close() {
    super.close();
    _client = null;
    _address = null;
    _account = null;
  }
}
