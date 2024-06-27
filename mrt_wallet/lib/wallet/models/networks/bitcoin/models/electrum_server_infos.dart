class ElectrumServerInfos {
  ElectrumServerInfos(
      {required this.banner, required this.features, required this.header});
  final String banner;
  final dynamic features;
  final Map<String, dynamic> header;
  bool get hasValidFeature => features is Map;

  late final String? genesisHash =
      hasValidFeature ? features["genesis_hash"] : null;

  @override
  String toString() {
    return "ElectrumServerInfos{banner: $banner, features: $features, header: $header}";
  }
}
