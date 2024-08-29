import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain/on_chain.dart';

class TronIssueTRC10Token {
  final TronAddress ownerAddress;
  final String name;
  final String? abbr;
  final BigInt? totalSupply;
  final int? precision;
  final String? description;
  final String? url;
  final String id;

  TronIssueTRC10Token({
    required this.ownerAddress,
    required this.name,
    required this.abbr,
    required this.totalSupply,
    required this.precision,
    required this.description,
    required this.url,
    required this.id,
  });

  factory TronIssueTRC10Token.fromJson(Map<String, dynamic> json) {
    return TronIssueTRC10Token(
      ownerAddress: TronAddress(json['owner_address']),
      name: StringUtils.decode(BytesUtils.fromHexString(json['name'])),
      abbr: StringUtils.tryDecode(BytesUtils.tryFromHexString(json['abbr'])),
      totalSupply: BigintUtils.tryParse(json['total_supply']),
      precision: json['precision'],
      description: StringUtils.tryDecode(
          BytesUtils.tryFromHexString(json['description'])),
      url: StringUtils.tryDecode(BytesUtils.tryFromHexString(json['url'])),
      id: json['id'],
    );
  }

  @override
  String toString() {
    return 'Token{'
        'ownerAddress: $ownerAddress, '
        'name: $name, '
        'abbr: $abbr, '
        'totalSupply: $totalSupply, '
        'precision: $precision, '
        'description: $description, '
        'url: $url, '
        'id: $id}';
  }
}
