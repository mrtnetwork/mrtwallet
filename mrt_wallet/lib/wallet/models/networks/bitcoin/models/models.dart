import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:blockchain_utils/utils/string/string.dart';
import 'package:mrt_wallet/crypto/utils/bitcoin/bitcoin.dart';
import 'package:mrt_wallet/wallet/models/balance/balance.dart';
import 'package:mrt_wallet/wallet/models/chain/address/networks/bitcoin/addresses/bitcoin.dart';
import 'package:mrt_wallet/wallet/models/networks/bch/models/cash_token.dart';
import 'package:mrt_wallet/wallet/models/others/models/receipt_address.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';

// class

class BitcoinAccountUtxos {
  BitcoinAccountUtxos._(
      {required this.address,
      required this.utxoAddressDetails,
      this.utxosWithBalance,
      this.sumOfUtxos});
  factory BitcoinAccountUtxos(
      {required String address,
      required UtxoAddressDetails addressDetails,
      List<UtxoWithAddress>? utxos,
      required WalletBitcoinNetwork network}) {
    if (utxos != null) {
      final List<BitcoinUtxoWithBalance> utxosWithBalance =
          utxos.map((e) => BitcoinUtxoWithBalance(e, network)).toList();
      final IntegerBalance sumOfUtxos = IntegerBalance(
          utxos.fold(BigInt.zero,
              (previousValue, element) => previousValue + element.utxo.value),
          network.coinParam.decimal);
      return BitcoinAccountUtxos._(
          address: address,
          sumOfUtxos: sumOfUtxos,
          // utxos: utxos,
          utxosWithBalance: utxosWithBalance,
          utxoAddressDetails: addressDetails);
    }
    return BitcoinAccountUtxos._(
        address: address, utxoAddressDetails: addressDetails);
  }
  final String address;
  final UtxoAddressDetails utxoAddressDetails;
  final List<BitcoinUtxoWithBalance>? utxosWithBalance;
  final IntegerBalance? sumOfUtxos;

  bool get hasUtxo => utxosWithBalance != null;
}

class BitcoinAccountWithUtxos {
  BitcoinAccountWithUtxos._(
      {required this.address,
      required this.utxoAddressDetails,
      required this.utxosWithBalance,
      required this.sumOfUtxos});
  factory BitcoinAccountWithUtxos(
      {required IBitcoinAddress address,
      required UtxoAddressDetails addressDetails,
      required List<UtxoWithAddress> utxos,
      required WalletBitcoinNetwork network}) {
    final List<BitcoinUtxoWithBalance> utxosWithBalance =
        utxos.map((e) => BitcoinUtxoWithBalance(e, network)).toList();
    final IntegerBalance sumOfUtxos = IntegerBalance(
        utxos.fold(BigInt.zero,
            (previousValue, element) => previousValue + element.utxo.value),
        network.coinParam.decimal);
    return BitcoinAccountWithUtxos._(
        address: address,
        sumOfUtxos: sumOfUtxos,
        // utxos: utxos,
        utxosWithBalance: utxosWithBalance,
        utxoAddressDetails: addressDetails);
  }
  final IBitcoinAddress address;
  final UtxoAddressDetails utxoAddressDetails;
  final List<BitcoinUtxoWithBalance> utxosWithBalance;
  final IntegerBalance sumOfUtxos;
}

class BitcoinPsbtInputWithAccount {
  final UtxoAddressDetails? owner;
  final ReceiptAddress<BitcoinBaseAddress> address;
  final IBitcoinAddress? ownerAddress;
  final TxInput input;
  final int index;
  final IntegerBalance balance;
  final int sighash;
  final bool hasChangableOutput;
  BitcoinPsbtInputWithAccount(
      {required this.owner,
      required this.input,
      required this.index,
      required this.address,
      required this.sighash,
      required this.ownerAddress,
      BigInt? value})
      : balance = IntegerBalance(value ?? BigInt.zero, BTCUtils.decimal,
            allowNegative: false, imutable: true),
        hasChangableOutput = PsbtUtils.canChangeOutput(sighash);
  BitcoinPsbtInputWithAccount copyWith(
      {UtxoAddressDetails? owner,
      TxInput? input,
      int? index,
      ReceiptAddress<BitcoinBaseAddress>? address,
      BigInt? value,
      int? sighash,
      IBitcoinAddress? ownerAddress,
      bool? hasChangableOutput}) {
    return BitcoinPsbtInputWithAccount(
        owner: owner ?? this.owner,
        input: input ?? this.input,
        index: index ?? this.index,
        address: address ?? this.address,
        value: value ?? balance.balance,
        sighash: sighash ?? this.sighash,
        ownerAddress: ownerAddress ?? this.ownerAddress);
  }
}

