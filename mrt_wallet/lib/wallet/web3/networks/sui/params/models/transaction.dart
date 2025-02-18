import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/sui/constant/constants/exception.dart';
import 'package:mrt_wallet/wallet/web3/networks/sui/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/networks/sui/params/core/request.dart';
import 'package:mrt_wallet/wallet/web3/validator/web3_validator_utils.dart';
import 'package:on_chain/sui/src/address/address/address.dart';
import 'package:on_chain/sui/src/rpc/models/types/types.dart';
import 'package:on_chain/sui/src/transaction/types/types.dart';
import 'package:on_chain/sui/src/utils/function.dart';

enum Web3SuiTransactionCallArgs {
  pure("Pure"),
  object("Object"),
  unresolvedPure("UnresolvedPure"),
  unresolvedObject("UnresolvedObject");

  final String name;
  const Web3SuiTransactionCallArgs(this.name);

  static Web3SuiTransactionCallArgs fromName(String? name) {
    return values
        .firstWhere((e) => e.name.toLowerCase() == name?.toLowerCase());
  }
}

abstract class Web3SuiTransactionCallArg {
  final Web3SuiTransactionCallArgs type;
  const Web3SuiTransactionCallArg(this.type);

  factory Web3SuiTransactionCallArg.fromJson(Map<String, dynamic> json) {
    final key = Web3ValidatorUtils.containsOnlyOnce(
        json: json,
        method: Web3SuiRequestMethods.signTransaction,
        keys: Web3SuiTransactionCallArgs.values.map((e) => e.name).toList(),
        name: "CallArg");
    final type = Web3SuiTransactionCallArgs.fromName(key);
    json = Web3ValidatorUtils.parseMap(
        key: key, method: Web3SuiRequestMethods.signTransaction, json: json);
    return switch (type) {
      Web3SuiTransactionCallArgs.object =>
        Web3SuiTransactionObject.fromJson(json),
      Web3SuiTransactionCallArgs.pure =>
        Web3SuiTransactionPureArg.fromJson(json),
      Web3SuiTransactionCallArgs.unresolvedPure =>
        Web3SuiTransactionUnresolvedPurePureArg.fromJson(json),
      Web3SuiTransactionCallArgs.unresolvedObject =>
        Web3SuiTransactionUnresolvedObject.fromJson(json),
    };
  }
  factory Web3SuiTransactionCallArg.fromJsonV1(Map<String, dynamic> json) {
    if (json["kind"] != "Input") {
      throw Web3RequestExceptionConst.invalidParametersParsingObjectFailed(
          "Transaction V1 Inputs");
    }
    return Web3ValidatorUtils.parse<Web3SuiTransactionCallArg,
        Map<String, dynamic>>(
      value: json,
      method: Web3SuiRequestMethods.signTransaction,
      onParse: (value) {
        if (value["value"] is Map) {
          final v = value["value"]?["Object"];
          if (v != null && v is Map) {
            return Web3SuiTransactionObject.fromJsonV1(v.cast());
          }
          final pure = value["value"]?["Pure"];
          if (pure != null) {
            return Web3SuiTransactionPureArg(
                bytes: StringUtils.decode((pure as List).cast<int>(),
                    type: StringEncoding.base64));
          }
        }
        final type = value["type"]?.toString();
        switch (type) {
          case "object":
            return Web3SuiTransactionUnresolvedObject(
                objectId: SuiAddress(value["value"]));
          case "pure":
            return Web3SuiTransactionUnresolvedPurePureArg(
                value: value["value"]);
          default:
            return null;
        }
      },
      onFailed: () =>
          throw Web3RequestExceptionConst.invalidParametersParsingObjectFailed(
              "Transaction V1 Inputs"),
    );
  }

  SuiCallArg toTransactionCallArguments();

  Map<String, dynamic> toJson();
  T cast<T extends Web3SuiTransactionCallArg>() {
    if (this is! T) {
      throw Web3RequestExceptionConst.internalErrorParsingTransactionFailed;
    }
    return this as T;
  }
}

enum Web3SuiObjectArgs {
  /// A Move object from fastpath.
  immOrOwnedObject("ImmOrOwnedObject"),

  /// A Move object from consensus (historically consensus objects were always shared).
  /// SharedObject::mutable controls whether caller asks for a mutable reference to shared object.
  sharedObject("SharedObject"),

  /// A Move object that can be received in this transaction.
  receiving("Receiving");

  final String name;
  const Web3SuiObjectArgs(this.name);
  static Web3SuiObjectArgs fromName(String? name) {
    return values
        .firstWhere((e) => e.name.toLowerCase() == name?.toLowerCase());
  }
}

class Web3SuiTransactionObject extends Web3SuiTransactionCallArg {
  final Web3SuiTransactionObjectArg objectArg;
  Web3SuiTransactionObject(this.objectArg)
      : super(Web3SuiTransactionCallArgs.object);
  factory Web3SuiTransactionObject.fromJson(Map<String, dynamic> json) {
    return Web3SuiTransactionObject(Web3SuiTransactionObjectArg.fromJson(json));
  }
  factory Web3SuiTransactionObject.fromJsonV1(Map<String, dynamic> json) {
    final objectArg = Web3ValidatorUtils.parse<Web3SuiTransactionObjectArg,
        Map<String, dynamic>>(
      value: json,
      method: Web3SuiRequestMethods.signTransaction,
      onParse: (value) {
        if (value.containsKey("ImmOrOwned")) {
          return Web3SuiTransactionImmOrOwnedObject.fromJson(
              value["ImmOrOwned"]);
        }
        if (value.containsKey("Shared")) {
          return Web3SuiTransactionSharedObject.fromJson(value["Shared"]);
        }
        if (value.containsKey("Receiving")) {
          return Web3SuiTransactionReceiving.fromJson(value["Receiving"]);
        }
        return null;
      },
      onFailed: () =>
          Web3RequestExceptionConst.invalidParametersParsingObjectFailed(
              "Transaction Input Objects"),
    );
    return Web3SuiTransactionObject(objectArg);
  }
  @override
  Map<String, dynamic> toJson() {
    return {
      Web3SuiTransactionCallArgs.object.name: {
        objectArg.type.name: objectArg.toJson()
      }
    };
  }

  @override
  SuiCallArg toTransactionCallArguments() {
    return objectArg.toTransactionObjectArgument();
  }
}

abstract class Web3SuiTransactionObjectArg {
  final Web3SuiObjectArgs type;
  const Web3SuiTransactionObjectArg(this.type);
  Map<String, dynamic> toJson();
  factory Web3SuiTransactionObjectArg.fromJson(Map<String, dynamic> json) {
    final key = Web3ValidatorUtils.containsOnlyOnce(
        json: json,
        method: Web3SuiRequestMethods.signTransaction,
        keys: Web3SuiObjectArgs.values.map((e) => e.name).toList(),
        name: "ObjectArg");
    final type = Web3SuiObjectArgs.fromName(key);
    json = Web3ValidatorUtils.parseMap(
        key: key, method: Web3SuiRequestMethods.signTransaction, json: json);
    return switch (type) {
      Web3SuiObjectArgs.immOrOwnedObject =>
        Web3SuiTransactionImmOrOwnedObject.fromJson(json),
      Web3SuiObjectArgs.sharedObject =>
        Web3SuiTransactionSharedObject.fromJson(json),
      Web3SuiObjectArgs.receiving => Web3SuiTransactionReceiving.fromJson(json)
    };
  }
  SuiCallArgObject toTransactionObjectArgument();
}

