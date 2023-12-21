class ExportedPublicKey {
  const ExportedPublicKey(
      {required this.extendedKey, required this.comprossed, this.uncomprossed});
  final String extendedKey;
  final String comprossed;
  final String? uncomprossed;
}
