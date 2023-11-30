class AppPath {
  AppPath.fromJson(Map<String, dynamic> json)
      : document = json["document"],
        cache = json["cache"],
        support = json["support"];
  final String document;
  final String cache;
  final String support;

  @override
  String toString() {
    return "document: $document \ncache: $cache \nsupport: $support";
  }
}