class BitcoinUtxoWithBalance {
  BitcoinUtxoWithBalance(
    this.utxo,
    WalletBitcoinNetwork network,
  )   : balance = IntegerBalance(utxo.utxo.value, network.coinParam.decimal,
            allowNegative: false, imutable: true),
        cashToken = utxo.utxo.token == null
            ? null
            : BCHCashToken(cashToken: utxo.utxo.token!);

  final UtxoWithAddress utxo;
  late final IntegerBalance balance;
  String get txHash => utxo.utxo.txHash;
  int get index => utxo.utxo.vout;
  // final UtxoAddressDetails address;
  final BCHCashToken? cashToken;
}

class BitcoinOutputWithBalance {
  BitcoinOutputWithBalance._({
    required this.viewAddress,
    required this.balance,
    required this.address,
    required this.token,
    required this.tokenBalance,
  });
  BitcoinOutputWithBalance(
      {required this.address,
      required WalletBitcoinNetwork network,
      this.token})
      : assert(() {
          if (token != null && network.type != NetworkType.bitcoinCash) {
            return false;
          }
          return true;
        }(),
            "${network.coinParam.token.name} does not support cashTokens feature"),
        viewAddress = address.networkAddress
            .toAddress(network.coinParam.transacationNetwork),
        balance = IntegerBalance.zero(network.coinParam.decimal),
        tokenBalance =
            token == null || !token.hasAmount ? null : IntegerBalance.zero(0);

  final String viewAddress;
  final IntegerBalance balance;
  final ReceiptAddress<BitcoinBaseAddress> address;
  final CashToken? token;
  final IntegerBalance? tokenBalance;
  bool get hasAmount => !balance.isZero;
  bool get hasTokenAmount => !(tokenBalance?.isZero ?? true);
  bool get isReady =>
      hasAmount && (token == null || !token!.hasAmount || hasTokenAmount);
  BitcoinBaseOutput toOutput({String? utxoHash}) {
    if (token != null) {
      return BitcoinTokenOutput(
          address: address.networkAddress,
          value: balance.balance,
          token: token!.copyWith(amount: tokenBalance?.balance),
          utxoHash: utxoHash);
    }
    return BitcoinOutput(
        address: address.networkAddress, value: balance.balance);
  }

  BitcoinOutputWithBalance copyWith(
      {String? viewAddress,
      IntegerBalance? balance,
      ReceiptAddress<BitcoinBaseAddress>? address,
      CashToken? token,
      IntegerBalance? tokenBalance}) {
    return BitcoinOutputWithBalance._(
        viewAddress: viewAddress ?? this.viewAddress,
        balance: balance ??
            IntegerBalance(this.balance.balance, this.balance.currencyDecimal),
        address: address ?? this.address,
        token: token ?? this.token,
        tokenBalance: tokenBalance ??
            (this.tokenBalance == null
                ? null
                : IntegerBalance(this.tokenBalance!.balance,
                    this.tokenBalance!.currencyDecimal)));
  }
}

class PsbtBitcoinOutputWithBalance {
  PsbtBitcoinOutputWithBalance._(
      {required this.balance,
      required this.address,
      required this.script,
      required this.change,
      required this.scriptPubKey,
      this.opReturns});

  factory PsbtBitcoinOutputWithBalance({
    required Script scriptPubKey,
    required BigInt balance,
    required WalletBitcoinNetwork network,
    ReceiptAddress<BitcoinBaseAddress>? address,
  }) {
    final scriptHex = scriptPubKey.toHex();
    if (address != null) {
      return PsbtBitcoinOutputWithBalance._(
          balance: IntegerBalance(balance, network.coinDecimal,
              allowNegative: false, imutable: true),
          address: address,
          script: scriptHex,
          change: address.isAccount,
          scriptPubKey: scriptPubKey);
    }
    final isOpReturn = BitcoinScriptUtils.isOpReturn(scriptPubKey);
    List<String>? opReturns;
    if (isOpReturn && scriptPubKey.script.length > 1) {
      opReturns = scriptPubKey.script
          .sublist(1)
          .map((e) =>
              StringUtils.tryDecode(
                  BytesUtils.tryFromHexString(e.toString())) ??
              e.toString())
          .toList();
    }
    return PsbtBitcoinOutputWithBalance._(
        balance: IntegerBalance(balance, network.coinDecimal,
            allowNegative: false, imutable: true),
        address: address,
        script: scriptHex,
        opReturns: opReturns?.join(", "),
        change: false,
        scriptPubKey: scriptPubKey);
  }