class Web3SuiTransactionImmOrOwnedObject extends Web3SuiTransactionObjectArg {
  final SuiAddress objectId;
  final BigInt version;
  final String digest;

  const Web3SuiTransactionImmOrOwnedObject(
      {required this.objectId, required this.version, required this.digest})
      : super(Web3SuiObjectArgs.immOrOwnedObject);

  factory Web3SuiTransactionImmOrOwnedObject.fromJson(
      Map<String, dynamic> json) {
    return Web3SuiTransactionImmOrOwnedObject(
        objectId: Web3ValidatorUtils.parseAddress(
            onParse: (address) => SuiAddress(address),
            key: "objectId",
            method: Web3SuiRequestMethods.signTransaction,
            json: json,
            addressName: "objectId"),
        version: Web3ValidatorUtils.parseBigInt(
            key: "version",
            method: Web3SuiRequestMethods.signTransaction,
            json: json),
        digest: Web3ValidatorUtils.parseBase58(
            key: "digest",
            method: Web3SuiRequestMethods.signTransaction,
            json: json));
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'objectId': objectId.address,
      'version': version.toString(),
      'digest': digest
    };
  }

  SuiObjectRef toObjectRef() {
    try {
      return SuiObjectRef(
          address: objectId,
          version: version,
          digest: SuiObjectDigest.fromBase58(digest));
    } catch (_) {
      throw Web3SuiExceptionConstant.invalidObject(objectId.address);
    }
  }

  @override
  SuiCallArgObject toTransactionObjectArgument() {
    return SuiCallArgObject(SuiObjectArgImmOrOwnedObject(toObjectRef()));
  }
}

class Web3SuiTransactionSharedObject extends Web3SuiTransactionObjectArg {
  final SuiAddress objectId;
  final BigInt initialSharedVersion;
  final bool mutable;

  Web3SuiTransactionSharedObject({
    required this.objectId,
    required this.initialSharedVersion,
    required this.mutable,
  }) : super(Web3SuiObjectArgs.sharedObject);

  factory Web3SuiTransactionSharedObject.fromJson(Map<String, dynamic> json) {
    return Web3SuiTransactionSharedObject(
      objectId: Web3ValidatorUtils.parseAddress(
          onParse: (address) => SuiAddress(address),
          key: "objectId",
          method: Web3SuiRequestMethods.signTransaction,
          json: json,
          addressName: "objectId"),
      initialSharedVersion: Web3ValidatorUtils.parseBigInt(
          key: "initialSharedVersion",
          method: Web3SuiRequestMethods.signTransaction,
          json: json),
      mutable: Web3ValidatorUtils.parseBool(
          key: "mutable",
          method: Web3SuiRequestMethods.signTransaction,
          json: json),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'objectId': objectId.address,
      'initialSharedVersion': initialSharedVersion.toString(),
      'mutable': mutable,
    };
  }

  @override
  SuiCallArgObject toTransactionObjectArgument() {
    return SuiCallArgObject(SuiObjectArgSharedObject(
        id: objectId,
        initialSharedVersion: initialSharedVersion,
        mutable: mutable));
  }
}

class Web3SuiTransactionReceiving extends Web3SuiTransactionObjectArg {
  final SuiAddress objectId;
  final BigInt version;
  final String digest;

  Web3SuiTransactionReceiving({
    required this.objectId,
    required this.version,
    required this.digest,
  }) : super(Web3SuiObjectArgs.receiving);

  factory Web3SuiTransactionReceiving.fromJson(Map<String, dynamic> json) {
    return Web3SuiTransactionReceiving(
      objectId: Web3ValidatorUtils.parseAddress(
          onParse: (address) => SuiAddress(address),
          key: "objectId",
          method: Web3SuiRequestMethods.signTransaction,
          json: json,
          addressName: "objectId"),
      version: Web3ValidatorUtils.parseBigInt(
          key: "version",
          method: Web3SuiRequestMethods.signTransaction,
          json: json),
      digest: Web3ValidatorUtils.parseBase58(
          key: "digest",
          method: Web3SuiRequestMethods.signTransaction,
          json: json),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'objectId': objectId.address,
      'digest': digest,
      'version': version.toString(),
    };
  }

  @override
  SuiCallArgObject toTransactionObjectArgument() {
    try {
      return SuiCallArgObject(SuiObjectArgReceiving(SuiObjectRef(
          address: objectId,
          version: version,
          digest: SuiObjectDigest.fromBase58(digest))));
    } catch (_) {
      throw Web3SuiExceptionConstant.invalidObject(objectId.address);
    }
  }
}

class Web3SuiTransactionPureArg extends Web3SuiTransactionCallArg {
  final String bytes;

  Web3SuiTransactionPureArg({required this.bytes})
      : super(Web3SuiTransactionCallArgs.pure);

  factory Web3SuiTransactionPureArg.fromJson(Map<String, dynamic> json) {
    return Web3SuiTransactionPureArg(
      bytes: Web3ValidatorUtils.parseBase64(
          key: "bytes",
          method: Web3SuiRequestMethods.signTransaction,
          json: json),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      type.name: {'bytes': bytes}
    };
  }

  @override
  SuiCallArg toTransactionCallArguments() {
    try {
      return SuiCallArgPure(
          StringUtils.encode(bytes, type: StringEncoding.base64));
    } catch (_) {
      throw Web3SuiExceptionConstant.invalidBase64Pure;
    }
  }

  List<int> deserialize() {
    return LayoutConst.bcsBytes()
        .deserialize(StringUtils.encode(bytes, type: StringEncoding.base64))
        .value;
  }
}

class Web3SuiTransactionUnresolvedPurePureArg
    extends Web3SuiTransactionCallArg {
  final dynamic value;
  Web3SuiTransactionUnresolvedPurePureArg({required this.value})
      : super(Web3SuiTransactionCallArgs.unresolvedPure);

  factory Web3SuiTransactionUnresolvedPurePureArg.fromJson(
      Map<String, dynamic> json) {
    return Web3SuiTransactionUnresolvedPurePureArg(value: json['value']);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      type.name: {'value': value}
    };
  }

  @override
  SuiCallArg toTransactionCallArguments() {
    throw Web3SuiExceptionConstant.failedToResolvePureArgs();
  }
}

class Web3SuiTransactionUnresolvedObject extends Web3SuiTransactionCallArg {
  final SuiAddress objectId;
  final BigInt? version;
  final String? digest;
  final BigInt? initialSharedVersion;

  Web3SuiTransactionUnresolvedObject({
    required this.objectId,
    this.version,
    this.digest,
    this.initialSharedVersion,
  }) : super(Web3SuiTransactionCallArgs.unresolvedObject);

