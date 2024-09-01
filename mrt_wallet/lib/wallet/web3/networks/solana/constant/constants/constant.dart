class Web3SolanaConst {
  static const int requestAccountTag = 100;
  static const String requestAccounts = "solana_requestAccounts";

  static const int signTransactionTag = 101;
  static const String signTransaction = "solana_signTransaction";

  static const int signMessageV2Tag = 102;
  static const String signMessage = "solana_signMessage";

  static const List<int> sendTransactionDataTag = [1, 2];
  static const List<int> sendTransactionDataConfigTag = [1, 3];
}
