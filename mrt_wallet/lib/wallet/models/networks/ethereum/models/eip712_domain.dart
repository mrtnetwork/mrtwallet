import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:blockchain_utils/utils/numbers/utils/bigint_utils.dart';
import 'package:on_chain/ethereum/src/address/evm_address.dart';

class EIP712Domain {
  final String name;
  final String version;
  final BigInt? chainId;
  final ETHAddress verifyingContract;
  final String? salt;
  EIP712Domain(
      {required this.name,
      this.chainId,
      required this.verifyingContract,
      required this.version,
      this.salt});
  static EIP712Domain? fromJson(Map<String, dynamic> message) {
    try {
      return EIP712Domain(
          name: message["name"],
          chainId: BigintUtils.tryParse(message["chainId"]),
          version: message["version"],
          verifyingContract: ETHAddress(message["verifyingContract"]),
          salt: message["salt"] == null
              ? null
              : BytesUtils.toHexString(
                  BytesUtils.fromHexString(message["salt"]),
                  prefix: "0x"));
    } catch (e) {
      return null;
    }
  }
}