  factory Web3SuiTransactionUnresolvedObject.fromJson(
      Map<String, dynamic> json) {
    return Web3SuiTransactionUnresolvedObject(
      objectId: Web3ValidatorUtils.parseAddress(
          onParse: (address) => SuiAddress(address),
          addressName: "objectId",
          key: "objectId",
          method: Web3SuiRequestMethods.signTransaction,
          json: json),
      version: Web3ValidatorUtils.parseBigInt(
          key: "version",
          method: Web3SuiRequestMethods.signTransaction,
          json: json),
      digest: Web3ValidatorUtils.parseBase58(
          key: "digest",
          method: Web3SuiRequestMethods.signTransaction,
          json: json),
      initialSharedVersion: Web3ValidatorUtils.parseBigInt(
          key: "initialSharedVersion",
          method: Web3SuiRequestMethods.signTransaction,
          json: json),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      type.name: {
        'objectId': objectId.address,
        'version': version?.toString(),
        'digest': digest,
        'initialSharedVersion': initialSharedVersion?.toString(),
      }
    };
  }

  @override
  SuiCallArg toTransactionCallArguments() {
    throw Web3SuiExceptionConstant.failedToResolveObject(objectId.address);
  }
}

enum Web3SuiArguments {
  gasCoin,
  input,
  result,
  nestedResult;

  static Web3SuiArguments fromName(String? name) {
    return values
        .firstWhere((e) => e.name.toLowerCase() == name?.toLowerCase());
  }
}

abstract class Web3SuiTransactionArgument {
  final Web3SuiArguments type;
  const Web3SuiTransactionArgument(this.type);
  factory Web3SuiTransactionArgument.fromJson(Map<String, dynamic> json) {
    final key = Web3ValidatorUtils.containsOnlyOnce(
        keys: ["GasCoin", "Input", "Result", "NestedResult"],
        name: "Argument",
        method: Web3SuiRequestMethods.signTransaction,
        json: json);
    final type = Web3SuiArguments.fromName(key);
    return switch (type) {
      Web3SuiArguments.gasCoin =>
        Web3SuiTransactionArgumentGasCoin.fromJson(json),
      Web3SuiArguments.input => Web3SuiTransactionArgumentInput.fromJson(json),
      Web3SuiArguments.result =>
        Web3SuiTransactionArgumentResult.fromJson(json),
      Web3SuiArguments.nestedResult =>
        Web3SuiTransactionArgumentNestedResult.fromJson(json)
    };
  }

  factory Web3SuiTransactionArgument.fromJsonV1(Map<String, dynamic> json) {
    final key = Web3ValidatorUtils.parseString(
        key: r"kind",
        method: Web3SuiRequestMethods.signTransaction,
        json: json);
    final type = Web3SuiArguments.fromName(key);
    return switch (type) {
      Web3SuiArguments.gasCoin => Web3SuiTransactionArgumentGasCoin(),
      Web3SuiArguments.input =>
        Web3SuiTransactionArgumentInput.fromJsonV1(json),
      Web3SuiArguments.result =>
        Web3SuiTransactionArgumentResult.fromJsonV1(json),
      Web3SuiArguments.nestedResult =>
        Web3SuiTransactionArgumentNestedResult.fromJsonV1(json)
    };
  }

  T cast<T extends Web3SuiTransactionArgument>() {
    if (this is! T) {
      throw Web3RequestExceptionConst.internalErrorParsingTransactionFailed;
    }
    return this as T;
  }

  Map<String, dynamic> toJson();
  SuiArgument toTransactionArguments();
}

class Web3SuiTransactionArgumentGasCoin extends Web3SuiTransactionArgument {
  const Web3SuiTransactionArgumentGasCoin() : super(Web3SuiArguments.gasCoin);
  factory Web3SuiTransactionArgumentGasCoin.fromJson(
      Map<String, dynamic> json) {
    Web3ValidatorUtils.parseBool(
        key: "GasCoin",
        method: Web3SuiRequestMethods.signTransaction,
        json: json);
    return Web3SuiTransactionArgumentGasCoin();
  }

  @override
  Map<String, dynamic> toJson() {
    return {"GasCoin": true};
  }

  @override
  SuiArgument toTransactionArguments() {
    return SuiArgumentGasCoin();
  }
}

class Web3SuiTransactionArgumentInput extends Web3SuiTransactionArgument {
  final int input;
  const Web3SuiTransactionArgumentInput(this.input)
      : super(Web3SuiArguments.input);
  factory Web3SuiTransactionArgumentInput.fromJson(Map<String, dynamic> json) {
    return Web3SuiTransactionArgumentInput(Web3ValidatorUtils.parseInt(
        key: "Input",
        method: Web3SuiRequestMethods.signTransaction,
        json: json));
  }
  factory Web3SuiTransactionArgumentInput.fromJsonV1(
      Map<String, dynamic> json) {
    return Web3SuiTransactionArgumentInput(Web3ValidatorUtils.parseInt(
        key: "index",
        method: Web3SuiRequestMethods.signTransaction,
        json: json));
  }
  @override
  Map<String, dynamic> toJson() {
    return {"Input": input};
  }

  @override
  SuiArgument toTransactionArguments() {
    return SuiArgumentInput(input);
  }
}

class Web3SuiTransactionArgumentResult extends Web3SuiTransactionArgument {
  final int result;
  const Web3SuiTransactionArgumentResult(this.result)
      : super(Web3SuiArguments.result);
  factory Web3SuiTransactionArgumentResult.fromJson(Map<String, dynamic> json) {
    return Web3SuiTransactionArgumentResult(Web3ValidatorUtils.parseInt(
        key: "Result",
        method: Web3SuiRequestMethods.signTransaction,
        json: json));
  }
  factory Web3SuiTransactionArgumentResult.fromJsonV1(
      Map<String, dynamic> json) {
    return Web3SuiTransactionArgumentResult(Web3ValidatorUtils.parseInt(
        key: "index",
        method: Web3SuiRequestMethods.signTransaction,
        json: json));
  }
  @override
  Map<String, dynamic> toJson() {
    return {"Result": result};
  }

  @override
  SuiArgument toTransactionArguments() {
    return SuiArgumentResult(result);
  }
}

class Web3SuiTransactionArgumentNestedResult
    extends Web3SuiTransactionArgument {
  final int index;
  final int resultIndex;
  const Web3SuiTransactionArgumentNestedResult(
      {required this.index, required this.resultIndex})
      : super(Web3SuiArguments.nestedResult);
  factory Web3SuiTransactionArgumentNestedResult.fromJson(
      Map<String, dynamic> json) {
    final r = Web3ValidatorUtils.parseList<List<int>, int>(
        key: "NestedResult",
        method: Web3SuiRequestMethods.signTransaction,
        json: json,
        length: 2);
    return Web3SuiTransactionArgumentNestedResult(
        index: r.first, resultIndex: r.last);
  }
  factory Web3SuiTransactionArgumentNestedResult.fromJsonV1(
      Map<String, dynamic> json) {
    return Web3SuiTransactionArgumentNestedResult(
        index: Web3ValidatorUtils.parseInt(
            key: "index",
            method: Web3SuiRequestMethods.signTransaction,
            json: json),
        resultIndex: Web3ValidatorUtils.parseInt(
            key: "resultIndex",
            method: Web3SuiRequestMethods.signTransaction,
            json: json));
  }
  @override
  Map<String, dynamic> toJson() {
    return {
      "NestedResult": [index, resultIndex]
    };
  }

  @override
  SuiArgument toTransactionArguments() {
    return SuiArgumentNestedResult(
        commandIndex: index, resultIndex: resultIndex);
  }
}

