class AccountObjectSignerEntry {
  final String account;
  final int signerWeight;

  const AccountObjectSignerEntry(
      {required this.account, required this.signerWeight});

  factory AccountObjectSignerEntry.fromJson(Map<String, dynamic> json) {
    return AccountObjectSignerEntry(
      account: json['Account'],
      signerWeight: json['SignerWeight'],
    );
  }
}

class XRPAccountObjectEntry {
  final int flags;
  final String ledgerEntryType;
  final String ownerNode;
  final String previousTxnID;
  final int previousTxnLgrSeq;
  final List<AccountObjectSignerEntry> signerEntries;
  final int signerListID;
  final int signerQuorum;
  final String index;

  XRPAccountObjectEntry({
    required this.flags,
    required this.ledgerEntryType,
    required this.ownerNode,
    required this.previousTxnID,
    required this.previousTxnLgrSeq,
    required this.signerEntries,
    required this.signerListID,
    required this.signerQuorum,
    required this.index,
  });

  factory XRPAccountObjectEntry.fromJson(Map<String, dynamic> json) {
    return XRPAccountObjectEntry(
      flags: json['Flags'],
      ledgerEntryType: json['LedgerEntryType'],
      ownerNode: json['OwnerNode'],
      previousTxnID: json['PreviousTxnID'],
      previousTxnLgrSeq: json['PreviousTxnLgrSeq'],
      signerEntries: List<AccountObjectSignerEntry>.from(json['SignerEntries']
          .map((x) => AccountObjectSignerEntry.fromJson(x['SignerEntry']))),
      signerListID: json['SignerListID'],
      signerQuorum: json['SignerQuorum'],
      index: json['index'],
    );
  }
}
