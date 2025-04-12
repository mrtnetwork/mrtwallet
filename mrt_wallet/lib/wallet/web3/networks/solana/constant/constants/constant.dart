class Web3SolanaConst {
  static const String sendTransaction = "solana_signAndSendTransaction";
  static const String signAndSendAllTransactions =
      "solana_signAndSendAllTransactions";
  static const String signMessage = "solana_signMessage";
  static const String signTransaction = "solana_signTransaction";
  static const String requestAccounts = "solana_requestAccounts";
  static const String signIn = "solana_signIn";

  static const int requestAccountTag = 100;
  static const int signTransactionTag = 101;
  static const int signMessageV2Tag = 102;
  static const int signAndSendAllTransactionsTag = 103;
  static const int sendTransactionTag = 104;
  static const int sendAllTransactionsTag = 105;
  static const int signInTag = 106;

  static const List<int> sendTransactionDataTag = [1, 2];
  static const List<int> sendTransactionDataConfigTag = [1, 3];
}