class Web3SuiTransactionCommandMoveCall extends Web3SuiTransactionCommand {
  final SuiAddress package;
  final String module;
  final String function;
  final List<String> typeArguments;
  final List<Web3SuiTransactionArgument> arguments;

  Web3SuiTransactionCommandMoveCall({
    required this.package,
    required this.module,
    required this.function,
    required this.typeArguments,
    required this.arguments,
  }) : super(Web3SuiTransactionCommands.moveCall);

  factory Web3SuiTransactionCommandMoveCall.fromJson(
      Map<String, dynamic> json) {
    return Web3SuiTransactionCommandMoveCall(
      package: Web3ValidatorUtils.parseAddress(
          key: "package",
          onParse: (address) => SuiAddress(address),
          method: Web3SuiRequestMethods.signTransaction,
          json: json,
          addressName: "Package"),
      module: Web3ValidatorUtils.parseString(
          key: "module",
          method: Web3SuiRequestMethods.signTransaction,
          json: json),
      function: Web3ValidatorUtils.parseString(
          key: "function",
          method: Web3SuiRequestMethods.signTransaction,
          json: json),
      typeArguments: Web3ValidatorUtils.parseList<List<String>, String>(
          key: "typeArguments",
          method: Web3SuiRequestMethods.signTransaction,
          json: json,
          allowEmpty: true),
      arguments: Web3ValidatorUtils.parseList<List<Map<String, dynamic>>,
                  Map<String, dynamic>>(
              key: "arguments",
              method: Web3SuiRequestMethods.signTransaction,
              json: json,
              allowEmpty: true)
          .map((e) => Web3SuiTransactionArgument.fromJson(e))
          .toList(),
    );
  }
  factory Web3SuiTransactionCommandMoveCall.fromJsonV1(
      Map<String, dynamic> json) {
    final target = Web3ValidatorUtils.praseObject<List<String>, String>(
      json: json,
      key: "target",
      method: Web3SuiRequestMethods.signTransaction,
      onParse: (value) {
        final split = value.split("::");
        if (split.length != 3) {
          return null;
        }
        return split;
      },
    );
    return Web3SuiTransactionCommandMoveCall(
      package: Web3ValidatorUtils.parse<SuiAddress, String>(
          onParse: (address) => SuiAddress(address),
          method: Web3SuiRequestMethods.signTransaction,
          value: target[0],
          onFailed: () => Web3SuiExceptionConstant.invalidObject(target[0])),
      module: target[1],
      function: target[2],
      typeArguments: Web3ValidatorUtils.parseList<List<String>, String>(
          key: "typeArguments",
          method: Web3SuiRequestMethods.signTransaction,
          json: json,
          allowEmpty: true),
      arguments: Web3ValidatorUtils.parseList<List<Map<String, dynamic>>,
                  Map<String, dynamic>>(
              key: "arguments",
              method: Web3SuiRequestMethods.signTransaction,
              json: json,
              allowEmpty: true)
          .map((e) => Web3SuiTransactionArgument.fromJsonV1(e))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      type.name: {
        'package': package.address,
        'module': module,
        'function': function,
        'typeArguments': typeArguments,
        'arguments': arguments.map((e) => e.toJson()).toList(),
      }
    };
  }

  @override
  SuiCommand toTrnsactionCommand() {
    return SuiCommandMoveCall(SuiProgrammableMoveCall(
        package: package,
        module: module,
        function: function,
        arguments: arguments.map((e) => e.toTransactionArguments()).toList()));
  }
}

class Web3SuiTransactionCommandTransferObjects
    extends Web3SuiTransactionCommand {
  final Web3SuiTransactionArgument address;
  final List<Web3SuiTransactionArgument> objects;

  Web3SuiTransactionCommandTransferObjects({
    required this.address,
    required this.objects,
  }) : super(Web3SuiTransactionCommands.transferObject);

  factory Web3SuiTransactionCommandTransferObjects.fromJson(
      Map<String, dynamic> json) {
    return Web3SuiTransactionCommandTransferObjects(
      address: Web3SuiTransactionArgument.fromJson(Web3ValidatorUtils.parseMap(
          key: "address",
          method: Web3SuiRequestMethods.signTransaction,
          json: json)),
      objects: Web3ValidatorUtils.parseList<List<Map<String, dynamic>>,
                  Map<String, dynamic>>(
              key: "objects",
              method: Web3SuiRequestMethods.signTransaction,
              json: json)
          .map((e) => Web3SuiTransactionArgument.fromJson(e))
          .toList(),
    );
  }
  factory Web3SuiTransactionCommandTransferObjects.fromJsonV1(
      Map<String, dynamic> json) {
    return Web3SuiTransactionCommandTransferObjects(
      address: Web3SuiTransactionArgument.fromJsonV1(
          Web3ValidatorUtils.parseMap(
              key: "address",
              method: Web3SuiRequestMethods.signTransaction,
              json: json)),
      objects: Web3ValidatorUtils.parseList<List<Map<String, dynamic>>,
                  Map<String, dynamic>>(
              key: "objects",
              method: Web3SuiRequestMethods.signTransaction,
              json: json)
          .map((e) => Web3SuiTransactionArgument.fromJsonV1(e))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      type.name: {
        'address': address.toJson(),
        'objects': objects.map((e) => e.toJson()).toList(),
      }
    };
  }

  @override
  SuiCommand toTrnsactionCommand() {
    return SuiCommandTransferObjects(
        objects: objects.map((e) => e.toTransactionArguments()).toList(),
        address: address.toTransactionArguments());
  }
}

class Web3SuiTransactionDataV2 {
  final int version;
  final SuiAddress? sender;
  final Web3SuiTransactionExpiration? expiration;
  final Web3SuiTransactionGasData gasData;
  final List<Web3SuiTransactionCallArg> inputs;
  final List<Web3SuiTransactionCommand> commands;
  final dynamic extensions;

  Web3SuiTransactionDataV2(
      {required this.version,
      this.sender,
      this.expiration,
      required this.gasData,
      required this.inputs,
      required this.commands,
      this.extensions});
  factory Web3SuiTransactionDataV2.fromJson(Map<String, dynamic> json) {
    final version = Web3ValidatorUtils.parseInt(
        key: "version",
        method: Web3SuiRequestMethods.signTransaction,
        json: json);
    switch (version) {
      case 1:
        return Web3SuiTransactionDataV2.fromJsonV1(json);
      case 2:
        return Web3SuiTransactionDataV2.fromJsonV2(json);
      default:
        throw Web3SuiExceptionConstant.unsuportedTransactionVersion;
    }
  }

