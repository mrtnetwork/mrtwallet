import 'package:blockchain_utils/helper/extensions/extensions.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

class SubstrateBlockWithEra {
  final String block;
  final List<int> blockHashBytes;
  final MortalEra era;
  SubstrateBlockWithEra(
      {required this.block,
      required this.era,
      required List<int> blockHashBytes})
      : blockHashBytes = blockHashBytes.asImmutableBytes;

  String get eraIndex => "Mortal${era.index}";
  int get eraValue => era.era;
}