  final IntegerBalance balance;
  final ReceiptAddress<BitcoinBaseAddress>? address;
  final String script;
  final Script scriptPubKey;
  final String? opReturns;
  final bool change;
  BitcoinBaseOutput toOutput() {
    if (address == null) {
      return BitcoinScriptOutput(script: scriptPubKey, value: balance.balance);
    }
    return BitcoinOutput(
        address: address!.networkAddress, value: balance.balance);
  }
}

class BitcoinBurnableUtxoWithBalance implements BitcoinOutputWithBalance {
  BitcoinBurnableUtxoWithBalance._(
      {required this.token,
      required this.tokenBalance,
      required this.categoryId});
  BitcoinBurnableUtxoWithBalance(
      {required this.token, required this.categoryId})
      : tokenBalance = !token.hasAmount ? null : IntegerBalance.zero(0);

  @override
  String get viewAddress => "unknown";
  @override
  IntegerBalance get balance => throw UnimplementedError();
  @override
  ReceiptAddress<BitcoinBaseAddress> get address => throw UnimplementedError();
  @override
  final CashToken token;
  @override
  final IntegerBalance? tokenBalance;
  @override
  bool get hasAmount => !balance.isZero;
  @override
  bool get hasTokenAmount => !(tokenBalance?.isZero ?? true);
  @override
  bool get isReady => token.hasAmount == hasTokenAmount;
  final String categoryId;
  @override
  BitcoinBaseOutput toOutput({String? utxoHash}) {
    return BitcoinBurnableOutput(
        value: tokenBalance?.balance,
        utxoHash: token.hasAmount ? null : utxoHash,
        categoryID: categoryId);
  }

  @override
  BitcoinBurnableUtxoWithBalance copyWith(
      {String? viewAddress,
      IntegerBalance? balance,
      ReceiptAddress<BitcoinBaseAddress>? address,
      CashToken? token,
      IntegerBalance? tokenBalance,
      String? categoryId}) {
    return BitcoinBurnableUtxoWithBalance._(
        token: token ?? this.token,
        categoryId: categoryId ?? this.categoryId,
        tokenBalance: tokenBalance ??
            (this.tokenBalance == null
                ? null
                : IntegerBalance(this.tokenBalance!.balance,
                    this.tokenBalance!.currencyDecimal)));
  }
}

class ElectrumServerInfos {
  ElectrumServerInfos(
      {required this.banner,
      required this.features,
      required this.header,
      required this.genesisHash});
  final String banner;
  final dynamic features;
  final Map<String, dynamic> header;
  bool get hasValidFeature => features is Map;

  final String genesisHash;

  @override
  String toString() {
    return "ElectrumServerInfos{banner: $banner, features: $features, header: $header}";
  }
}

class BitcoinMemo {
  factory BitcoinMemo(String memo) {
    return BitcoinMemo._(
        memo,
        BitcoinScriptOutput(
            script: BTCUtils.toOpreturn([memo]), value: BigInt.zero),
        true);
  }
  BitcoinMemo._(this.memo, this.script, this.removable);
  factory BitcoinMemo.fromScript(BitcoinScriptOutput script, String memo) {
    return BitcoinMemo._(memo, script, false);
  }
  final String memo;
  final BitcoinScriptOutput script;
  final bool removable;
}

typedef ONPSBTSIGNINGREQUEST = Future<List<int>> Function(
    PsbtSigningInputDigest);

class BitcoonPsbtSigner
    extends PsbtBtcSigner<SignInputResponse, PsbtSigningInputDigest> {
  final ONPSBTSIGNINGREQUEST signer;
  BitcoonPsbtSigner._({required this.signer, required this.signerPublicKey});
  factory BitcoonPsbtSigner(
      {required ECPublic publicKey, required ONPSBTSIGNINGREQUEST signer}) {
    return BitcoonPsbtSigner._(signer: signer, signerPublicKey: publicKey);
  }
  @override
  SignInputResponse btcSignInput(PsbtSignInputDigest digest) {
    throw UnimplementedError('use btcSignInputAsync for signing.');
  }

  @override
  Future<SignInputResponse> btcSignInputAsync(
      PsbtSigningInputDigest digest) async {
    final signature = await signer(digest);
    return SignInputResponse(
        signature: signature, signerPublicKey: signerPublicKey);
  }

  @override
  final ECPublic signerPublicKey;
}