  factory Web3SuiTransactionDataV2.fromJsonV2(Map<String, dynamic> json) {
    return Web3SuiTransactionDataV2(
      version: Web3ValidatorUtils.parseInt(
          key: "version",
          method: Web3SuiRequestMethods.signTransaction,
          json: json),
      sender: Web3ValidatorUtils.parseAddress(
          onParse: (address) => SuiAddress(address),
          key: "sender",
          method: Web3SuiRequestMethods.signTransaction,
          json: json),
      expiration: Web3ValidatorUtils.parse<Web3SuiTransactionExpiration?,
          Map<String, dynamic>>(
        onParse: (value) {
          return Web3SuiTransactionExpiration.fromJson(value);
        },
        value: json["expiration"],
        method: Web3SuiRequestMethods.signTransaction,
        onFailed: () {
          throw Web3RequestExceptionConst.invalidParametersParsingObjectFailed(
              "expiration");
        },
      ),
      gasData: Web3SuiTransactionGasData.fromJson(Web3ValidatorUtils.parseMap(
          key: "gasData",
          method: Web3SuiRequestMethods.signTransaction,
          json: json)),
      inputs: Web3ValidatorUtils.parseList<List<Map<String, dynamic>>,
                  Map<String, dynamic>>(
              key: "inputs",
              json: json,
              method: Web3SuiRequestMethods.signTransaction,
              allowEmpty: true)
          .map((e) => Web3SuiTransactionCallArg.fromJson(e))
          .toList(),
      commands: Web3ValidatorUtils.parseList<List<Map<String, dynamic>>,
                  Map<String, dynamic>>(
              key: "commands",
              json: json,
              method: Web3SuiRequestMethods.signTransaction,
              allowEmpty: true)
          .map(
            (e) => Web3SuiTransactionCommand.fromJson(e),
          )
          .toList(),
      extensions: json['extensions'],
    );
  }

  factory Web3SuiTransactionDataV2.fromJsonV1(Map<String, dynamic> json) {
    return Web3SuiTransactionDataV2(
      version: Web3ValidatorUtils.parseInt(
          key: "version",
          method: Web3SuiRequestMethods.signTransaction,
          json: json),
      sender: Web3ValidatorUtils.parseAddress(
          onParse: (address) => SuiAddress(address),
          key: "sender",
          method: Web3SuiRequestMethods.signTransaction,
          json: json),
      expiration: Web3ValidatorUtils.parse<Web3SuiTransactionExpiration?,
          Map<String, dynamic>>(
        onParse: (value) {
          return Web3SuiTransactionExpiration.fromJson(value);
        },
        value: json["expiration"],
        method: Web3SuiRequestMethods.signTransaction,
        onFailed: () {
          throw Web3RequestExceptionConst.invalidParametersParsingObjectFailed(
              "expiration");
        },
      ),
      gasData: Web3SuiTransactionGasData.fromJson(Web3ValidatorUtils.parseMap(
          key: "gasConfig",
          method: Web3SuiRequestMethods.signTransaction,
          json: json)),
      inputs: Web3ValidatorUtils.parseList<List<Map<String, dynamic>>,
                  Map<String, dynamic>>(
              key: "inputs",
              json: json,
              method: Web3SuiRequestMethods.signTransaction,
              allowEmpty: true)
          .map((e) => Web3SuiTransactionCallArg.fromJsonV1(e))
          .toList(),
      commands: Web3ValidatorUtils.parseList<List<Map<String, dynamic>>,
                  Map<String, dynamic>>(
              key: "transactions",
              json: json,
              method: Web3SuiRequestMethods.signTransaction,
              allowEmpty: true)
          .map((e) => Web3SuiTransactionCommand.fromJsonV1(e))
          .toList(),
      extensions: json['extensions'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': 2,
      'sender': sender?.address,
      'expiration': expiration?.toJson(),
      'gasData': gasData.toJson(),
      'inputs': inputs.map((e) => e.toJson()).toList(),
      'commands': commands.map((e) => e.toJson()).toList(),
      'extensions': extensions,
    };
  }
}

enum Web3SuiTransactionExpirations {
  epoch("Epoch"),
  none("None");

  final String name;
  const Web3SuiTransactionExpirations(this.name);
  static Web3SuiTransactionExpirations fromName(String? name) {
    return values
        .firstWhere((e) => e.name.toLowerCase() == name?.toLowerCase());
  }
}

abstract class Web3SuiTransactionExpiration {
  final Web3SuiTransactionExpirations type;
  const Web3SuiTransactionExpiration(this.type);
  factory Web3SuiTransactionExpiration.fromJson(Map<String, dynamic> json) {
    final key = Web3ValidatorUtils.containsOnlyOnce(
        json: json,
        method: Web3SuiRequestMethods.signTransaction,
        keys: Web3SuiTransactionExpirations.values.map((e) => e.name).toList(),
        name: "Expiration");
    final type = Web3SuiTransactionExpirations.fromName(key);
    return switch (type) {
      Web3SuiTransactionExpirations.none =>
        Web3SuiTransactionExpirationNone.fromJson(json),
      Web3SuiTransactionExpirations.epoch =>
        Web3SuiTransactionExpirationEpoch.fromJson(json)
    };
  }
  SuiTransactionExpiration toTransactionExpiration();
  Map<String, dynamic> toJson();
}

class Web3SuiTransactionExpirationNone extends Web3SuiTransactionExpiration {
  const Web3SuiTransactionExpirationNone()
      : super(Web3SuiTransactionExpirations.none);
  factory Web3SuiTransactionExpirationNone.fromJson(Map<String, dynamic> json) {
    Web3ValidatorUtils.parseBool(
        key: Web3SuiTransactionExpirations.none.name,
        method: Web3SuiRequestMethods.signTransaction,
        json: json);
    return Web3SuiTransactionExpirationNone();
  }

  @override
  Map<String, dynamic> toJson() {
    return {type.name: true};
  }

  @override
  SuiTransactionExpiration toTransactionExpiration() {
    return SuiTransactionExpirationNone();
  }
}

class Web3SuiTransactionExpirationEpoch extends Web3SuiTransactionExpiration {
  final BigInt epoch;
  const Web3SuiTransactionExpirationEpoch(this.epoch)
      : super(Web3SuiTransactionExpirations.epoch);
  factory Web3SuiTransactionExpirationEpoch.fromJson(
      Map<String, dynamic> json) {
    return Web3SuiTransactionExpirationEpoch(Web3ValidatorUtils.parseBigInt(
        key: Web3SuiTransactionExpirations.epoch.name,
        method: Web3SuiRequestMethods.signTransaction,
        json: json));
  }

  @override
  Map<String, dynamic> toJson() {
    return {type.name: epoch.toString()};
  }

  @override
  SuiTransactionExpiration toTransactionExpiration() {
    return SuiTransactionExpirationEpoch(epochId: epoch);
  }
}

class Web3SuiTransactionGasData {
  final BigInt? budget;
  final BigInt? price;
  final SuiAddress? owner;
  final List<Web3SuiTransactionImmOrOwnedObject>? payment;
  bool get hasFee => budget != null && price != null;

  Web3SuiTransactionGasData({
    this.budget,
    this.price,
    this.owner,
    this.payment,
  });

