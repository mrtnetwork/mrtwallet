class XRPIssueToken {
  final String issuer;
  final String symbol;
  final String balance;
  XRPIssueToken.fromJson(Map<String, dynamic> json)
      : issuer = json["issuer"],
        balance = json["value"],
        symbol = json["currency"];
  @override
  String toString() {
    return "{name: $symbol, issuer: $issuer, balance: $balance}";
  }
}
