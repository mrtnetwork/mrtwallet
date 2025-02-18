class Web3SuiConst {
  static const String signAndExecuteTransaction =
      "sui_signAndExecuteTransaction";
  static const String signTransaction = "sui_signTransaction";
  static const String signAndExecuteTransactionBlock =
      "sui_signAndExecuteTransactionBlock";
  static const String signTransactionBlock = "sui_signTransactionBlock";
  static const String signMessage = "sui_signMessage";
  static const String signPersonalMessage = "sui_signPersonalMessage";

  static const String requestAccounts = "sui_requestAccounts";
  static const String getNetwork = "sui_network";
  static const String switchNetwork = "wallet_switchSuiChain";
  static const int requestAccountTag = 100;
  static const int signTransactionTag = 101;
  static const int signAndExecuteTransactionTag = 103;
  static const int signMessagTag = 102;
  static const int signPersonalMessagTag = 108;

  static const int signTransactionBlockTag = 104;
  static const int signAndExecuteTransactionBlockTag = 105;
  static const int getNetworkTag = 106;
  static const int changeNetworkTag = 107;
}