  factory Web3SuiTransactionGasData.fromJson(Map<String, dynamic> json) {
    return Web3SuiTransactionGasData(
      budget: Web3ValidatorUtils.parseBigInt(
          key: "budget",
          method: Web3SuiRequestMethods.signTransaction,
          json: json),
      price: Web3ValidatorUtils.parseBigInt(
          key: "price",
          method: Web3SuiRequestMethods.signTransaction,
          json: json),
      owner: Web3ValidatorUtils.parseAddress(
          onParse: (address) => SuiAddress(address),
          key: "owner",
          method: Web3SuiRequestMethods.signTransaction,
          json: json),
      payment: Web3ValidatorUtils.parseList<List<Map<String, dynamic>>?,
                  Map<String, dynamic>>(
              key: "payment",
              method: Web3SuiRequestMethods.signTransaction,
              json: json,
              allowEmpty: true)
          ?.map((e) => Web3SuiTransactionImmOrOwnedObject.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'budget': budget?.toString(),
      'price': price?.toString(),
      'owner': owner?.address,
      'payment': payment?.map((e) => e.toJson()).toList(),
    };
  }

  SuiGasData toTransactionGasData(
      {required SuiAddress owner,
      required BigInt budget,
      required BigInt price,
      List<SuiObjectRef> payment = const []}) {
    return SuiGasData(
        payment: this.payment?.map((e) => e.toObjectRef()).toList() ?? payment,
        owner: this.owner ?? owner,
        price: this.price ?? price,
        budget: this.budget ?? budget);
  }
}

class Web3SuiTransactionCommandSplitCoins extends Web3SuiTransactionCommand {
  final Web3SuiTransactionArgument coin;
  final List<Web3SuiTransactionArgument> amounts;

  Web3SuiTransactionCommandSplitCoins({
    required this.coin,
    required this.amounts,
  }) : super(Web3SuiTransactionCommands.splitCoins);

  factory Web3SuiTransactionCommandSplitCoins.fromJson(
      Map<String, dynamic> json) {
    return Web3SuiTransactionCommandSplitCoins(
      coin: Web3SuiTransactionArgument.fromJson(Web3ValidatorUtils.parseMap(
          key: "coin",
          method: Web3SuiRequestMethods.signTransaction,
          json: json)),
      amounts: Web3ValidatorUtils.parseList<List<Map<String, dynamic>>,
                  Map<String, dynamic>>(
              key: "amounts",
              method: Web3SuiRequestMethods.signTransaction,
              json: json)
          .map((e) => Web3SuiTransactionArgument.fromJson(e))
          .toList(),
    );
  }
  factory Web3SuiTransactionCommandSplitCoins.fromJsonV1(
      Map<String, dynamic> json) {
    return Web3SuiTransactionCommandSplitCoins(
      coin: Web3SuiTransactionArgument.fromJsonV1(Web3ValidatorUtils.parseMap(
          key: "coin",
          method: Web3SuiRequestMethods.signTransaction,
          json: json)),
      amounts: Web3ValidatorUtils.parseList<List<Map<String, dynamic>>,
                  Map<String, dynamic>>(
              key: "amounts",
              method: Web3SuiRequestMethods.signTransaction,
              json: json)
          .map((e) => Web3SuiTransactionArgument.fromJsonV1(e))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      type.name: {
        'coin': coin.toJson(),
        'amounts': amounts.map((e) => e.toJson()).toList(),
      }
    };
  }

  @override
  SuiCommand toTrnsactionCommand() {
    return SuiCommandSplitCoins(
        amounts: amounts.map((e) => e.toTransactionArguments()).toList(),
        coin: coin.toTransactionArguments());
  }
}

class Web3SuiTransactionCommandMergeCoins extends Web3SuiTransactionCommand {
  final Web3SuiTransactionArgument destination;
  final List<Web3SuiTransactionArgument> sources;

  Web3SuiTransactionCommandMergeCoins({
    required this.destination,
    required this.sources,
  }) : super(Web3SuiTransactionCommands.mergeCoins);

  factory Web3SuiTransactionCommandMergeCoins.fromJson(
      Map<String, dynamic> json) {
    return Web3SuiTransactionCommandMergeCoins(
      destination: Web3SuiTransactionArgument.fromJson(
          Web3ValidatorUtils.parseMap(
              key: "destination",
              method: Web3SuiRequestMethods.signTransaction,
              json: json)),
      sources: Web3ValidatorUtils.parseList<List<Map<String, dynamic>>,
                  Map<String, dynamic>>(
              key: "sources",
              method: Web3SuiRequestMethods.signTransaction,
              json: json)
          .map((e) => Web3SuiTransactionArgument.fromJson(e))
          .toList(),
    );
  }
  factory Web3SuiTransactionCommandMergeCoins.fromJsonV1(
      Map<String, dynamic> json) {
    return Web3SuiTransactionCommandMergeCoins(
      destination: Web3SuiTransactionArgument.fromJsonV1(
          Web3ValidatorUtils.parseMap(
              key: "destination",
              method: Web3SuiRequestMethods.signTransaction,
              json: json)),
      sources: Web3ValidatorUtils.parseList<List<Map<String, dynamic>>,
                  Map<String, dynamic>>(
              key: "sources",
              method: Web3SuiRequestMethods.signTransaction,
              json: json)
          .map((e) => Web3SuiTransactionArgument.fromJsonV1(e))
          .toList(),
    );
  }
  @override
  Map<String, dynamic> toJson() {
    return {
      type.name: {
        'destination': destination.toJson(),
        'sources': sources.map((e) => e.toJson()).toList(),
      }
    };
  }

  @override
  SuiCommand toTrnsactionCommand() {
    return SuiCommandMergeCoins(
        sources: sources.map((e) => e.toTransactionArguments()).toList(),
        destination: destination.toTransactionArguments());
  }
}

class Web3SuiTransactionCommandPublish extends Web3SuiTransactionCommand {
  final List<String> modules;
  final List<SuiAddress> dependencies;

  Web3SuiTransactionCommandPublish(
      {required this.modules, required this.dependencies})
      : super(Web3SuiTransactionCommands.publish);
  factory Web3SuiTransactionCommandPublish.fromJson(Map<String, dynamic> json) {
    return Web3SuiTransactionCommandPublish(
      modules: Web3ValidatorUtils.parseList<List<String>, String>(
          key: "modules",
          method: Web3SuiRequestMethods.signTransaction,
          json: json,
          allowEmpty: false),
      dependencies: Web3ValidatorUtils.parseList<List<String>, String>(
              key: "dependencies",
              method: Web3SuiRequestMethods.signTransaction,
              json: json,
              allowEmpty: true)
          .map((e) => SuiAddress(e))
          .toList(),
    );
  }

  factory Web3SuiTransactionCommandPublish.fromJsonV1(
      Map<String, dynamic> json) {
    return Web3SuiTransactionCommandPublish(
      modules: Web3ValidatorUtils.parse<List<String>, List>(
        value: json["modules"],
        method: Web3SuiRequestMethods.signTransaction,
        onParse: (value) {
          return value
              .map((e) => (e as List).cast<int>())
              .map((e) => StringUtils.decode(e, type: StringEncoding.base64))
              .toList();
        },
        onFailed: () =>
            throw Web3SuiExceptionConstant.invalidCommandParameters("publish"),
      ),
      dependencies: Web3ValidatorUtils.parseList<List<String>, String>(
              key: "dependencies",
              method: Web3SuiRequestMethods.signTransaction,
              json: json,
              allowEmpty: true)
          .map((e) => SuiAddress(e))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      type.name: {
        'modules': modules,
        'dependencies': dependencies.map((e) => e.address).toList(),
      }
    };
  }

