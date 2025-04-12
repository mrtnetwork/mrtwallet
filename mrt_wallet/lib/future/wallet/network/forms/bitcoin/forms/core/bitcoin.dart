import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/core.dart';
import 'package:mrt_wallet/app/models/models/typedef.dart';
import 'package:mrt_wallet/wallet/web3/networks/bitcoin/bitcoin.dart';

abstract class BitcoinTransactionForm extends TransactionForm {
  BigInt get transferValue;
  BitcoinChain? _account;
  IBitcoinAddress? _address;
  DynamicVoid? onStimateChanged;
  BitcoinClient? _apiProvider;
  BitcoinClient get client => _apiProvider!;
  BitcoinChain get account => _account!;
  IBitcoinAddress get address => _address!;
  WalletBitcoinNetwork get network => _account!.network;

  @override
  String? validateError({IBitcoinAddress? account});

  void initForm({BitcoinChain? account, IBitcoinAddress? address}) {
    _account = account;
    _address = address;
    _apiProvider = account?.clientNullable;
  }

  @override
  void close() {
    _account = null;
    _address = null;
    _apiProvider = null;
    super.close();
  }
}

abstract class BitcoinWeb3Form<PARAMS extends Web3BitcoinRequestParam>
    extends Web3Form<BitcoinBaseAddress, BitcoinChain, Web3BitcoinChainAccount,
        Web3BitcoinChain, PARAMS> {
  @override
  abstract final Web3BitcoinRequest<dynamic, PARAMS> request;

  DynamicVoid? onStimateChanged;

  @override
  String get name => request.params.method.name;

  void confirmRequest({Object? response}) {
    onCompleteForm?.call(response);
  }

  BitcoinClient? _client;
  BitcoinClient get client => _client!;
  IBitcoinAddress? _address;
  IBitcoinAddress get address => _address!;
  BitcoinChain? _account;
  BitcoinChain get account => _account!;
  WalletBitcoinNetwork get network => _account!.network;

  Future<void> initForm(
      {required BitcoinChain account,
      required IBitcoinAddress? address}) async {
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
