class Localization {
  static Map<String, dynamic> get languages => {
        "en": {
          "wellcome": "Welcome To MRT Wallet",
          "setup": "Setup wallet",
          "use_mnemonic": "Use Existing Mnemonic",
          "generate_mnemonic": "Generate New Mnemonic",
          "enter_mne": "Enter mnemonic",
          "enter_mnemonic": "Safely Enter Your BIP39 Mnemonic",
          "enter_mnemonic_desc":
              "Securely enter your BIP39 mnemonic to access and manage your cryptocurrency funds. Utilize the BIP39 standard to conveniently restore wallets across multiple platforms. Keep your mnemonic phrase confidential and ensure a smooth and reliable experience for managing your digital assets.",
          "enter_mnemonic_desc2":
              "Please enter your 12, 15, 18, 21, or 24-word BIP39 mnemonic phrase below.",
          "enter_mnemonic_validator":
              "Please enter a valid 12, 15, 18, 21, or 24-word BIP39 mnemonic phrase with space.",
          "e_mnemonic":
              "Enter your 12-24 word recovery phrase (mnemonic) to import your wallet",
          "enter_passphrase_desc":
              "If you have used a mnemonic passphrase to create the master key, use the following option to enter the passphrase",
          "g_mnemonic":
              "Generate a new 12-24 word recovery phrase (mnemonic) to create a new wallet",
          "g_mnemonic_desc":
              "Create a unique mnemonic to remember important information easily.",
          "invalid_mnemonic_ordering":
              "The entered mnemonic order is incorrect",
          "n_of_mnemonic_words": "Number of mnemonic words",
          "count_words": "___1__ Words",
          "generate": "Generate",
          "setup_password": "Setup password",
          "p_note": "Please Note:",
          "continue": "Continue",
          "p_note1":
              "Your wallet password is not stored anywhere and cannot be recovered if forgotten.",
          "p_note2":
              "Your mnemonic phrase is the only way to recover your wallet. Do not forget it!",
          "p_note3":
              "Keep your wallet password and mnemonic phrase in a safe place and never share them with anyone.",
          "p_note4":
              "If you lose your wallet password and mnemonic, you may permanently lose access to your funds.",
          "e_password": "Enter password",
          "c_password": "Confirm password",
          "password_desc":
              "Password should be at least 8 characters long and include a combination of letters, numbers, and special characters",
          "weak_password":
              "Password is not strong. Make sure it contains uppercase, lowercase, special character, and numbers.",
          "p_does_not_match": "Password does not match",
          "show_mnemonic_desc":
              "Please treat your mnemonic phrase with the utmost care and confidentiality. Do not share it with anyone, and ensure it remains hidden from prying eyes. Your mnemonic is the key to accessing your funds and should be kept secure at all times. Any unauthorized access may result in the loss of your assets.",
          "r_generate": "Re-generate",
          "v_mnemonic": "Verify mnemonic",
          "v_mnemonic_desc":
              "Please verify your mnemonic phrase to ensure its accuracy. Carefully enter your mnemonic words in the correct order to confirm your access to your account. This step is crucial for securing your wallet and funds.",
          "Language": "Language",
          "select_the_mnemonic": "Select the mnemonic",
          "select_mnemonic_desc":
              "Please click on the desired mnemonic in the order you viewed the mnemonic on the previous page.",
          "reset": "Reset",
          "passphrase": "Passphrase",
          "extra_opetion_desc":
              "Your security is our top priority. We do not store your passphrase. For added protection, we provide an export option that allows you to view and securely store your mnemonic phrase. Your cryptographic assets remain in your control, and by choosing to export only the mnemonic, you retain exclusive access to your account. Rest assured, your privacy and security are paramount.",
          "mn_password": "BIP39 passphrase",
          "mn_password_desc":
              "BIP39, also known as Hierarchical Deterministic Wallets, allows for the generation of a tree of keys from a single master seed. Adding a passphrase to this process creates an extra layer of security, known as a BIP32 passphrase.",
          "enable_mnemonic_password": "Enable BIP39 passphrase",
          "password_should_not_be_empty": "Password should not be empty",
          "wallet_data_is_invalid": "The wallet data is invalid",
          "incorrect_password": "Incorrect password",
          "invalid_mnemonic": "Invalid mnemonic",
          "invalid_account_details": "Invalid account details",
          "invalid_passphrase": "invalid mnemonic passphrase.",
          "close": "Close",
          "launch_the_wallet": "Launching the wallet",
          "wallet_login": "Wallet Login",
          "wallet_login_desc":
              "Welcome to the secure login portal for your cryptocurrency wallet. Please enter your credentials below to access your digital assets",
          "password": "Password",
          "unlock": "Unlock",
          "derive_bitcoin_address": "Deriving Bitcoin Addresses",
          "generate_from_hd_wallet":
              "Generating an address based on your HD wallet seed.",
          "generate_from_imported_keys":
              "Generating an address based on your imported keys",
          "generate_from_imported_key_desc1":
              "In address creation mode with imported private keys, the address is generated using the associated public key of the selected private key.",
          "choose_public_key": "Choose a public key.",
          "select_derivation_type": "Select derivation type",
          "derivation_type": "Derivation type",
          "select_imported_key_desc":
              "Kindly choose the public key associated with the imported private key to generate the address.",
          "select_derivation_desc":
              "Select the method for generating the address: either based on entered private keys or using your HD wallet seed.",
          "bip44_desc":
              "BIP44: Standard for multi-account wallets with P2PKH addresses, facilitating structured and efficient transaction management.",
          "bip49_desc":
              "BIP49: Extension of BIP44, enhancing security with P2SH nested SegWit addresses, addressing transaction malleability.",
          "bip84_desc":
              "BIP84: Introduces native SegWit (bech32) for more efficient fund storage, reducing fees and improving processing.",
          "bip86_desc":
              "BIP86: Proposes SegWit Version 1 P2TR, advancing Bitcoin's features, security, and scalability in line with community efforts.",
          "setup_bitcoin_address": "Setup bitcoin address",
          "setup_bitcoin_address_desc":
              "You have not set up any Bitcoin account. To begin setup, please click on the 'Setup Address' button.",
          "setup_address": "Setup Address",
          "choose_bitcoin_address_type": "Choose Address Type",
          "choose_bitcoin_address_type_desc":
              "Please select a Bitcoin address type to create an address.",
          "bitcoin_type_recomended":
              "We recommend creating a P2TR or P2WPKH address due to their enhanced security features and lower cost fees.",
          "standard_derivation": "Standard Derivation",
          "standard_deravation_for": "Derivation Standard for ___1__",
          "p2sh_nested_segwit": "P2SH Nested SegWit",
          "p2sh_nested_segwit_desc":
              "Enhancing Security and Transaction Handling with P2SH Nested SegWit Addresses",
          "p_level": "Purpose level",
          "c_level": "Coin level",
          "a_level": "Account level",
          "change_level": "Change level",
          "address_index": "Address index",
          "key_derivation": "Key derivation",
          "bip32_key_derivation": "BIP32 key derivation",
          "bip32_derivation_desc":
              "BIP32 levels (purpose, coin, account, change, address index) provide a hierarchical structure for generating cryptocurrency addresses, enabling deterministic wallet creation with specific attributes for organizational and security purposes.",
          "bip32_derivation_desc2":
              "When deriving key indexes, it's essential to securely record and store them. Forgetting to do so could result in potential financial losses. Always ensure that your derived key indexes are safely preserved to avoid any risks of losing access to your funds.",
          "bip32_derivation_desc3":
              "For BIP32, the indices for hardened keys should start at 2^31 and go up to 2^32 - 1. For example, If you intend to derive a hardened key with an index of 84 in BIP32, you should use the index 2^31 + 84, which equates to 2147483732.",
          "choose_index_each_level": "Choose an index for each level.",
          "bip32_level_desc":
              "BIP32 level (purpose, coin, account, change, address index) represents the hierarchical structure used in the BIP32 standard for deriving keys.",
          "bip32_key_index_validate":
              "The key index should not be negative and should be less than 2^32 - 1.",
          "hardened": "Hardened",
          "hardened_index": "Hardened key with an index of ___1__.",
          "path": "Path",
          "setup_derivation_path": "Setup Derivation path",
          "generate_address": "Generate address",
          "invalid_argruments":
              "Invalid arguments expected ___1__ but got ___2__",
          "invalid_coin": "Invalid coin",
          "to_many_accounts":
              "Too many accounts, please use custom path derivation",
          "incorrect_network": "Incorrect network",
          "invalid_bip_key_index": "invalid bip proposal derivation index",
          "address_already_exist": "Address already exist",
          "generating_new_addr": "Generating new address",
          "copied_to_clipboard": "Copied to clipboard.",
          "selected": "Selected",
          "switch_account": "Switch account",
          "new_address": "New Address",
          "request_error": "The request encountered an error",
          "invalid_request_type":
              "Invalid type, request result can be string, list, or map",
          "build_transacation": "Build transaction",
          "create_and_send_bitcoin_transaction":
              "Create and send Bitcoin transactions",
          "please_selected_acc_spend":
              "Please select the Bitcoin accounts you want to spend.",
          "export_mnemonic": "Export mnemonic",
          "export_mnemonic_desc":
              "Export your mnemonic for secure backup and recovery",
          "export_mnemonic_desc2":
              "Safeguard your cryptographic assets by securely storing your mnemonic. Use a trusted hardware wallet, secure offline storage, or a reputable password manager to ensure the protection of your valuable information. Remember, the safety of your assets starts with the responsible management of your mnemonic and passphrase.",
          "export": "Export",
          "more_security": "More security",
          "mnemonic_security_des1":
              "Make sure nobody can access or view your mnemonic, as it serves as a critical key to your account.",
          "mnemonic_security_des2":
              "Refrain from using the copy icon, as there is a risk of mnemonic leakage through apps that may monitor the copy function.",
          "mnemonic_security_des3":
              "Do not take pictures of your mnemonic, as storing it in image format is not a safe practice and can compromise its security.",
          "show_mnemonic": "Show mnemonic",
          "backup_mnemonic": "Backup mnemonic",
          "b_using_web3_secret_defination":
              "Backup using the Web3 Secret Storage Definition.",
          "about_web3_secret_defination":
              "You can learn more about saving with Web3 Secret Storage Definition version 3 by following this",
          "end_link": "link.",
          "about_web3_defination_desc1":
              "At present, only your mnemonic is stored in the Web3 storage definition.",
          "about_web3_defination_desc4":
              "At present, only your current account private key is stored in the Web3 storage definition.",
          "encoding": "Encoding type",
          "encoding_desc":
              "This encoding can only be decoded by this application and is not compatible with other supported Web3 storage definitions.",
          "create_backup": "Create a backup",
          "creating_backup_desc":
              "Creating a backup, this process may take a few seconds",
          "backup_desc1":
              "Kindly save the backup text in a text file and securely store it.",
          "backup_desc2":
              "Only with the current wallet password can the backup be decrypted. In case of forgetting the password, there is no possibility of opening the file.",
          "restore_backup": "Restore backup",
          "restore_backuo_desc":
              "Recover the mnemonic using the backup stored in the Web3 definition storage",
          "restore_mnemonic_from_bcakup":
              "Recover the mnemonic from the backup.",
          "restore_mnemonic_desc":
              "Kindly paste the encrypted text of your Web3 secret definition below.",
          "enter_backup": "Input backup text.",
          "bcakup_validator":
              "The backup text should exceed 100 characters in length.",
          "input_backup_password": "Input backup password.",
          "backup_password_validator": "Backup password should not be empty.",
          "clipboard_empty": "Clipboard is empty.",
          "decoding_type": "Decoding type",
          "invalid_bitcoin_address_type": "Invalid BIP49 address type.",
          "p2wshInP2sh": "P2WSH nested in P2SH",
          "p2wpkhInP2sh": "P2WPKH nested in P2SH",
          "p2pkhInP2sh": "P2PKH Inside P2SH",
          "p2pkInP2sh": "P2PK Inside P2SH",
          "get_unspent_transaction": "Get Unspent Transactions",
          "retrieving_transaction": "Retrieving Transactions - Please Wait",
          "transaction_successfully_received":
              "Transaction outputs successfully received.",
          "problem_when_receiving_utxos":
              "Problem receiving Utxos for certain accounts.",
          "utxo_receiving_err":
              "There is a problem receiving unspent transactions. Please try again.",
          "build_transaction": "Build transaction",
          "select_output_addresses":
              "Select the addresses for transaction outputs.",
          "recipients": "Recipients",
          "tap_to_select": "Tap to select",
          "bitcoin_address": "Bitcoin address",
          "receiver_address": "Receiver address",
          "receiver_address_desc":
              "Input the recipient's address in the field below.",
          "address_recipient_funds": "Address of recipient of funds",
          "address": "Address",
          "invalid_network_address":
              "The provided address is not valid for this network.",
          "list_of_recipients": "List of recipients",
          "setup_recipients": "Setup recipients",
          "processing_fee_please_wait":
              "Processing transaction fee, kindly await for completion.",
          "input_for_each_entery": "Input the preferred amount for each entry.",
          "build_transaction_desc1":
              "If the total of the entered amounts, along with the transaction fee, is less than the sum of unspent transactions, the remaining amount will be transferred to the designated address in the 'change' field.",
          "transaction_fee": "Transaction fee",
          "replace_by_fee": "Replace by fee",
          "decimal_int_validator":
              "Please enter the amount as a decimal or an integer",
          "price_less_than": "The value must be less than ___1__",
          "price_greather_than": "The amount must be greater than ___1__",
          "amount_of_output": "Amount of output",
          "receiver": "Receiver",
          "setup_output_amount": "Setup output amount",
          "the_remaining_amount": "The remaining amount",
          "amount": "Amount",
          "bitcoin_transaction_fee": "Bitcoin transaction fee",
          "transacation_fee_desc":
              "Select one of the following rates for transaction fees",
          "transaction_fee_desc2":
              "You may input a custom transaction fee by selecting the 'Custom' option.",
          "transaction_fee_desc3":
              "Kindly be aware that exceeding or falling below the specified transaction fee limit is non-refundable.",
          "setup_custom_fee": "Setup custom fee",
          "transaction_fee_desc4":
              "Kindly input the preferred amount for the transaction fee.",
          "custom_fee": "Custom fee",
          "setup_transaction_fee": "Setup transaction fee",
          "account_not_found": "Account not found",
          "sign_transaction": "Sign transaction",
          "signing_tx_desc":
              "The wallet requests the signing of the transaction using the following accounts.",
          "signing_tx_desc1":
              "Kindly provide your wallet password to sign the transaction; otherwise, close the page.",
          "wallet_is_locked": "Wallet is locked.",
          "to_many_request": "Too many requests",
          "user_rejected_signing_request":
              "The transaction signing request has been declined.",
          "incorrect_wallet_status":
              "The wallet is currently unprepared for this operation.",
          "select_account": "Select account",
          "send_transaction": "Send transaction",
          "transaction_Insufficient_balance":
              "Insufficient balance to finalize the transaction. Prior to proceeding, please review the transaction outputs for accuracy.",
          "create_send_transaction":
              "Creating and sending Bitcoin transaction. Kindly await completion.",
          "bitcoin_multi_sig_addr": "Bitcoin multi-signature address",
          "establishing_bitcoin_multi_sig_addr":
              "Establishing a Bitcoin multi-signature address.",
          "multi_sig_desc":
              "This feature is specifically crafted to enhance the security of your funds. It involves creating an account with the public keys of multiple chosen accounts. This address serves as an added layer of security, ensuring that even if one of your private keys is compromised, your funds remain both accessible and secure.",
          "mutli_sig_desc2":
              "To sign unspent transactions for this address, it requires all the corresponding private keys associated with the public keys used in its creation",
          "multi_sig_desc3":
              "The transaction fee for this address increases by 10% with the inclusion of each additional public key.",
          "multi_sig_desc4":
              "The loss of private keys associated with added addresses will lead to a loss of funds.",
          "list_of_public_keys": "List of Public Keys",
          "multi_sig_desc5":
              "By selecting the 'add' option from your accounts, you can obtain the public key of the chosen account to create the address.",
          "public_key_already_exist": "Public key already exist",
          "threshold_configuration": "Threshold configuration",
          "threshhold_desc":
              "Specify the transaction signature threshold. This threshold indicates the number of signatures required to confirm the transaction. For example, setting it to 5 means that the transaction requires 5 signatures. Maximum 16 thresholds",
          "threshold": "Threshold",
          "signers_weight_configuration": "Configuration for Signers' Weight",
          "signer_wight_desc1":
              "The weight assigned to each signer dictates their influence in signing the transaction. For example, with a transaction threshold set at 3, if you have address A with a weight of 2, address B with a weight of 1, and address C with a weight of 3, you would need the signatures of either addresses A and B or address C to confirm the transaction.",
          "weight": "Weight",
          "threshhold_desc2":
              "The signer's weight must not surpass the specified threshold.",
          "threshhold_desc3":
              "The cumulative weight of the signatories must meet the specified threshold.",
          "review_address": "Review address",
          "review_address_desc":
              "Please ensure that important and critical information about the multi-signature account, including the public key and order used, the weight assigned to the added public key, as well as the script details, is in a safe and accessible place. This is vital to protect your funds.",
          "public_keys_and_weight_of_each":
              "Public keys and their respective weights",
          "publick_key": "Public key",
          "multi_sig_script": "Multi-signature script",
          "address_script": "Address script",
          "type_of_address": "Type of address",
          "backup_as_text": "Backup as text",
          "address_details_copied":
              "The address details have been copied to the clipboard.",
          "address_details2": "Details for a Multi-Signature Address.",
          "address_backup_desc1":
              "Kindly preserve the following text in a secure location to ensure you have the essential information for recreating the address when needed",
          "address_details": "Address details",
          "address_added_to_accounts":
              "The address has been successfully added to your Bitcoin accounts.",
          "unavailable_multi_sig_public_key":
              "The public key is unavailable for this multi-signature address.",
          "switch_network": "Switch network",
          "erase_wallet": "Erase wallet",
          "security": "Security",
          "multi_signature": "Multi-signature",
          "export_private_key": "Export private key",
          "export_public_key": "Export public key",
          "remove_account": "Remove account",
          "backup_private_key": "Backup private key",
          "export_public_key_desc1": "Exporting Public Keys Using BIP",
          "comperessed_public_key": "Compressed public key",
          "uncomperessed_public_key": "Uncompressed public key",
          "extended_public_key": "Extended public key",
          "private_key_is_not_available": "The private key is not available",
          "export_private_key_desc":
              "Remember, the security of your private key is crucial for safeguarding your digital assets. Take these precautions seriously to minimize the risk of unauthorized access and potential loss of funds.",
          "private_key": "Private key",
          "extended_private_key": "Extended private key",
          "show_private_key": "Show private key",
          "unable_to_accsess_private_key":
              "Unable to access the private key for this account.",
          "remove_account_desc":
              "Remove the account from the network accounts list.",
          "remove_accounts_desc1":
              "Prior to account deletion, kindly ensure you have securely backed up the private key associated with this account.",
          "enter_wallet_password_to_continue":
              "Please enter your wallet password to continue.",
          "wallet_password": "Wallet password",
          "backup_private_key_desc":
              "To generate a backup, kindly proceed to the 'Extract Private Key' page.",
          "remove_account_pls_wait": "Removing account—please wait.",
          "account_deleted": "Account successfully deleted.",
          "import_account": "Account Import",
          "import_account_desc1":
              "The new account should align with the app's coin and network settings.",
          "import_account_desc2":
              "Please enter your private key, extended key, or Wallet Import Format (WIF) to proceed.",
          "private_key_invalid": "The provided private key is not valid.",
          "import_accounts_desc3": "Indicate the type of your private key",
          "imported": "Imported",
          "importing_key_pls_wait": "Importing key—please wait.",
          "address_imported_desc1":
              "Key successfully imported. Please proceed to the 'New Address' option in the address menu to create a new address.",
          "hd_wallet": "HD Wallet",
          "imported_key": "Imported key",
          "empty_custom_key_desc":
              "You haven't added any foreign private key to your wallet. Please enter a new private key from the settings before proceeding",
          "not_support_multisig_derivation":
              "Derivation from a multisig address is not supported.",
          "p2wsh_one_of_one_desc":
              "Generated from a standard P2WSH one-of-one multisig script",
          "non_derivation": "Non-derivation",
          "import_key_derivation_desc2":
              "The address is created without derivation.",
          "imported_at": "Imported at ___1__",
          "address_added_success":
              "The address has been successfully added to the wallet",
          "generate_new_address": "Generate new address",
          "spendable_amount": "Spendable amount",
          "utxos": "Unspent transactions",
          "choose_utxos_each_account":
              "Kindly choose the unspent transactions associated with each account you intend to utilize.",
          "public_key_signatories": "The public keys of the signatories.",
          "attempt_again": "Attempt once more",
          "lacks_an_utxos": "It lacks an unspent transaction.",
          "choose_all": "Choose all.",
          "setup_memo": "Setup memo",
          "tap_to_add_memo": "Tap to add a memo.",
          "character_length_min_validator":
              "The character count must exceed ___1__ letters.",
          "character_length_max_validator":
              "The character count must be fewer than ___1__ letters.",
          "transaction_memo": "Transaction mome",
          "memo_desc1":
              "The transaction fee escalates based on the volume of entered text.",
          "memo_desc2":
              "If you initiate the momo, the program will record even an empty message. If you don't require a note, please close the page.",
          "memo": "Memo",
          "address_sharing": "Address sharing",
          "share_barcode": "Share barcode",
          "share_as_file": "Share as file",
          "image_store_alert_keys":
              "storing it in image format is not a safe practice and can compromise its security.",
          "file_verification_fail":
              "We couldn't verify the file's integrity. It may be corrupted or tampered with. please try again",
          "share_mnemonic": "Share mnemonic",
          "show_barcode": "Show barcode",
          "change_password": "Change password",
          "wallet_password_desc":
              "Strengthen your wallet's security with a password update.",
          "change_password_desc":
              "If you've utilized the program's backup feature, the new password won't unlock previous backups. Ensure you create a new backup or remember the current backup password to maintain access.",
          "password_changed": "Wallet password successfully updated.",
          "changing_password": "Password update in progress. Please wait.",
          "enter_new_password": "New Password",
          "delete_wallet": "Delete Wallet",
          "delete_wallet_desc":
              "Deleting the wallet will irreversibly erase all associated data. To regain access, you'll need either the mnemonic or the account's private key. Make certain you have a secure backup in place before initiating this irreversible process.",
          "delete_wallet_confirmation": "Wallet Deletion Confirmation",
          "deleting_wallet": "Deleting wallet. Please wait.",
          "wallet_deleted_success": "Wallet Deleted Successfully",
          "export_security_phrase": "Export and backup Security Phrase",
          "wallet_preferences": "Wallet Preferences",
          "clear_wallet_data": "Clear Wallet Data",
          "never": "Never",
          "one_minute": "one Minute",
          "two_minute": "two Minute",
          "five_minute": "five Minute",
          "switching_account": "Switching account",
          "switching_network": "Switching network",
          "unlocking_wallet": "Unlocking wallet",
          "automatic_loc": "Automatic lock",
          "customize_wallet_settings": "Customize Wallet Settings",
          "update_settings_desc":
              "Kindly utilize the 'Update' option to apply changes to the settings after each edit.",
          "update_settings": "Update setting",
          "updating": "Updating",
          "setting_update_successfully": "Settings updated successfully",
          "import_private_key": "Import private key",
          "view_on_explorer": "View on Explorer",
          "view_address_on_explorer": "View Address on Explorer",
          "lock": "Lock wallet",
          "dark_mode": "Dark mode",
          "primary_color_palette": "Primary Color Palette",
          "select_color_from_blow":
              "Select the primary color for the program from the following options:",
          "color_changed": "The primary color has been successfully modified.",
          "update_balances": "Update balances",
          "somthing_wrong": "Somthing wrong",
          "wallet_in_progress_wait":
              "The wallet is in processing, please await completion.",
          "request_cancelled": "The request was cancelled",
          "invalid_request": "Invalid request",
          "settings": "Settings",
          "switch_address": "Switch address",
          "mrt_wallet": "MRT WALLET",
          "fully_open_source": "Fully Open Source Wallet",
          "about_mrt_wallet": "About MRT Wallet",
          "api_provider_service": "API Provider Service",
          "active": "Active",
          "last_request_error": "The most recent request encountered an error",
          "reached_limit_error":
              "You have reached the limit for free requests. Please wait.",
          "bitcoin_api_provider_service": "Bitcoin service provider",
          "what_is_api_provider":
              "A Blockchain API provider service, offers developers a comprehensive interface for interacting with the blockchain. It facilitates functions such as reading UTXOs, checking balances, and sending transactions, providing seamless integration for applications requiring real-time access to blockchain network data and transaction management.",
          "what_is_service_provider": "What is a blockchain service provider?",
          "select_provider": "Select provider",
          "choose_provider": "Choose a provider.",
          "select_provider_desc": "Select a provider from the options below",
          "backup_wallet": "Create a wallet backup.",
          "backup_wallet_desc":
              "Safeguard your crypto assets by securely storing essential elements such as mnemonic phrases, imported private keys, addresses, and more through a reliable web3 definition storage solution. This ensures a protected backup mechanism for your wallet's crucial information.",
          "backup": "Backup",
          "backup_wallet_desc1":
              "This backup can only be decrypted using this application.",
          "invalid_wallet_backup": "Invalid wallet backup.",
          "mnemonic_backup": "Mnemonic backup",
          "wallet_backup": "Wallet backup",
          "select_backup_option": "Select your backup option."
        }
      };
}