  @override
  SuiCommand toTrnsactionCommand() {
    return SuiCommandPublish(
        modules: modules
            .map((e) => StringUtils.encode(e, type: StringEncoding.base64))
            .toList(),
        dependencies: dependencies);
  }
}

class Web3SuiTransactionCommandMakeMoveVec extends Web3SuiTransactionCommand {
  final String? typeArgument;
  final List<Web3SuiTransactionArgument> elements;

  Web3SuiTransactionCommandMakeMoveVec({
    this.typeArgument,
    required this.elements,
  }) : super(Web3SuiTransactionCommands.makeMoveVec);

  factory Web3SuiTransactionCommandMakeMoveVec.fromJson(
      Map<String, dynamic> json) {
    return Web3SuiTransactionCommandMakeMoveVec(
      typeArgument: Web3ValidatorUtils.parseString(
          key: "type",
          method: Web3SuiRequestMethods.signTransaction,
          json: json),
      elements: Web3ValidatorUtils.parseList<List<Map<String, dynamic>>,
                  Map<String, dynamic>>(
              key: "elements",
              method: Web3SuiRequestMethods.signTransaction,
              json: json,
              allowEmpty: true)
          .map((e) => Web3SuiTransactionArgument.fromJson(e))
          .toList(),
    );
  }

  factory Web3SuiTransactionCommandMakeMoveVec.fromJsonV1(
      Map<String, dynamic> json) {
    return Web3SuiTransactionCommandMakeMoveVec(
      typeArgument: Web3ValidatorUtils.parse<String?, Map>(
        value: json["type"],
        onParse: (value) {
          if (value.containsKey("None")) return null;
          if (value.containsKey("Some")) return value["Some"];
          throw Web3SuiExceptionConstant.invalidCommandParameters(
              "MakeMoveVec");
        },
        method: Web3SuiRequestMethods.signTransaction,
        onFailed: () => throw Web3SuiExceptionConstant.invalidCommandParameters(
            "MakeMoveVec"),
      ),
      elements: Web3ValidatorUtils.parseList<List<Map<String, dynamic>>,
                  Map<String, dynamic>>(
              key: "objects",
              method: Web3SuiRequestMethods.signTransaction,
              json: json,
              allowEmpty: true)
          .map((e) => Web3SuiTransactionArgument.fromJsonV1(e))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      type.name: {
        'type': typeArgument,
        'elements': elements.map((e) => e.toJson()).toList()
      }
    };
  }

  @override
  SuiCommand toTrnsactionCommand() {
    return SuiCommandMakeMoveVec(
        typeInput: typeArgument == null
            ? null
            : SuiTypeTagUtils.parseTag(typeArgument!),
        elements: elements.map((e) => e.toTransactionArguments()).toList());
  }
}

class Web3SuiTransactionCommandUpgrade extends Web3SuiTransactionCommand {
  final List<String> modules;
  final List<SuiAddress> dependencies;
  final SuiAddress package;
  final Web3SuiTransactionArgument ticket;

  Web3SuiTransactionCommandUpgrade({
    required this.modules,
    required this.dependencies,
    required this.package,
    required this.ticket,
  }) : super(Web3SuiTransactionCommands.upgrade);

  factory Web3SuiTransactionCommandUpgrade.fromJson(Map<String, dynamic> json) {
    return Web3SuiTransactionCommandUpgrade(
      modules: Web3ValidatorUtils.parseList<List<String>, String>(
          key: "modules",
          method: Web3SuiRequestMethods.signTransaction,
          json: json),
      dependencies: Web3ValidatorUtils.parseList<List<String>, String>(
              key: "dependencies",
              method: Web3SuiRequestMethods.signTransaction,
              json: json,
              allowEmpty: true)
          .map((e) => SuiAddress(e))
          .toList(),
      package: Web3ValidatorUtils.parseAddress(
          key: "package",
          onParse: (address) => SuiAddress(address),
          method: Web3SuiRequestMethods.signTransaction,
          json: json,
          addressName: "package"),
      ticket: Web3SuiTransactionArgument.fromJson(Web3ValidatorUtils.parseMap(
          key: "ticket",
          method: Web3SuiRequestMethods.signTransaction,
          json: json)),
    );
  }

  factory Web3SuiTransactionCommandUpgrade.fromJsonV1(
      Map<String, dynamic> json) {
    return Web3SuiTransactionCommandUpgrade(
      modules: Web3ValidatorUtils.parse<List<String>, List>(
        value: json["modules"],
        method: Web3SuiRequestMethods.signTransaction,
        onParse: (value) {
          return value
              .map((e) => (e as List).cast<int>())
              .map((e) => StringUtils.decode(e, type: StringEncoding.base64))
              .toList();
        },
        onFailed: () =>
            throw Web3SuiExceptionConstant.invalidCommandParameters("upgrade"),
      ),
      dependencies: Web3ValidatorUtils.parseList<List<String>, String>(
              key: "dependencies",
              method: Web3SuiRequestMethods.signTransaction,
              json: json,
              allowEmpty: true)
          .map((e) => SuiAddress(e))
          .toList(),
      package: Web3ValidatorUtils.parseAddress(
          key: "packageId",
          onParse: (address) => SuiAddress(address),
          method: Web3SuiRequestMethods.signTransaction,
          json: json,
          addressName: "package"),
      ticket: Web3SuiTransactionArgument.fromJsonV1(Web3ValidatorUtils.parseMap(
          key: "ticket",
          method: Web3SuiRequestMethods.signTransaction,
          json: json)),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      type.name: {
        'modules': modules,
        'dependencies': dependencies.map((e) => e.address).toList(),
        'package': package.address,
        'ticket': ticket.toJson(),
      }
    };
  }

  @override
  SuiCommand toTrnsactionCommand() {
    return SuiCommandUpgrade(
        modules: modules
            .map((e) => StringUtils.encode(e, type: StringEncoding.base64))
            .toList(),
        dependencies: dependencies,
        package: package,
        ticket: ticket.toTransactionArguments());
  }
}

/// A single command in a programmable transaction.
enum Web3SuiTransactionCommands {
  moveCall("MoveCall"),
  transferObject("TransferObjects"),
  splitCoins("SplitCoins"),
  mergeCoins("MergeCoins"),
  publish("Publish"),
  makeMoveVec("MakeMoveVec"),
  upgrade("Upgrade");

