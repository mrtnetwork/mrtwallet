import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/network/forms/sui/sui.dart';
import 'package:mrt_wallet/future/widgets/widgets/progress_bar/progress.dart';
import 'package:mrt_wallet/wallet/api/client/networks/sui/models/types.dart';
import 'package:mrt_wallet/wallet/models/balance/integer/integer.dart';
import 'package:mrt_wallet/wallet/models/chain/address/networks/sui/sui/sui.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/models/networks/sui/models/types.dart';
import 'package:mrt_wallet/wallet/models/others/models/receipt_address.dart';
import 'package:mrt_wallet/wallet/models/token/chains_tokens/sui.dart';
import 'package:mrt_wallet/wallet/web3/networks/sui/sui.dart';
import 'package:on_chain/on_chain.dart';

class _MoveNormalizedArguments {
  final List<SuiApiMoveNormalizedType> parameters;
  const _MoveNormalizedArguments._(this.parameters);
  static bool isTxContext(SuiApiMoveNormalizedType type) {
    switch (type.type) {
      case SuiApiMoveNormalizedTypes.struct:
        return type.cast<SuiApiMoveNormalizedTypeStruct>().struct.isTxContext;
      case SuiApiMoveNormalizedTypes.reference:
        return isTxContext(
            type.cast<SuiApiMoveNormalizedTypeReference>().reference);
      case SuiApiMoveNormalizedTypes.mutableReference:
        return isTxContext(type
            .cast<SuiApiMoveNormalizedTypeMutableReference>()
            .mutableReference);
      default:
        return false;
    }
  }

  static bool isReceiving(SuiApiMoveNormalizedType type) {
    switch (type.type) {
      case SuiApiMoveNormalizedTypes.struct:
        return type.cast<SuiApiMoveNormalizedTypeStruct>().struct.isReceiving;
      case SuiApiMoveNormalizedTypes.reference:
        return isTxContext(
            type.cast<SuiApiMoveNormalizedTypeReference>().reference);
      case SuiApiMoveNormalizedTypes.mutableReference:
        return isTxContext(type
            .cast<SuiApiMoveNormalizedTypeMutableReference>()
            .mutableReference);
      default:
        return false;
    }
  }

  factory _MoveNormalizedArguments(SuiApiMoveNormalizedFunction abi) {
    final parameters = abi.parameters.clone();
    if (parameters.isEmpty) return _MoveNormalizedArguments._([]);
    final lastParameter = parameters.last;
    if (_MoveNormalizedArguments.isTxContext(lastParameter)) {
      parameters.removeLast();
    }
    return _MoveNormalizedArguments._(parameters);
  }

  Web3SuiTransactionPureArg? encodeAt(int index, Object? value) {
    final encode = parameters[index].toSuiCallArgPrue(value: value);
    if (encode != null) {
      return Web3SuiTransactionPureArg(bytes: encode.toBcsBase64());
    }
    return null;
  }
}

