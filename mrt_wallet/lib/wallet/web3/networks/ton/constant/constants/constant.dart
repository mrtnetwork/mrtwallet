class Web3TonConst {
  static const int requestAccountTag = 100;

  static const int signTransactionTag = 101;

  static const int signMessageV2Tag = 102;
  static const String signMessage = "ton_signMessage";
  static const String sendTransaction = "ton_sendTransaction";
  static const String signTransaction = "ton_signTransaction";
  static const String requestAccounts = "ton_requestAccounts";
  static const String addressName = "Ton address";

  static const int sendTransactionTag = 103;

  static const List<int> sendTransactionMessagesTag = [3, 1];
}
