class XRPNFToken {
  final String nftokenId;
  final int flags;
  final String issuer;
  final String? uri;
  final int serial;
  final int nftokenTaxon;
  XRPNFToken.fromJson(Map<String, dynamic> json)
      : flags = json["Flags"],
        nftokenId = json["NFTokenID"],
        issuer = json["Issuer"],
        nftokenTaxon = json["NFTokenTaxon"],
        serial = json["nft_serial"],
        uri = json["URI"];
}