class Web3SuiSendTransactionForm
    extends SuiWeb3Form<Web3SuiSignOrExecuteTransaction> {
  Web3SuiSendTransactionForm({required this.request});
  @override
  Web3SuiRequest<Map<String, dynamic>, Web3SuiSignOrExecuteTransaction> request;
  Web3SuiTransactionDataV2 get transaction => request.params.transaction;
  late final List<Web3SuiTransactionCallArg> _inputs =
      List.from(transaction.inputs);
  final Map<SuiAddress, SuiObjectResponse> _resolvedObjects = {};
  late BigInt? _gasUnitPrice = transaction.gasData.price;
  Future<BigInt> _getGasPrice() async {
    return _gasUnitPrice ??= await client.getGasPrice();
  }

  List<SuiAddress> _getUnresolvedObjectIds() {
    final unresolvedObject =
        _inputs.whereType<Web3SuiTransactionUnresolvedObject>().toList();
    return unresolvedObject
        .where((e) =>
            (e.digest == null) ||
            (e.initialSharedVersion == null && e.initialSharedVersion == null))
        .map((e) => e.objectId)
        .toList();
  }

  Future<void> _getUnresolvedObject(
      {required List<SuiAddress> objectIds}) async {
    final ids =
        objectIds.where((e) => !_resolvedObjects.containsKey(e)).toList();
    if (ids.isEmpty) return;
    final objects = await client.getObjects(ids);
    final fetchedObject = objects.map((k, v) {
      BigInt? initialVersion;
      final data = v.data;
      if (v.error != null || data == null) {
        throw Web3SuiExceptionConstant.retrieveObjectFailed(
            v.error?.errorMessage);
      }
      if (data.owner?.type == SuiApiObjectOwnerType.shared) {
        initialVersion = (v.data!.owner as SuiApiObjectOwnerShared)
            .shared
            .initialSharedVersion;
      }
      return MapEntry(
          k,
          SuiObjectResponse(
              objectId: data.objectId,
              digest: data.digest,
              version: data.version,
              initialVersion: initialVersion));
    });
    _resolvedObjects.addAll(fetchedObject);
  }

  Web3SuiTransactionUnresolvedPurePureArg? _getUnresolvedPure(
      Web3SuiTransactionArgument argument) {
    if (argument.type != Web3SuiArguments.input) return null;
    final index = argument.cast<Web3SuiTransactionArgumentInput>().input;
    final input = _inputs[index];
    if (input.type != Web3SuiTransactionCallArgs.unresolvedPure) return null;
    return input.cast();
  }

  Future<void> _updateTransferObjectArguments(
      Web3SuiTransactionCommandTransferObjects transferObject) async {
    final pure = _getUnresolvedPure(transferObject.address);
    if (pure != null) {
      final address = MoveAddress.parse(pure.value);
      final index = _inputs.indexOf(pure);
      _inputs[index] = Web3SuiTransactionPureArg(bytes: address.toBcsBase64());
    }
  }

  Future<void> _resolveObjects() async {
    int? asInput(Web3SuiTransactionArgument argument) {
      if (argument.type != Web3SuiArguments.input) return null;
      return argument.cast<Web3SuiTransactionArgumentInput>().input;
    }

    for (int i = 0; i < _inputs.length; i++) {
      final input = _inputs[i];
      if (input.type != Web3SuiTransactionCallArgs.unresolvedObject) continue;
      final unResolveObject = input.cast<Web3SuiTransactionUnresolvedObject>();
      bool mutable = false;
      bool isReceving = false;
      for (final command in transaction.commands) {
        if (isReceving && mutable) break;
        switch (command.type) {
          case Web3SuiTransactionCommands.splitCoins:
            final splitCoins =
                command.cast<Web3SuiTransactionCommandSplitCoins>();
            final index = asInput(splitCoins.coin);
            if (index == i) {
              mutable = true;
            }

            break;
          case Web3SuiTransactionCommands.mergeCoins:
            final mergeCoins =
                command.cast<Web3SuiTransactionCommandMergeCoins>();
            for (final coin in [
              mergeCoins.destination,
              ...mergeCoins.sources
            ]) {
              final index = asInput(coin);
              if (index == i) {
                mutable = true;
                break;
              }
            }
            break;
          case Web3SuiTransactionCommands.moveCall:
            if (isReceving && mutable) continue;
            final moveCall = command.cast<Web3SuiTransactionCommandMoveCall>();
            for (int j = 0; j < moveCall.arguments.length; j++) {
              if (isReceving && mutable) break;
              final argument = moveCall.arguments[j];
              if (argument.type != Web3SuiArguments.input) continue;
              final index = asInput(argument);
              if (index != i) continue;
              final abi = await _getAbi(moveCall);
              final param = abi.parameters[j];
              mutable =
                  mutable || param.type != SuiApiMoveNormalizedTypes.reference;
              isReceving =
                  isReceving || _MoveNormalizedArguments.isReceiving(param);
            }
          case Web3SuiTransactionCommands.makeMoveVec:
            final mergeCoins =
                command.cast<Web3SuiTransactionCommandMakeMoveVec>();
            for (final inp in mergeCoins.elements) {
              final index = asInput(inp);
              if (index == i) {
                mutable = true;
                break;
              }
            }
            break;
          default:
            break;
        }
      }
      await _resolveObject(
          object: unResolveObject, isMutable: mutable, isReceiving: isReceving);
    }
  }

  Future<void> _updateSplitCoins(
      Web3SuiTransactionCommandSplitCoins splitCoins) async {
    for (final i in splitCoins.amounts) {
      final pure = _getUnresolvedPure(i);
      if (pure == null) continue;
      final index = _inputs.indexOf(pure);
      final amount = MoveU64.parse(pure.value);
      _inputs[index] = Web3SuiTransactionPureArg(bytes: amount.toBcsBase64());
    }
  }

  Future<void> _resolveObject({
    required Web3SuiTransactionUnresolvedObject object,
    required bool isMutable,
    required bool isReceiving,
  }) async {
    final obj = _resolvedObjects[object.objectId];

    Web3SuiTransactionObject updatedObject;
    if (object.initialSharedVersion != null || obj!.initialVersion != null) {
      updatedObject = Web3SuiTransactionObject(Web3SuiTransactionSharedObject(
        objectId: object.objectId,
        initialSharedVersion:
            object.initialSharedVersion ?? obj!.initialVersion!,
        mutable: isMutable,
      ));
    } else if (isReceiving) {
      updatedObject = Web3SuiTransactionObject(Web3SuiTransactionReceiving(
          objectId: object.objectId,
          version: object.version ?? obj.version,
          digest: object.digest ?? obj.digest));
    } else {
      updatedObject = Web3SuiTransactionObject(
          Web3SuiTransactionImmOrOwnedObject(
              objectId: object.objectId,
              version: object.version ?? obj.version,
              digest: object.digest ?? obj.digest));
    }
    final index = _inputs.indexOf(object);
    _inputs[index] = updatedObject;
  }

  final Map<String, _MoveNormalizedArguments> _abis = {};
  Future<_MoveNormalizedArguments> _getAbi(
      Web3SuiTransactionCommandMoveCall moveCall) async {
    final name =
        "${moveCall.package.address}::${moveCall.module}::${moveCall.function}";
    _abis[name] ??= _MoveNormalizedArguments(await client.normalizeFunction(
        package: moveCall.package.address,
        moduleName: moveCall.module,
        functionName: moveCall.function));
    return _abis[name]!;
  }

  Future<void> _updateMoveCall(
      Web3SuiTransactionCommandMoveCall moveCall) async {
    late final List<Web3SuiTransactionArgumentInput> inputsArguments = moveCall
        .arguments
        .whereType<Web3SuiTransactionArgumentInput>()
        .toList();
    if (inputsArguments.isEmpty) return;
    final abi = await _getAbi(moveCall);
    if (abi.parameters.length != moveCall.arguments.length) {
      throw Web3SuiExceptionConstant.mismatchMoveCallArguments;
    }
    for (int i = 0; i < moveCall.arguments.length; i++) {
      final argument = moveCall.arguments[i];
      final pure = _getUnresolvedPure(argument);
      if (pure != null) {
        final inputIndex = _inputs.indexOf(pure);
        final encode = abi.encodeAt(i, pure.value);
        if (encode != null) {
          _inputs[inputIndex] = encode;
          continue;
        } else {
          final address =
              MethodUtils.nullOnException(() => SuiAddress(pure.value));
          if (address == null) {
            throw Web3SuiExceptionConstant.invalidObjectId(
                pure.value?.toString() ?? 'null');
          }
          _inputs[inputIndex] =
              Web3SuiTransactionUnresolvedObject(objectId: address);
        }
      }
    }
  }

  Future<SuiTransactionDataV1> _buildTransaction() async {
    await _getUnresolvedObject(objectIds: _getUnresolvedObjectIds());
    for (final i in transaction.commands) {
      switch (i.type) {
        case Web3SuiTransactionCommands.transferObject:
          await _updateTransferObjectArguments(i.cast());
          break;
        case Web3SuiTransactionCommands.splitCoins:
          await _updateSplitCoins(i.cast());
          break;
        case Web3SuiTransactionCommands.moveCall:
          await _updateMoveCall(i.cast());
          break;
        default:
          break;
      }
    }
    await _resolveObjects();
    final commands =
        transaction.commands.map((e) => e.toTrnsactionCommand()).toList();
    final inputs = _inputs.map((e) => e.toTransactionCallArguments()).toList();
    final kind = SuiTransactionKindProgrammableTransaction(
        SuiProgrammableTransaction(inputs: inputs, commands: commands));
    final gasPrice = await _getGasPrice();
    final gasData = transaction.gasData.toTransactionGasData(
        owner: address.networkAddress,
        budget: SuiHelper.toMist("0.1"),
        price: gasPrice);
    final expiration = transaction.expiration?.toTransactionExpiration() ??
        SuiTransactionExpirationNone();
    return SuiTransactionDataV1(
        expiration: expiration,
        sender: transaction.sender ?? address.networkAddress,
        gasData: gasData,
        kind: kind);
  }

  final GlobalKey<StreamWidgetState> simulateProgressKey = GlobalKey();
  final Cancelable _cancelable = Cancelable();
  String? _vmStatus;
  String? get vmStatus => _vmStatus;

  /// final information
  SuiTransactionFee? _fee;
  IntegerBalance get fee => _fee!.totalFee;
  SuiTransactionDataV1? _finalTransaction;
  ReceiptAddress<SuiAddress>? _owner;
  ReceiptAddress<SuiAddress>? get owner => _owner;
  ReceiptAddress<SuiAddress>? _feePayer;
  ReceiptAddress<SuiAddress>? get feePayer => _feePayer;
  List<SuiWeb3AccountChangeBalance>? _balanceChanged;
  List<SuiWeb3AccountChangeBalance>? get balanceChanged => _balanceChanged;
  String? _simulateTxContent;
  String? get simulateContent => _simulateTxContent;

  String? _transactionContent;
  String get transactionContent => _transactionContent!;

  StreamWidgetStatus _status = StreamWidgetStatus.progress;
  StreamWidgetStatus get status => _status;

  bool _simulateSuccess = false;
  ReceiptAddress<SuiAddress>? _getOwnerAddress(SuiApiObjectOwner owner) {
    switch (owner.type) {
      case SuiApiObjectOwnerType.addressOwner:
        return _getOrCreateReceiptAddress(
            SuiAddress((owner as SuiApiObjectOwnerAddressOwner).addressOwner));
      case SuiApiObjectOwnerType.objectOwner:
        return _getOrCreateReceiptAddress(
            SuiAddress((owner as SuiApiObjectOwnerObjectOwner).objectOwner));
      default:
        return null;
    }
  }

  List<SuiToken> _accountTokens = [];

  Future<void> _getBalanceChanges(List<SuiApiBalanceChange> changes) async {
    final tokens = await MethodUtils.call(() =>
        client.getAccountTokens(address.networkAddress, allowSuiCoin: true));
    if (tokens.hasResult) {
      _accountTokens = tokens.result;
    }
    List<SuiWeb3AccountChangeBalance> changed = [];
    for (final i in changes) {
      if (i.owner.type == SuiApiObjectOwnerType.addressOwner ||
          i.owner.type == SuiApiObjectOwnerType.objectOwner) {}
      SuiWeb3AccountChangeBalance change;
      final amount = BigintUtils.tryParse(i.amount);
      final token =
          _accountTokens.firstWhereNullable((e) => e.assetType == i.coinType);
      final ownerAddress = _getOwnerAddress(i.owner);
      final owner = i.owner.type.name.camelCase;
      if (amount != null && token != null) {
        change = SuiWeb3AccountChangeBalance(
          coinType: i.coinType,
          amountStr: i.amount,
          token: token,
          amount: IntegerBalance(amount, token.token.decimal!, imutable: true),
          owner: owner,
          ownerAddres: ownerAddress,
        );
      } else {
        change = SuiWeb3AccountChangeBalance(
          coinType: i.coinType,
          amountStr: i.amount,
          owner: owner,
          ownerAddres: ownerAddress,
        );
      }
      changed.add(change);
    }
    if (changed.isEmpty) return;
    _balanceChanged = changed;
  }

  // SuiTransactionData get tr
  Future<void> simulateTx() async {
    if (_simulateSuccess) return;
    _status = StreamWidgetStatus.progress;
    _cancelable.cancel();
    _vmStatus = null;
    simulateProgressKey.process();
    onChanged?.call();
    _simulateSuccess = false;
    try {
      final r = await MethodUtils.call(() async {
        SuiTransactionDataV1 tx = _finalTransaction!;
        if (!transaction.gasData.hasFee) {
          tx = tx.copyWith(
              gasData: transaction.gasData.toTransactionGasData(
                  owner: tx.gasData.owner,
                  budget: SuiTransactionConst.maxGas,
                  price: tx.gasData.price));
        }
        return client.simulateTransaction(tx);
      }, cancelable: _cancelable);
      if (r.isCancel) return;
      if (r.hasError ||
          r.result.effects.status.status != SuiApiExecutionStatusType.success) {
        _vmStatus = r.error?.tr ?? r.result.effects.status.error;
        if (r.hasResult) {
          _simulateTxContent = StringUtils.fromJson(r.result.toJson(),
              indent: ' ', toStringEncodable: true);
        }
        _status = StreamWidgetStatus.error;
        simulateProgressKey.error();
        return;
      }
      if (!transaction.gasData.hasFee) {
        final fee = SuiTransactionFee(
          gasUsed: r.result.effects.gasUsed,
          gasPrice: await _getGasPrice(),
          network: network,
        );
        _fee = fee;
        _finalTransaction = _finalTransaction!.copyWith(
            gasData: transaction.gasData.toTransactionGasData(
                owner: address.networkAddress,
                budget: fee.budget,
                price: fee.gasPrice));
      }
      await _getBalanceChanges(r.result.balanceChanges);
      _vmStatus = "transaction_simulation_success".tr;
      _simulateTxContent = StringUtils.fromJson(r.result.toJson(),
          indent: ' ', toStringEncodable: true);
      _status = StreamWidgetStatus.idle;
      simulateProgressKey.idle();
      _simulateSuccess = true;
    } finally {
      onChanged?.call();
    }
  }

  ReceiptAddress<SuiAddress>? _getOrCreateReceiptAddress(SuiAddress? address) {
    if (address == null) return null;
    return account.getReceiptAddress(address.address) ??
        ReceiptAddress<SuiAddress>(
            view: address.address, networkAddress: address);
  }

  @override
  Future<void> initForm(
      {required SuiChain account, required ISuiAddress? address}) async {
    await super.initForm(account: account, address: address);
    final finalTransaction = await _buildTransaction();
    if (finalTransaction.sender != this.address.networkAddress) {
      _owner = _getOrCreateReceiptAddress(finalTransaction.sender);
    }
    if (finalTransaction.gasData.owner != this.address.networkAddress) {
      _owner = _getOrCreateReceiptAddress(finalTransaction.gasData.owner);
    }
    _fee = SuiTransactionFee.fromBudget(
      budget: finalTransaction.gasData.budget,
      gasPrice: finalTransaction.gasData.price,
      network: network,
    );
    _transactionContent = StringUtils.fromJson(finalTransaction.toJson(),
        indent: ' ', toStringEncodable: true);
    _finalTransaction = finalTransaction;
    MethodUtils.after(() => simulateTx(),
        duration: APPConst.oneSecoundDuration);
  }

  Future<void> sendTransaction(FuncFutureNullableBoolString onSubmit) async {
    if (!_simulateSuccess) {
      final submit = await onSubmit(vmStatus != null
          ? "transaction_simulate_failed_desc".tr
          : "transaction_simulate_not_ready_desc".tr);
      if (submit != true) return;
    }
    onCompleteForm?.call(_finalTransaction!);
  }

  @override
  void close() {
    super.close();
    onCompleteForm = null;
    for (final i in _accountTokens) {
      i.balance.dispose();
    }
  }
}