  const Web3SuiTransactionCommands(this.name);
  final String name;
  static Web3SuiTransactionCommands fromName(String? name) {
    return values
        .firstWhere((e) => e.name.toLowerCase() == name?.toLowerCase());
  }
}

abstract class Web3SuiTransactionCommand {
  final Web3SuiTransactionCommands type;
  const Web3SuiTransactionCommand(this.type);
  factory Web3SuiTransactionCommand.fromJson(Map<String, dynamic> json) {
    final key = Web3ValidatorUtils.containsOnlyOnce(
        json: json,
        method: Web3SuiRequestMethods.signTransaction,
        keys: Web3SuiTransactionCommands.values.map((e) => e.name).toList(),
        name: "Command");
    final type = Web3SuiTransactionCommands.fromName(key);
    json = Web3ValidatorUtils.parseMap(
        key: key, method: Web3SuiRequestMethods.signTransaction, json: json);
    return switch (type) {
      Web3SuiTransactionCommands.moveCall =>
        Web3SuiTransactionCommandMoveCall.fromJson(json),
      Web3SuiTransactionCommands.transferObject =>
        Web3SuiTransactionCommandTransferObjects.fromJson(json),
      Web3SuiTransactionCommands.splitCoins =>
        Web3SuiTransactionCommandSplitCoins.fromJson(json),
      Web3SuiTransactionCommands.mergeCoins =>
        Web3SuiTransactionCommandMergeCoins.fromJson(json),
      Web3SuiTransactionCommands.publish =>
        Web3SuiTransactionCommandPublish.fromJson(json),
      Web3SuiTransactionCommands.makeMoveVec =>
        Web3SuiTransactionCommandMakeMoveVec.fromJson(json),
      Web3SuiTransactionCommands.upgrade =>
        Web3SuiTransactionCommandUpgrade.fromJson(json),
    };
  }
  factory Web3SuiTransactionCommand.fromJsonV1(Map<String, dynamic> json) {
    final type = Web3ValidatorUtils.parse<Web3SuiTransactionCommands, String>(
      method: Web3SuiRequestMethods.signTransaction,
      value: json["kind"],
      onParse: (value) => Web3SuiTransactionCommands.fromName(value),
      onFailed: () => Web3SuiExceptionConstant.parsingTransactionFailed,
    );
    return switch (type) {
      Web3SuiTransactionCommands.moveCall =>
        Web3SuiTransactionCommandMoveCall.fromJsonV1(json),
      Web3SuiTransactionCommands.transferObject =>
        Web3SuiTransactionCommandTransferObjects.fromJsonV1(json),
      Web3SuiTransactionCommands.splitCoins =>
        Web3SuiTransactionCommandSplitCoins.fromJsonV1(json),
      Web3SuiTransactionCommands.mergeCoins =>
        Web3SuiTransactionCommandMergeCoins.fromJsonV1(json),
      Web3SuiTransactionCommands.publish =>
        Web3SuiTransactionCommandPublish.fromJsonV1(json),
      Web3SuiTransactionCommands.makeMoveVec =>
        Web3SuiTransactionCommandMakeMoveVec.fromJsonV1(json),
      Web3SuiTransactionCommands.upgrade =>
        Web3SuiTransactionCommandUpgrade.fromJsonV1(json),
    };
  }

  Map<String, dynamic> toJson();

  T cast<T extends Web3SuiTransactionCommand>() {
    if (this is! T) {
      throw Web3RequestExceptionConst.internalErrorParsingTransactionFailed;
    }
    return this as T;
  }

  SuiCommand toTrnsactionCommand();
}

class Web3SuiSignTransactionResponse {
  final String bytes;
  final String signature;
  final String digest;
  const Web3SuiSignTransactionResponse(
      {required this.bytes, required this.signature, required this.digest});
  factory Web3SuiSignTransactionResponse.fromJson(Map<String, dynamic> json) {
    return Web3SuiSignTransactionResponse(
        bytes: json["bytes"],
        signature: json["signature"],
        digest: json["digest"]);
  }
  Map<String, dynamic> toJson() {
    return {"bytes": bytes, "signature": signature, "digest": digest};
  }
}

class Web3SuiSignAndExecuteTransactionResponse {
  final String digest;
  final String effects;
  final Map<String, dynamic> excuteResponse;
  const Web3SuiSignAndExecuteTransactionResponse(
      {required this.digest,
      required this.effects,
      required this.excuteResponse});
  factory Web3SuiSignAndExecuteTransactionResponse.fromJson(
      Map<String, dynamic> json) {
    return Web3SuiSignAndExecuteTransactionResponse(
        digest: json["digest"],
        effects: json["effects"],
        excuteResponse: json["excuteResponse"]);
  }
  Map<String, dynamic> toJson() {
    return {
      "digest": digest,
      "effects": effects,
      "excuteResponse": excuteResponse
    };
  }
}

class Web3SuiSignOrExecuteTransaction
    extends Web3SuiRequestParam<Map<String, dynamic>> {
  final SuiApiTransactionBlockResponseOptions? executeOptions;
  final SuiApiExecuteTransactionRequestType? executeType;
  final Web3SuiTransactionDataV2 transaction;
  @override
  final SuiAddress account;

  Web3SuiSignOrExecuteTransaction._(
      {required this.account,
      required this.transaction,
      required this.method,
      required this.executeOptions,
      required this.executeType});
  factory Web3SuiSignOrExecuteTransaction(
      {required Web3SuiTransactionDataV2 transaction,
      required SuiAddress account,
      required Web3RequestMethods method,
      required SuiApiTransactionBlockResponseOptions? executeOptions,
      required SuiApiExecuteTransactionRequestType? executeType}) {
    switch (method) {
      case Web3SuiRequestMethods.signTransaction:
      case Web3SuiRequestMethods.signAndExecuteTransaction:
      case Web3SuiRequestMethods.signAndExecuteTransactionBlock:
      case Web3SuiRequestMethods.signTransactionBlock:
        break;
      default:
        throw Web3RequestExceptionConst.internalError;
    }
    return Web3SuiSignOrExecuteTransaction._(
        account: account,
        transaction: transaction,
        method: method as Web3SuiRequestMethods,
        executeOptions: executeOptions,
        executeType: executeType);
  }

  factory Web3SuiSignOrExecuteTransaction.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: Web3MessageTypes.walletRequest.tag);
    final Map<String, dynamic> transaction =
        StringUtils.toJson(values.elementAs<String>(2));
    final method = Web3RequestMethods.fromTag(values.elementAt(0));
    return Web3SuiSignOrExecuteTransaction(
        account: SuiAddress(values.elementAs(1)),
        transaction: Web3SuiTransactionDataV2.fromJson(transaction),
        method: method,
        executeOptions: values.elemetMybeAs<
                SuiApiTransactionBlockResponseOptions, CborStringValue>(
            3,
            (e) => SuiApiTransactionBlockResponseOptions.fromJson(
                StringUtils.toJson(e.value))),
        executeType: values
            .elemetMybeAs<SuiApiExecuteTransactionRequestType, CborStringValue>(
                4,
                (e) => SuiApiExecuteTransactionRequestType.values
                    .firstWhere((n) => e.value == n.name)));
  }

  @override
  final Web3SuiRequestMethods method;

  bool get isExecute =>
      method == Web3SuiRequestMethods.signAndExecuteTransaction;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          method.tag,
          account.address,
          CborStringValue(StringUtils.fromJson(transaction.toJson())),
          StringUtils.tryFromJson(executeOptions?.toJson()),
          executeType?.name
        ]),
        type.tag);
  }

  @override
  Map<String, dynamic> toJson() {
    return {"account": account.address, "transaction": transaction.toJson()};
  }

  @override
  Web3SuiRequest<Map<String, dynamic>, Web3SuiSignOrExecuteTransaction>
      toRequest(
          {required Web3RequestApplicationInformation request,
          required Web3APPAuthentication authenticated,
          required List<APPCHAIN> chains}) {
    final SuiChain chain = super.findRequestChain(
        request: request, authenticated: authenticated, chains: chains);
    return Web3SuiRequest<Map<String, dynamic>,
            Web3SuiSignOrExecuteTransaction>(
        params: this,
        authenticated: authenticated,
        chain: chain,
        info: request);
  }
}
