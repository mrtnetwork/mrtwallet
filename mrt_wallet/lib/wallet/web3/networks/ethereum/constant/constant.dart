class Web3EthereumConst {
  /// methods tags
  static const int sendTransactionTag = 0;
  static const int personalSignTag = 1;
  static const int typedDataTag = 2;
  static const int addChainTag = 3;
  static const int switchEthereumChainTag = 4;
  static const int requestAccountTag = 5;
  static const int disconnectTag = 6;
  static const int ethAccountsTag = 7;
  static const int ethChainIdTag = 8;

  /// method name
  static const String sendTransaction = "eth_sendTransaction";
  static const String personalSign = "personal_sign";
  static const String typedData = "eth_signTypedData";
  static const String typedDataV3 = "eth_signTypedData_v3";
  static const String typedDataV4 = "eth_signTypedData_v4";
  static const String requestAccounts = "eth_requestAccounts";
  static const String ethAccounts = "eth_accounts";
  static const String ethChinId = "eth_chainId";
  static const String addChain = "wallet_addEthereumChain";
  static const String switchEthereumChain = "wallet_switchEthereumChain";
  static const String disconnect = "wallet_switchEthereumChain";

  static const List<String> ethereumSupportedRpcPorotocols = [
    "http",
    "https",
    "wss",
    "ws"
  ];
}
