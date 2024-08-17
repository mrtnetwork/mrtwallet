enum JSLanguage { english }

class Web3Localization {
  static const JSLanguage _language = JSLanguage.english;

  static Map<String, String> get localization => _localization[_language]!;

  static const Map<JSLanguage, Map<String, String>> _localization = {
    JSLanguage.english: {
      "evm_decimals_validator":
          "The decimals for the EVM networks must be set to 18.",
      "rpc_url_validator": "There must be at least one valid RPC URL.",
      "chain_name_symbol_validator":
          "The currency name and symbol length must be between 3 and 15 characters.",
      "eth_gas_argruments_validator":
          "You cannot use both legacy and EIP-1559 gas parameters simultaneously.",
      "eth_gas_argruments_validator2":
          "To use EIP-1559 gas metrics, you must fill both maxFeePerGas and maxPriorityFeePerGas fields.",
      "method_not_found": "Method not found.",
      "unsuported_network": "Unsuported Network.",
      "invalid_request": "Invalid request",
      "permission_does_not_exist": "Permission denied for this request.",
      "internal_request_error_desc":
          "This error is related to an internal wallet process. Please submit the issue on GitHub, including the full exception message.",
      "unsuported_network_request":
          "MRT Wallet does not support Web3 for the current network requested.",
      "invalid_request_url": "Invalid target URL in the request.",
      "wallet_is_unavailable":
          "Wallet service is currently unavailable. Please try again later.",
      "request_rejected": "Request rejected by user.",
      "request_permission_error": "Request lacks the necessary permissions.",
      "internal_error":
          "An internal error occurred in the wallet. Please try again later.",
      "website_disabled":
          "The wallet feature has been disabled on this website by the wallet owner.",
      "mrt_wallet_is_now_active": "MRT Wallet is now active.",
      "invalid_transaction_type": "Invalid Transaction type.",
      "eth_invalid_transaction_type_with_gas":
          "The provided transaction type does not correspond with the specified gas parameters.",
      "eth_eip1559_not_supported":
          "The current network does not support EIP-1559 transactions."
    }
  };
}

extension JSTransaction on String {
  String get jsTr => Web3Localization.localization[this] ?? this;
}
