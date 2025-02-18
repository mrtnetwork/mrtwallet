class Localization {
  static Map<String, Map<String, String>> get languages => {
        "en": {
          "wellcome": "Welcome To MRT Wallet",
          "setup": "Setup wallet",
          "use_mnemonic": "Use Existing Mnemonic",
          "generate_mnemonic": "Generate New Mnemonic",
          "enter_mne": "Enter mnemonic",
          "enter_mnemonic": "Safely Enter Your Mnemonic",
          "enter_mnemonic_desc":
              "Securely enter your BIP39 mnemonic to access and manage your cryptocurrency funds. Utilize the BIP39 standard to conveniently restore wallets across multiple platforms. Keep your mnemonic phrase confidential and ensure a smooth and reliable experience for managing your digital assets.",
          "enter_mnemonic_desc2":
              "Please enter your 12, 15, 18, 21, or 24-word mnemonic phrase below.",
          "enter_mnemonic_validator":
              "Please enter a valid 12, 15, 18, 21, or 24-word mnemonic phrase with space.",
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
          "password_validator":
              "Password should be at least 8 characters long.",

          "weak_password":
              "Password is not strong. Make sure it contains uppercase, lowercase, special character, and numbers.",
          "password_used_before": "This password has been used before.",
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
          "invalid_serialization_data": "Invalid serialization data",
          "invalid_passphrase": "invalid mnemonic passphrase.",
          "close": "Close",
          "launch_the_wallet": "Launching the wallet",
          "wallet_login": "Wallet Login",
          "wallet_login_desc":
              "Welcome to the secure login portal for your cryptocurrency wallet. Please enter your credentials below to access your digital assets",
          "password": "Password",
          "unlock": "Unlock",
          "derive_network_address": "Deriving ___1__ Addresses",
          "generate_from_hd_wallet":
              "Creating an address from your HD wallet seed or imported keys.",
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
          "setup_network_address": "Setup ___1__ address",
          "setup_network_address_desc":
              "You have not set up any ___1__ account. To begin setup, please click on the 'Setup Address' button.",
          "setup_address": "Setup Address",
          "setup_addresses": "Setup Addresses",
          "choose_bitcoin_address_type": "Choose Address Type",
          "choose_bitcoin_address_type_desc":
              "Please select the address type to create an address.",
          "bitcoin_type_recomended":
              "We recommend creating a ___1__ address due to their enhanced security features and lower cost fees.",
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
          "substrate_key_derivation": "Substrate key derivation",
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
          "setup_derivation": "Setup Derivation",
          "generate_address": "Generate address",
          "invalid_argruments":
              "Invalid arguments expected ___1__ but got ___2__",
          "invalid_coin": "Invalid coin",
          "to_many_accounts":
              "Too many accounts, please use custom path derivation",
          "incorrect_network": "Incorrect network",
          "invalid_provider_infomarion": "Invalid provider information.",
          "invalid_bip_key_index": "invalid bip proposal derivation index",
          "address_already_exist": "Address already exist",
          "generating_new_addr": "Generating new address",
          "copied_to_clipboard": "Copied to cliboard.",
          "copied_to_clipboard_faild": "Copy action unsuccessful.",
          "selected": "Selected",
          "switch_account": "Switch account",
          "new_address": "New Address",
          "request_error": "The request encountered an error",
          "invalid_request_type":
              "Invalid type, request result can be string, list, or map",
          "build_transacation": "Build transaction",
          "create_and_send_network_transaction":
              "Create and send ___1__ transactions",
          "please_selected_acc_spend":
              "Please select the ___1__ accounts you want to spend.",
          "spend_multiple_account_desc":
              "In a single transaction, you can spend from multiple addresses.",
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
          "b_using_web3_secret_defination": "Backup using the Web3 SSD.",
          "about_web3_secret_defination":
              "You can learn more about saving with Web3 Secret Storage Definition version 3 by following this",
          "end_link": "link.",
          "about_web3_defination_desc1":
              "At present, only your mnemonic is stored in the Web3 storage definition.",
          "about_web3_defination_desc4":
              "At present, only your current account private key is stored in the Web3 storage definition.",
          "encoding": "Encoding type",
          "mrt_backup_encoding_desc":
              "This type of backup can only be decoded by the MRT Wallet application.",
          "create_backup": "Create a backup",
          "creating_backup_desc":
              "Creating a backup, this process may take a few seconds",
          "backup_desc1":
              "Kindly save the backup text in a text file and securely store it.",
          "backup_desc2":
              "Only the current wallet password can decrypt the backup. If the password is forgotten, the file cannot be opened.",
          "restore_backup": "Restore backup",
          "restore_backuo_desc":
              "Recover the mnemonic using the backup stored in the Web3 definition storage",
          "restore_wallet_from_bcakup": "Restore wallet from backup.",
          "restore_mnemonic_desc":
              "Kindly paste the encrypted text of your mnemonic or wallet backup.",
          "enter_backup": "Input backup text.",
          "bcakup_validator":
              "The backup must be a valid bytes as hexadecimal string.",
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
          "retrieving_transaction": "Retrieving Transactions. Please Wait.",
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
          "recipient": "Recipient",
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
          "int_validator": "Please enter the amount as an integer",
          "price_less_than": "The value must be less than ___1__",
          "price_greather_than": "The amount must be greater than ___1__",
          "amount_of_output": "Amount of output",
          "receiver": "Receiver",
          "setup_output_amount": "Setup output amount",
          "amount": "Amount",
          "bitcoin_transaction_fee": "Bitcoin transaction fee",
          "transacation_fee_desc":
              "Select one of the following rates for transaction fees",
          "transaction_fee_desc2":
              "You may input a custom transaction fee by selecting the 'Custom' option.",
          "transaction_fee_desc3":
              "Kindly be aware that exceeding or falling below the specified transaction fee limit is non-refundable.",
          "setup_custom_fee": "Setup fee",
          "transaction_fee_desc4":
              "Kindly input the preferred amount for the transaction fee.",
          "custom_fee": "Custom fee",
          "setup_transaction_fee": "Setup transaction fee",
          "account_not_found": "Account not found",
          "sign_transaction": "Sign transaction",
          "signing_tx_desc":
              "The wallet is requesting you to sign the data with the following accounts.",
          "signing_tx_desc1":
              "Kindly provide your wallet password to sign the data (Transaction, Message, etc.). otherwise, close the page.",
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
              "Creating and sending ___1__ transaction. Kindly await completion.",
          "multi_sig_addr": "Multi-signature address",
          "establishing_multi_sig_addr":
              "Establishing a multi-signature address.",
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
              "Specify the transaction signature threshold. This threshold indicates the number of signatures required to confirm the transaction. For example, setting it to 5 means that the transaction requires 5 signatures.",
          "threshold": "Threshold",
          "signers_weight_configuration": "Configuration for Signers Weight",
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
          "public_key": "Public key",
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
              "The address has been successfully added to your accounts.",
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
              "Accessing the private key in this network is not feasible.",
          "remove_account_desc":
              "Remove the account from the network accounts list.",
          "remove_accounts_desc1":
              "Prior to account deletion, kindly ensure you have securely backed up the private key associated with this account.",
          "enter_wallet_password_to_continue":
              "Please enter your wallet password to continue.",
          "wallet_password": "Wallet password",
          "backup_private_key_desc":
              "To generate a backup, kindly proceed to the 'Extract Private Key' page.",
          "remove_account_pls_wait": "Removing account. please wait.",
          "account_deleted": "Account successfully deleted.",
          "import_account": "Account Import",
          "inidicate_type_of_key": "Indicate the type of your private key.",
          "import_account_desc1":
              "The new account should align with the app's coin and network settings.",
          "import_account_desc2":
              "Please enter your private key, extended key, or Wallet Import Format (WIF) to proceed.",
          "private_key_invalid": "The provided private key is not valid.",
          "extended_key_invalid": "The provided extended key is not valid.",
          "wif_key_invalid": "Invalid WIF: incorrect key or wrong coin type.",
          "key_type": "key type",
          "imported": "Imported",
          "importing_key_pls_wait": "Importing key. please wait.",
          "setup_new_account_pls_wait": "Setup new account. please wait.",
          "removing_key_pls_wait": "Removing kaypair. please wait.",
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
          "export_security_phrase": "Export and backup Seed Phrase",
          "wallet_preferences": "Wallet Preferences",
          "clear_wallet_data": "Clear Wallet Data",
          "never": "Never",
          "one_minute": "One Minute",
          "two_minute": "Two Minute",
          "five_minute": "Five Minute",
          "ten_minute": "Ten Minute",
          "thirty_minute": "Thirty Minute",
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
          "lock_wallet": "Lock wallet",
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
          "no_error_found": "No error found",
          "network_all_request_error": "All requests have encountered errors",
          "network_some_request_error": "Some requests have encountered errors",
          "reached_limit_error":
              "You have reached the limit for free requests. Please wait.",
          "service_provider": "Service provider",
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
          "invalid_wallet_backup_checksum":
              "Invalid wallet backup checksum. The passphrase may be incorrect.",
          "mnemonic_backup": "Mnemonic backup",
          "wallet_backup": "Wallet backup",
          "select_backup_option": "Select your backup option.",
          "adjust_app_brightness": "Adjust App Brightness",
          "define_primary_of_app":
              "Define the primary color scheme for the application",
          "essence_of_mrt_wallet": "Discover the Essence of MRT Wallet",
          "manage_imported_key": "Administer Imported Keys",
          "manage_key_desc1": "Delete Imported Keys from Your Wallet",
          "retrieving_imported_keys_wait":
              "Retrieving Imported Keys. Please Wait.",
          "no_imported_key_found": "No Imported Private Keys Detected",
          "manage_key_desc2":
              "If the key is removed, and an address has already been generated with the corresponding account, it will become inaccessible in the wallet.",
          "inventory_keys": "Keys Inventory",
          "remove": "Remove",
          "key_extended_for": "Key Expansion for",
          "wif_for": "WIF (Wallet Import Format) for",
          "wif": "WIF (Wallet Import Format)",
          "deleting_key": "Deleting Key. Please Wait.",
          "bitcoin_and_forked": "Bitcoins and forked",
          "ripple": "Ripple",
          "bip44_derivation_desc":
              "BIP44 is a Bitcoin Improvement Proposal that defines a hierarchical deterministic wallet structure. It outlines the methodology for deriving a tree of cryptographic key pairs from a single master key, allowing for secure and flexible key management. The key pairs generated through BIP44 can correspond to different cryptocurrencies and are derived in a structured way, making it easier to manage multiple assets in a single wallet. The structure includes the master node, which leads to the formation of child nodes, ultimately generating a tree-like structure of key pairs. This method provides a standardized approach for wallet software to derive multiple accounts and addresses from a single seed, enhancing security and ease of use for cryptocurrency users.",
          "bip44_derivation": "Bip-44 derivation",
          "classic_address": "Classic address",
          "x_address": "X-Address",
          "x_address_desc":
              "The new 𝗫-address format aims to replace the use of a separate destination tag.",
          "tag": "Tag",
          "enter_tag_desc": "The tag must be a value between 0 and 2^32-1.",
          "tag_validator": "The tag must be a value between 0 and 2^32-1.",
          "tap_to_choose_address": "Tap to choose address",
          "invalid_contact_details": "Contact details are invalid",
          "your_accounts": "Your Accounts",
          "contacts": "Contacts",
          "no_contacts_found": "No contacts were found in this network",
          "add_to_contacts": "Add to Contacts",
          "contact_name_validator":
              "The contact name must be at least 3 characters long",
          "name_of_contact": "Name of contact",
          "contact_desc_1":
              "The contact will be saved in the ___1__ network contact list and will only be available within this network.",
          "new_contact": "New Contact",
          "contact_already_exist": "Contact already exists",
          "contact_saved": "Contact saved successfully",
          "tap_to_enter_amount": "Tap to enter amount",
          "retrieving_network_condition":
              "Retrieving network condition. Please Wait.",
          "memo_data": "Memo data",
          "memo_format": "Memo format",
          "memo_type": "Memo type",
          "memos": "Memos",
          "memo_desc":
              "You can add multiple notes up to 1 KB to this transaction.",
          "tap_to_create_memo": "Tap to create memo",
          "create_memo": "Create memo",
          "ripple_memo_desc1":
              "The Memos field includes arbitrary messaging data with the transaction. It is presented as an array of objects. Each object has only one field, Memo, which in turn contains another object with one or more of the following fields:",
          "memos_field": "Memos Field",
          "memo_data_desc":
              "Arbitrary hex value, conventionally containing the content of the memo.",
          "memo_format_desc":
              "Hex value representing characters allowed in URLs. Conventionally containing information on how the memo is encoded",
          "memo_type_desc":
              "Hex value representing characters allowed in URLs. Conventionally, a unique relation (according to RFC 5988) that defines the format of this memo.",
          "tap_to_input_value": "Tap to input the value",
          "empty_desc":
              "If you submit an empty value, it will be recorded. To cancel, please close the page.",
          "hex_desc":
              "Inputs must be in hexadecimal format. If the entered input is not in hexadecimal, the program will convert it to hexadecimal.",
          "setup_input": "Setup input",
          "value_is_empty": "The value is empty.",
          "depositor": "Depositor",
          "trust_set": "TrustSet",
          "tust_line_desc": "Create a trust line for holding tokens.",
          "trust_set_desc2":
              "Create or modify a trust line linking two accounts",
          "issuer": "Issuer",
          "issuer_desc": "The address of the account to extend trust to.",
          "currency": "Currency",
          "currency_desc": "The currency to this trust line applies to",
          "ripple_currency_desc1":
              r"Currency codes must be exactly 3 ASCII characters in length. The following characters are permitted: all uppercase and lowercase letters, digits, as well as the symbols ?, !, @, #, $, %, ^, &, *, <, >, (, ), {, }, [, ], and |.",
          "ripple_currency_desc2": "Currency codes are case-sensitive.",
          "ripple_currency_desc3":
              "The currency code XRP (all-uppercase) is disallowed. Real XRP typically does not use a currency code in the XRP Ledger protocol.",
          "tap_to_enter_currency_code": "Tap to enter the currency code",
          "ripple_currency_desc4":
              "The standard format for currency codes is a three-character string such as USD. This is intended for use with ISO 4217 Currency Codes . The following rules apply:",
          "regular_exception_validate_desc":
              "The input must match the following regular expression ___1__",
          "trust_set_value": "Value",
          "trust_set_value_desc":
              "Quoted decimal representation of the limit to set on this trust line.",
          "enter_valid_number": "Please enter a valid number",
          "minium_numnber_validator":
              "The input number should not be less than ___1__",
          "maximum_number_validator":
              "The input number should not be greater than ___1__",
          "limit_amount_fields": "Fields for LimitAmount",
          "trust_set_quality_in": "Quality In",
          "trust_set_quality_out": "Quality out",
          "trust_set_quality_in_desc":
              "Value incoming balances on this trust line at the ratio of this number per 1,000,000,000 units. A value of 0 is shorthand for treating balances at face value.",
          "trust_set_quality_out_desc":
              "Value outgoing balances on this trust line at the ratio of this number per 1,000,000,000 units. A value of 0 is shorthand for treating balances at face value",
          "trust_set_fields": "TrustSet Fields",
          "trust_set_flags": "TrustSet Flags",
          "account": "Account",
          "insufficient_balance_error":
              "Insufficient balance: You need ___1__ to complete this transaction.",
          "account_set": "AccountSet",
          "account_set_desc":
              "An AccountSet transaction modifies the properties of an account in the XRP Ledger.",
          "domain": "Domain",
          "domain_desc":
              "The domain that owns this account, as a string of hex representing the ASCII for the domain in lowercase.",
          "account_set_fields": "AccountSet Fields",
          "character_length_validator_desc":
              "The ___1__ length cannot exceed ___2__ characters (___3__ bytes).",
          "email_hash": "Email Hash",
          "ripple_email_hash_desc":
              "An arbitrary 128-bit value. Conventionally, clients treat this as the md5 hash of an email address to use for displaying a Gravatar  image.",
          "ripple_message_key": "Message key",
          "ripple_message_key_desc":
              "Public key for sending encrypted messages to this account.",
          "ripple_message_key_desc2":
              "it must be exactly 33 bytes, with the first byte indicating the key type: 0x02 or 0x03 for secp256k1 keys, 0xED for Ed25519 keys. To remove the key, use an empty value",
          "ripple_public_key":
              "Please enter a valid secp256k1 or Ed25519 (Ripple) public key.",
          "ripple_nft_token_minter": "NFT token minter",
          "ripple_nft_token_minter_desc":
              "Another account that can mint NFTokens for you.",
          "ripple_transfer_rate": "Transfer rate",
          "ripple_transfer_rate_desc":
              "The fee to charge when users transfer this account's tokens, represented as billionths of a unit.",
          "ripple_transfer_rate_desc2":
              "Cannot be more than 2000000000 or less than 1000000000, except for the special case 0 meaning no fee",
          "ripple_validate_transfer_rate":
              "Please enter a valid number for the transfer rate.",
          "ripple_tick_size": "Tick size",
          "ripple_tick_size_desc":
              "Tick size to use for offers involving a currency issued by this address",
          "ripple_tick_size_desc2":
              "The exchange rates of those offers is rounded to this many significant digits. Valid values are 3 to 15 inclusive, or 0 to disable.",
          "ripple_validate_tick_size":
              "Please enter a valid number for the tick size.",
          "ripple_enable_account_set_flags": "Enable account set flags",
          "ripple_disable_account_set_flags": "Disable account set flags",
          "account_set_flags": "Account set flags",
          "invalid_balance": "Invalid balance information",
          "network_support_token_error":
              "Token issuance not supported by the network.",
          "network_support_nft_error":
              "NFT issuance not supported by the network.",
          "invalid_token_information": "Invalid token information",
          "invalid_nft_information": "Invalid NFT information",
          "token_already_exists": "Token already exists.",
          "nfts_already_exists": "NFTs already exists.",
          "services": "Services",
          "tokens": "Tokens",
          "no_tokens_found": "No tokens found in the account.",
          "no_nft_found": "No NFTs found in the account.",
          "monitor_my_tokens": "Monitor my tokens.",
          "monitor_my_nfts": "Monitor my NFTs.",
          "add_token": "Add Token",
          "fetching_account_token_please_wait":
              "Retrieving account tokens. please wait.",
          "no_items_found": "No items found.",
          "yes": "Yes",
          "no": "No",
          "add_token_to_your_account": "Add token to your account?",
          "remove_token_from_account": "Remove Token from Your Account?",
          "remove_token": "Remove token",
          "token_transfer": "Token Transfer",
          "token_info": "Token info",
          "account_qr_code": "Account QR Code",
          "manage_tokens": "Manage Tokens",
          "add_or_remove_tokens": "Add or Remove Tokens from Your Account",
          "nfts": "NFTs",
          "add_nft_to_your_account": "Add NFTs to your account?",
          "remove_nft_from_account": "Remove NFTs from Your Account?",
          "remove_nfts": "Remove NFTs",
          "manage_nfts": "Manage NFTs",
          "manage_nfts_desc":
              "Administer NFTs: Burn, Manage, Create, or Cancel Offers",
          "serial": "Serial",
          "nfts_id": "NFTs ID",
          "uri": "URI",
          "ripple_nftokentaxon":
              "	An arbitrary taxon, or shared identifier, for a series or collection of related NFTs",
          "ripple_mint_token_issuer":
              "The issuer of the token, if the sender of the account is issuing it on behalf of another account.",
          "ripple_mint_token_transfer_rate":
              "The value specifies the fee charged by the issuer for secondary sales of the NFToken, if such sales are allowed",
          "nft_token_uri":
              "The contents could decode to an HTTP or HTTPS URL, an IPFS URI, a magnet link",
          "flags": "Flags",
          "nft_flags_field_desc":
              "Transactions of the NFTokenMint type support additional values in the Flags field,",
          "field_is_req": "___1__ is required",
          "ripple_nfttoken_fields": "NFTokenMint Fields",
          "ripple_nftoken_burn_id":
              "The NFToken to be removed by this transaction.",
          "token_id": "Token ID",
          "owner": "Owner",
          "ripple_nftoken_burn_owner":
              "The owner of the NFToken to burn. Only used if that owner is different than the account sending this transaction.",
          "ripple_nftoken_burn_fields": "NFTokenBurn Fields",
          "ripple_create_offer_owner":
              "Who owns the corresponding NFToken. If the offer is to buy a token, this field must be present and it must be different than the Account field (since an offer to buy a token one already holds is meaningless)",
          "expiration": "Expiration",
          "ripple_create_offer_expiration":
              "Indicates the time after which the offer will no longer be valid.",
          "destination": "Destination",
          "ripple_create_offer_destination":
              "If present, indicates that this offer may only be accepted by the specified account.",
          "ripple_create_nft_offer_amount":
              "Indicates the amount expected or offered for the corresponding NFToken.",
          "ripple_create_nft_offer_id":
              "	Identifies the NFToken object that the offer references.",
          "nftoken_create_offer_fields": "NFTokenCreateOffer Fields",
          "token_issuer": "Generally, the account that issues this token.",
          "token_amount": "Token Amount",
          "token_currency":
              "Arbitrary currency code for the token. Cannot be XRP.",
          "token_value":
              "Quoted decimal representation of the amount of the token",
          "plese_enter_currency_first":
              "Please begin by entering the currency.",
          "token_amount_desc": "To specify an amount of a (fungible) token",
          "xrp_amount": "XRP Amount",
          "setup_currency_amount": "Setup currency amount",
          "nft_offer_flag_desc":
              "Transactions of the NFTokenCreateOffer type support additional values in the Flags field",
          "ripple_nftoken_create_offer_fields": "NFTokenCreateOffer fields",
          "ripple_nftoken_accept_offer_fields": "NFTokenAcceptOffer fields",
          "ripple_accept_offer_sell_offer":
              "Identifies the NFTokenOffer that offers to sell the NFToken",
          "ripple_accept_offer_buy_offer":
              "Identifies the NFTokenOffer that offers to buy the NFToken.",
          "ripple_accept_offer_broker_fee":
              "specifies the amount that the broker keeps as part of their fee for bringing the two offers together; the remaining amount is sent to the seller of the NFToken being bought.",
          "ripple_nftoken_cancel_offer_fields": "NFTokenCancelOffer fields",
          "ripple_cancel_nft_token_nftoken_offers":
              "An array of IDs of the NFTokenOffer objects to cancel (not the IDs of NFToken objects, but the IDs of the NFTokenOffer objects)",
          "ripple_escrow_create_fields": "EscrowCreate Fields",
          "ripple_escrow_create_amount":
              "	Amount of XRP to deduct from the sender's balance and escrow.",
          "ripple_escrow_create_destionation":
              "Address to receive escrowed XRP.",
          "ripple_escrow_create_cancel_after":
              "This value is immutable; the funds can only be returned to the sender after this time.",
          "ripple_escrow_create_finish_after":
              "when the escrowed XRP can be released to the recipient. This value is immutable, and the funds can't be accessed until this time.",
          "condition": "Condition",
          "ripple_escrow_create_condition":
              "if this condition is fulfilled. If the condition is not fulfilled before the expiration time specified in the CancelAfter field, the XRP can only revert to the sender.",
          "ripple_escrow_create_destination_tag":
              "Arbitrary tag to further specify the destination for this escrowed payment, such as a hosted recipient at the destination address",
          "ripple_escrow_finish_fields": "EscrowFinish Fields",
          "ripple_escrow_finish_owner":
              "Address of the source account that funded the held payment.",
          "ripple_escrow_finish_sequence":
              "	Transaction sequence of EscrowCreate transaction that created the held payment to finish.",
          "ripple_escrow_finish_condition":
              "Hex value matching the previously-supplied of the held payment.",
          "ripple_escrow_finish_fulfillment":
              "Hex value of the fulfillment matching the held payment's Condition.",
          "ripple_escrow_cancel_fields": "EscrowCancel Fields",
          "ripple_escrow_cancel_owner":
              "Address of the source account that funded the escrow payment.",
          "ripple_escrow_cancel_offer_sequence":
              "Transaction sequence (or Ticket number) of EscrowCreate transaction that created the escrow to cancel.",
          "ripple_trust_set_limit_amount":
              "Object defining the trust line to create or modify, in the format of a Currency Amount.",
          "ripple_trust_set_flags":
              "Transactions of the TrustSet type support additional values in the Flags field, as follows:",
          "ripple_payment_fields": "Payment Fields",
          "invoiceid": "InvoiceID",
          "ripple_payment_invoiceid":
              "Arbitrary 256-bit hash representing a specific reason or identifier for this payment.",
          "payment_flags": "Payment Flags",
          "ripple_payment_flags":
              "Transactions of the Payment type support additional values in the Flags field, as follows",
          "ripple_accept_offer_desc":
              "The NFTokenAcceptOffer transaction is used to accept offers to buy or sell an NFToken.",
          "ripple_nftoken_burn_desc":
              "The NFTokenBurn transaction is used to remove a NFToken object from the NFTokenPage in which it is being held, effectively removing the token from the ledger (burning it).",
          "ripple_nftoken_cancel_offer_desc":
              "The NFTokenCancelOffer transaction can be used to cancel existing token offers created using NFTokenCreateOffer.",
          "ripple_create_nftoken_offer_desc":
              "Creates either a new Sell offer for an NFToken owned by the account executing the transaction, or a new Buy offer for an NFToken owned by another account.",
          "ripple_mint_nftoken_desc":
              "The NFTokenMint transaction creates a non-fungible token and adds it to the relevant NFTokenPage object of the NFTokenMinter as an NFToken object",
          "ripple_payment_desc":
              "A Payment transaction represents a transfer of value from one account to another.",
          "ripple_escrow_cancel_desc": "Return escrowed XRP to the sender.",
          "ripple_escrow_create_desc":
              "Sequester XRP until the escrow process either finishes or is canceled.",
          "ripple_escrow_finish_desc":
              "Deliver XRP from a held payment to the recipient.",
          "ripple_trust_set_desc":
              "Create or modify a trust line linking two accounts.",
          "fulfillment_desc":
              "Crypto condition fulfillment refers to the automated execution of predefined conditions in blockchain-based smart contracts, ensuring trustless and transparent outcomes without the need for intermediaries.",
          "create_random_fulfillment": "Create random fulfillment.",
          "fulfillment": "Fulfillment",
          "fulfillment_desc2":
              "Ensure to securely save both fulfillment and conditions, as they are essential for completing transactions in the escrow process.",
          "apply_for_condition": "Apply for condition.",
          "saved_fulfillment_desc":
              "Are you certain that the fulfillment and conditions have been securely saved?",
          "key_algorithm": "Key algorithm",
          "key_algorithms": "Key algorithms",
          "invalid_ripple_privatekey_algorithm":
              "Invalid Ripple private key encryption algorithm.",
          "ed25519_support_derivation_desc":
              "ED25519 derivation only supports hardened indices.",
          "cannot_export_public_key": "Unable to export public key.",
          "regular_key": "RegularKey",
          "ripple_regular_key_desc":
              "A SetRegularKey transaction assigns, changes, or removes the regular key pair associated with an account.",
          "ripple_set_regular_key_fields": "SetRegularKey Fields",
          "ripple_regular_key_field_desc":
              "A XRP Address that indicates the regular key pair to be assigned to the account. If omitted, removes any existing regular key pair from the account. Must not match the master key pair for the address.",
          "ripple_signer_list_fields": "SignerListSet Fields",
          "ripple_set_signer_list_desc":
              "The SignerListSet transaction creates, replaces, or removes a list of signers that can be used to multi-sign a transaction. This transaction type was introduced by the MultiSign amendment",
          "ripple_signer_quorum_desc":
              "A target number for the signer weights. A multi-signature from this list is valid only if the sum weights of the signatures provided is greater than or equal to this value. To delete a signer list, use the value 0.",
          "ripple_signer_entries_desc":
              "Array of SignerEntry objects, indicating the addresses and weights of signers in this list. This signer list must have at least 1 member and no more than 32 members.",
          "ripple_signer_entery": "Signer Entry",
          "ripple_signer_entery_desc":
              "Each member of the SignerEntries field is an object that describes that signer in the list",
          "ripple_signer_enteris_fields": "SignerEntries fields",
          "ripple_signer_entry_account_desc":
              "An XRP Ledger address whose signature contributes to the multi-signature. It does not need to be a funded address in the ledger.",
          "ripple_signer_weight": "SignerWeight",
          "ripple_signer_weight_desc":
              "The weight of a signature from this signer. A multi-signature is only valid if the sum weight of the signatures provided meets or exceeds the signer list's SignerQuorum value.",
          "ripple_wallet_locator": "WalletLocator",
          "ripple_signer_entry_wallet_locator_desc":
              "Arbitrary hexadecimal data. This can be used to identify the signer or for other, related purposes.",
          "hash256_validator":
              "Invalid hash256: The hash256 value must be a hexadecimal string with a length of 64 characters",
          "setup_signer": "Setup signer",
          "ripple_signer_quorum_validator":
              "signerQuorum must be less than or equal to the sum of the SignerWeight values in the signerEntries list.",
          "disable_master_key_addr":
              "Master key disablement is active. Please utilize a multi-signature account for signing or creating transactions.",
          "ripple_multi_sig_address_desc":
              "Ripple accommodates both multi-signature and regular key signature transactions.",
          "ripple_multi_sig_account_desc":
              "Kindly input the address of the primary account supporting either multi-signature or regular key transactions.",
          "retrieving_account_information":
              "Retrieving account information. Please Wait.",
          "get_account_information": "Get account information",
          "ripple_mutlti_sig_address_not_found":
              "The account could not be found or does not support the multi-signature feature",
          "ripple_multi_sig_address_desc2":
              "Please choose either a signer list or a regular key to create a multi-signature address.",
          "signer_list": "Signer list",
          "account_does_not_support_feature":
              "The account does not support this feature",
          "multi_sig_feature_type": "Multi-signature Feature Type",
          "signerquorum": "SignerQuorum",
          "ripple_multi_sig_addres_signer_list_desc":
              "Please choose the required number of signers, matching the Signer Quorum, whose private keys are accessible from your accounts for verification. If the desired account is not in your account list, you must first add it to your wallet through the settings.",
          "account_does_not_match_with_signer_account":
              "The account does not match with the signer account.",
          "ripple_multi_sig_addres_signer_list_desc2":
              "Kindly tap each address to confirm the availability of its private key",
          "ripple_multi_sig_regular_key_desc":
              "The account has a regular key. To send and sign the transaction, you need the private key of the regular key address",
          "its_not_multisig_account": "It is not a multi-signature account",
          "ripple_payment_send_to_self_desc":
              "An XRP payment transaction cannot have the same sender and destination",
          "ripple_account_signature_updated_desc":
              "The account signature settings have been updated. To ensure proper functionality, we recommend removing the account from your list and adding it again with the revised settings.",
          "accounts": "Accounts",
          "private_keys": "Private keys",
          "private_keys__signing_access_desc":
              "The data requires the use of the following private keys to complete the signing process.",
          "amount_for_each_output":
              "Kindly input the preferred quantity for each output.",
          "cancel": "Cancel",
          "account_name": "Account name",
          "setup_or_update_account_name": "Establish or Refresh Account Name",
          "remove_account_name_desc":
              "If you wish to remove the account name, please confirm by entering an empty text.",
          "evm_networks": "EVM",
          "tvm_networks": "TVM",
          "sol_networks": "SOL",
          "disable_standard_derivation":
              "You can manually create a BIP32 path to generate an address by disabling the standard derivation.",
          "transfer": "Transfer",
          "slow": "Slow",
          "normal": "Normal",
          "high": "High",
          "max_base_fee": "Max base fee",
          "max_priority": "Max priority",
          "gas_price": "Gas Price",
          "gwei": "GWEI",
          "eip_1559_gas_fee": "EIP-1559 Gas Fee",
          "legacy_gas_fee": "Legacy Gas Fee",
          "what_is_max_fee":
              "Max base fee refers to the upper limit or maximum value that the base fee component of a transaction can reach within the Ethereum network",
          "what_is_prority_fee":
              "the Priority Fee in Ethereum, especially in the context of EIP-1559, is an extra amount that users can include in their transactions to increase the likelihood of miners including them in the next block.",
          "eth_fee_desc":
              "The transaction's true cost is determined by multiplying the maximum base fee by the specified gas limit.",
          "eth_legacy_fee_desc":
              "The transaction's true cost is determined by multiplying the gas price by the specified gas limit.",
          "gas_limit": "Gas limit",
          "gas_limit_desc":
              "is the unit used to measure the amount of computational effort required to execute operations or smart contracts. Each operation consumes a certain amount of gas, and the gas limit determines the total computational resources available for the transaction.",
          "gas_limit_validator":
              "The gas limit must be set to a value greater than zero.",
          "gas_limit_helper":
              "The gas limit is below the current network conditions.",
          "prority_fee_validator":
              "The priority fee should be a non-negative decimal value.",
          "max_base_fee_validator":
              "The Max base fee should be a non-negative decimal value.",
          "gas_price_fee_validator":
              "The Gas price should be a non-negative decimal value.",
          "max_base_fee_helper1":
              "The Max base fee is below the current network conditions.",
          "gas_price_fee_helper1":
              "The Gas price is below the current network conditions.",
          "max_base_fee_helper2":
              "The Max base fee is higher than the current network conditions.",
          "gas_price_fee_helper2":
              "The Gas price is higher than the current network conditions.",
          "max_priority_helper1":
              "The Max priority is below the current network conditions.",
          "max_priority_helper2":
              "The Max priority is higher than the current network conditions.",
          "input_the_amout": "Input the transaction amount in the field below",
          "import_token": "Import Token",
          "contract_address": "Contract address",
          "import_erc20_token": "Import ERC-20 token",
          "import_trc20_token": "Import TRC-20 token",
          "import_erc20_desc":
              "Input the contract address of your token to import it into your account.",
          "tap_to_input_contract_address": "Tap to input contract address",
          "add_to_my_account": "Add to My Account",
          "retrieving_contract_detauls":
              "Retrieving smart contract information. Please Wait.",
          "smart_contract_not_found":
              "No smart contract found; please verify the contract address.",
          "import_new_token": "Import new token",
          "transfer_erc20": "Transfer ERC-20",
          "transfer_trc20": "Transfer TRC-20",
          "transfer_trc10": "Transfer TRC-10",
          "multi_sig_account_does_not_supported":
              "Your account lacks the necessary permissions to initiate this transaction. Please utilize the multi-signature feature for authorization.",
          "total_burn": "Total burn",
          "fee_limit": "Fee Limit",
          "default": "Default",
          "custom": "Custom",
          "burn": "Burn",
          "bandwidth": "Bandwidth",
          "energy": "Energy",
          "consumed_stacked": "Consumed/Stacked",
          "trx_burned_for_resource": "Trx burned for resource",
          "tron_fee_limit_desc":
              "The fee limit represents the maximum amount of energy or bandwidth that a user is allowed to consume for a specific transaction",
          "low_fee_limit_desc":
              "The specified fee limit is insufficient for the operation's resource requirements.",
          "take_another_shot": "Take another shot",
          "trc20_tokens": "TRC-20 Tokens",
          "trc10_tokens": "TRC-10 Tokens",
          "erc20": "ERC-20",
          "trc20": "TRC-20",
          "trc10": "TRC-10",
          "update_account_permission": "Update account permission",
          "permissions": "Permissions",
          "tron_permission_desc":
              "Choose the permission you wish to modify or remove.",
          "permission_name": "Permission name",
          "input_the_permission_name": "Input the permission name",
          "operations": "Operations",
          "tron_operations_desc":
              "This permission grants access to the following operations.",
          "all_operations": "All Operations",
          "operation_disabled": "The operation is disabled",
          "tron_threshhold_desc":
              "Operation is permitted only when the combined weights of the involved signatures surpass the specified value",
          "tron_permission_key": "Signers (Key)",
          "tron_permission_key_desc":
              "The accounts and weights that all own the permission, 5 keys at most.",
          "tap_to_input_new_signer": "Tap to input new signer",
          "signer": "Signer",
          "signer_account_address": "The signer account address",
          "signer_already_exist": "The signer already exist",
          "new_active_permission": "New active permission",
          "update_permission": "Update permission",
          "remove_permission": "Remove permission",
          "tron_signer_validator_desc":
              "The number of signers should not exceed 5.",
          "tron_signer_validator_witness_desc":
              "The required number of witness signers is 1.",
          "tron_permission_threshhold_validator":
              "The cumulative weight of the signatories must meet the specified threshold.",
          "tron_permission_validator1":
              "Please save the current permission before making any further changes.",
          "permission_is_being_edited": "Permission is being edited",
          "update_account_permissions": "Update the account's permission.",
          "tron_multi_sig_desc":
              "Tron supports multi-signature transactions, allowing you to select a specific permission and initiate transactions corresponding to that chosen permission.",
          "tron_multi_sig_desc2":
              "Kindly input the Tron address to which you intend to send transactions.",
          "tron_multi_sig_select_permission":
              "Kindly choose the permission you desire.",
          "tron_multi_sig_addres_threshhold":
              "Please choose the required number of signers, matching the threshhold, whose private keys are accessible from your accounts for verification. If the desired account is not in your account list, you must first add it to your wallet through the settings.",
          "tron_account_permission_not_access_desc":
              "The account permission has been modified, or the current authorization does not grant access to initiate this type of transaction.",
          "tron_stack_v2": "Stake2.0",
          "tron_unstack_v2": "Unstake2.0",
          "frozen_balance": "Frozen balance",
          "unfreeze_balance": "Unfreeze balance",
          "trx_stake_amount": "TRX stake amount",
          "trx_unstake_amount": "The amount of TRX to unstake",
          "resource": "Resource",
          "trx_stake_type": "TRX stake type",
          "stacke_amount": "Stake amount",
          "stacking_balance_in_your_account": "Staking balance in your account",
          "delegated_resource": "Delegate Resource",
          "delegate_resource_desc":
              "Delegate bandwidth or energy resources to other accounts",
          "delegatable_amount": "Delegatable  amount",
          "delegatable_amount_desc": "The amount of delegatable resource share",
          "resource_delegated_amount": "Resource delegate amount",
          "resource_receiver_address": "Resource receiver address",
          "lock": "Lock",
          "lock_period": "Lock period",
          "tron_delegate_resource_lock_desc":
              "Whether to lock the resource delegation, enable means locked the delegation, the delegating cannot be canceled within the period specified by the lock period",
          "tron_delegate_lock_time_desc":
              "Lock time,The unit is block interval(3 seconds), indicates the time of how many blocks which the delegation will be locked",
          "tron_delegate_lock_time_desc2":
              "Lock time,The unit is block interval(3 seconds), indicates the time of how many blocks which the delegation will be locked. Only when lock is true, this field is valid. If the delegate lock period is 1 day, the lock_period is: 28800. The minimum value of lock_period is the remaining lock period of this type of resource that was delegated last time, and the maximum value is 864000 (30 days). If lock is true and lock_period is not set or set to 0, lock_period will be set to the default value 86400 (3 days) automatically",
          "retrieving_resources": "Retrieving Resources. Please Wait.",
          "no_bandwidth_resourced": "Bandwidth resources unavailable.",
          "no_energy_resourced": "Energy resources unavailable.",
          "undelegated_period_time_desc":
              "Undelegation not permitted during lock period.",
          "balance": "Balance",
          "undelegated_balance_desc":
              "Amount of TRX staked for resources to be delegated",
          "undelegated_resource": "UnDelegate Resource",
          "undelegated_resource_validator_desc1":
              "Undelegation requires available resources.",
          "undelegated_resource_desc":
              "Cancel the delegation of bandwidth or energy",
          "url": "Url",
          "create_witness": "Create Witness",
          "create_witness_desc": "Apply to become a witness.",
          "tron_create_witness_url_desc": "The website URL of the SR node",
          "update_witness": "Update witness",
          "update_witness_desc":
              "Edit the URL of the witness's official website.",
          "tron_mutlisig_active_length_validator":
              "You must have 1 to 8 permissions with an active permission type.",
          "permission_type": "Permission type",
          "update_account": "Update account",
          "account_name_desc": "name of the account",
          "modify_account_name": "Modify account name",
          "key_name": "Key name",
          "import_private_key_key_name_desc":
              "A distinctive identifier for enhanced key differentiation.",
          "import_evm_network": "Import ethereum network",
          "import": "Import",
          "import_new_network": "Import new network",
          "import_new_network_desc1":
              "Providing an incorrect or malicious RPC endpoint can compromise the security of your wallet. Always double-check the accuracy of the RPC URL before adding a new network.",
          "import_new_network_desc2":
              "Custom networks might lack the same level of security as well-established, widely-used networks. Ensure that you trust the administrators and community behind the custom network to minimize potential vulnerabilities.",
          "chain_id": "Chain ID",
          "chain_id_desc": "Specify the unique identifier for the network.",
          "rpc_url": "RPC Url",
          "rpc_url_desc":
              "Enter the RPC endpoint for the network. Ensure it is correct and secure.",
          "network_name": "Network name",
          "network_name_desc": "Give your custom network a descriptive name.",
          "symbol": "Symbol",
          "symbol_desc": "Add a symbol for easy identification.",
          "chain_id_validator": "Please enter a valid chain ID.",
          "rpc_url_validator":
              "Please enter a valid RPC URL starting with 'http' or 'https'.",
          "network_name_validator":
              "Please enter a valid network name without special characters, with a maximum length of 20 characters.",
          "symbol_validator":
              "Please enter a valid Symbol without special characters, with a maximum length of 6 characters.",
          "invalid_json_response":
              "Invalid response. Expected JSON, but received something else",
          "http_error_404":
              "Error 404: Resource Not Found. The requested URL or endpoint could not be located on the server.",
          "http_error_400":
              "Error 400: Bad Request. The server could not understand the request due to invalid syntax or missing parameters.",
          "http_error_401":
              "Error 401: Unauthorized. Access to the requested resource is denied due to missing or incorrect authentication credentials.",
          "http_error_403":
              "Error 403: Forbidden. Access to the requested resource is forbidden.",
          "http_error_405":
              "Error 405: Method Not Allowed. The specified HTTP method is not supported for the requested resource",
          "http_error_408":
              "Error 408: Request Timeout. The server timed out while waiting for the request",
          "http_error_500":
              "Error 500: Internal Server Error. The server encountered an unexpected condition that prevented it from fulfilling the reques",
          "http_error_503":
              "Error 503: Service Unavailable. The server is currently unable to handle the request due to temporary overloading or maintenance of the server",

          "network_chain_id_already_exist": "The network already exists.",
          "invalid_chain_id":
              "The Chain ID does not match the Network ID associated with the provided RPC link.",
          "network_imported_to_your_wallet":
              "The network has been successfully imported to your wallet.",
          "providers": "Providers",
          "edit_or_add_evm_provider_desc":
              "Please choose the provider you wish to edit or add a new one",
          "edit_provider_rpc_url": "Edit Provider RPC URL",
          "update_url": "Update URL",
          "discard_changes": "Discard Changes",
          "checking_rpc_network_info": "Checking RPC Network Information",
          "rpc_url_has_been_updated": "RPC URL has been updated.",
          "rpc_url_already_exists":
              "A provider already exists with this RPC URL.",
          "tap_to_add_new_service_provider":
              "Tap to add a new service provider.",
          "update_network": "Update Network",
          "chain_id_of_network": "The chain ID of the network",
          "updating_network": "Updating network information. Please Wait.",
          "network_updated_successfully":
              "The network has been successfully updated.",
          "invalid_network_information": "Invalid network information.",
          "import_network": "Import network",
          "backup_multi_sig_address_desc":
              "Are you certain that the address information has been securely saved?",
          "choose_all_utxos": "Choose all Unspent Transaction Outputs (UTXOs)",
          "remaining_amount": "Remaining amount",
          "remaining_amount_and_receiver":
              "Remaining amount of UTXO and receiver address.",
          "cost_for_transaction": "Cost for transactions",
          "rbf_desc":
              "Allows users to adjust transaction fees after initiation for priority or confirmation speed changes.",
          "memo_desc2":
              "Additional message or information attached to a transaction.",
          "custom_derivation": "Custom derivation",
          "key_already_exists": "Private key already exists",
          "wallet_deletation_desc":
              "Have you verified the existence of a backup for your wallet before proceeding with deletion?",
          "read_more": "Read more...",
          "harden": "Harden",
          "p2sh32": "P2SH32",
          "use_pay_to_script_hash_32": "Use Pay to Script Hash 32",
          "transaction_fee_has_been_modified":
              "The transaction fee has been modified.",
          "transaction_fee_warning":
              "The transaction fee is currently lower than the prevailing network conditions.",
          "transaction_fee_high_warning":
              "The transaction fee is currently higher than the prevailing network conditions.",
          "bch_specific": "BCH Specific",
          "token_aware": "Token-aware",
          "cash_token_desc":
              "Use this address to send or receive CashTokens on the BCH network",
          "retreiving_account_utxos": "Retrieving Accounts UTXOs. Please Wait.",
          "create_tokens": "Create Token",
          "fungible_tokens": "Fungible Tokens",
          "minting_nft": "Minting NFT",
          "immutable_nft": "Immutable NFT",
          "select_token_type": "Choose Token Type.",
          "create_token_desc1":
              "Please carefully review this page before proceeding to create a token.",
          "total_supply": "Total supply",
          "input_total_supply": "Input the total supply of fungible tokens.",
          "token_meta_data": "Token Metadata",
          "cash_tokens_metadata_desc1":
              "You can enhance your Cashtokens with metadata using the BCMR standard.",
          "cash_token_creation_desc1":
              "With the AuthUTXO token, you can add or update token metadata at any time. However, it's crucial to transfer the authority to update metadata (AuthUTXO) to a dedicated wallet immediately after creation. You can create an Auth account from the services section on the account page.",
          "add_meta_data": "Add Metadata",
          "where_meta_data_uoloaded": "Where is your token metadata uploaded?.",
          "ipfs": "IPFS",
          "https": "HTTPS",
          "gist": "Github (gist)",
          "meta_data_uploaded_in": "Metadata uploaded in",
          "input_your_meta_data_uri_desc":
              "Enter your Metadata URI with the 'https' prefix",
          "input_your_meta_data_ipfs_cid":
              "Enter your Metadata IPFS CID V1 (must start with 'baf').",
          "ipfs_cid": "IPFS CID V1",
          "invalid_ipfs_v1_cid": "Invalid IPFS v1 CID",
          "validate_https": "Please enter a valid URL starting with 'https'.",
          "read_uri_content": "Read URI Content",
          "fetching_uri_content":
              "Fetching the content of the URI. Please wait.",
          "bitcoin_cash_meta_data_registeries":
              "Bitcoin Cash Metadata Registries",
          "content": "Content",
          "content_of_uri": "The content of uri",
          "bcm_uri": "BCMR URI",
          "bcmr_hash": "BCMR Hash",
          "bcmr_hash_desc": "The SHA-256 hash of your URI content",
          "setup_bcmr": "Setup BCMR",
          "tap_to_add_bcmr": "Tap to add BCMR",
          "bcmr": "BCMR",
          "bcmr_hash_desc1": "All URIs' BCMR content hashes must be identical.",
          "uri_already_exist": "The URI already exist.",
          "on_chain_uri": "On-chain URI",
          "on_chain_uri_desc": "on-chain Metadata URI",
          "bch_create_token_index_error":
              "To create tokens, you need a UTXO with index 0. Your account does not currently possess any UTXOs with index 0.",
          "bch_token_index_zero_error":
              "To generate a token, it's essential to have a UTXO (Unspent Transaction Output) with an index of 0. Unfortunately, the UTXOs you've chosen at the moment do not include any with an index of 0.",
          "token_authory": "Token authority",
          "token_authory_desc":
              "You have the option to create a token for another account instead of your own",
          "create_token_amount_desc":
              "The amount for the token output is required to be a minimum of ___1__ satoshis when creating a token.",
          "bcmr_hash_validate_desc":
              "All URIs' contents must have the same hash.",
          "nft": "NFT",
          "capability": "Capability",
          "capability_desc": "The capability of the NFT",
          "none": "None",
          "mutable": "Mutable",
          "minting": "Minting",
          "capability_required_desc":
              "The capability is required for non-fungible tokens.",
          "commitment": "Commitment",
          "commitment_desc": "The commitment contents of the NFT",
          "commitment_validate_desc":
              "The commitment must be a maximum of 40 bytes (80 characters).",
          "output_index_desc":
              "Output index (position) within the transaction.",
          "max": "MAX",
          "token_utxos": "Token UTXOs",
          "includ_token_utxos": "Include token UTXOs.",
          "category_id": "Category ID",
          "tap_to_add_new_receipment": "Tap to add new recipient",
          "add_operation_for_each_token": "Add operation for each tokens.",
          "tap_to_add_operation": "Tap to add operation.",
          "token_operation": "Token Operation",
          "operation": "Operation",
          "initiate_operations": "Initiate operations: send, mint, or burn.",
          "t_amount": "___1__ amount",
          "setup_operation": "Setup Operation",
          "remaining_token_amount_and_receiver":
              "Remaining token amount of UTXO and receiver address.",
          "remaining_token_amount_desc":
              "You must utilize the entire amount for the transaction to be accepted. Alternatively, you have the option to include a new recipient using your address for the remaining balance.",
          "tap_to_add_commitment": "Tap to add commitment",
          "without_commitment": "Without commitment",
          "update_commitment": "Update commitment",
          "display_all_account": "Display all accounts",
          "spending_from_multiple_account": "Spending from multiple accounts",
          "accounts_removed_from_spending_list":
              "Accounts removed from spending list",
          "transaction_ordering": "Transaction Ordering",
          "transaction_ordering_desc":
              "The order in which these inputs and outputs are listed in transaction.",
          "bip69": "BIP-69",
          "shuffle": "Shuffle",
          "inputs": "Inputs",
          "outputs": "Outputs",
          "save": "Save",
          "bip_69_desc":
              "Lexicographical Indexing of Transaction Inputs and Outputs",
          "shuffle_desc": "Mixing inputs and outputs (random)",
          "none_ordering_transaction_desc":
              "The order of selected UTXOs, added outputs, remaining output, and notes determines the shuffle.",
          "manually": "Manually",
          "manually_ordering_transaction_desc":
              "Sort manually before sending; note that changes after may reset to the default (BIP-69) sort algorithm.",
          "token_id_choose_desc":
              "Kindly choose a UTXO that you wish to use as the hash for your token ID.",
          "token_id_validator_desc": "The Token ID cannot be null.",
          "ft": "Fungible Token",
          "tap_to_create_token": "Tap to create a new token.",
          "tap_to_add_mint_operation": "Tap to add mint operation.",
          "tap_to_add_transfer_operation": "Tap to add transfer operation.",
          "tap_to_add_burn_operation": "Tap to add burn operation.",
          "setup_burnable_amount": "Setup the amount eligible for burning.",
          "burn_amount": "Burn amount",
          "transaction_generated_with_number_accounts":
              "A transaction has been generated, involving ___1__ accounts",
          "transaction_need_number_private_key_to_complete":
              "The transaction requires the input of ___1__ private keys for completion.",
          "list_of_operations": "List of operations",
          "node_connection_error":
              "The connection with the node could not be established",
          "network_unbale_change_providers":
              "Unable to modify default providers.",
          "protocol": "Protocol",
          "network_protocol_not_supported":
              "The ___1__ protocol is not supported on this platform.",
          "network_tittle_tcp_ssl_url":
              "Enter the ___1__ URL or IPv4 address without any prefix, including the port, like example.com:50002.",
          "network_title_websocket_url":
              "Please supply the WebSocket address, including the WS or WSS prefix, and if necessary, specify the port. For example, wss://example.com.",
          "network_title_http_url":
              "Please provide the HTTP or HTTPS address, including the http:// or https:// prefix. If applicable, include the port number. For example, https://example.com:8080",
          "network_tcp_address_validator":
              "Invalid TCP or IPv4 address. Please refer to the example address for proper formatting.",
          "network_websocket_address_validator":
              "Invalid Websocket address. Please refer to the example address for proper formatting.",
          "network_waiting_for_response": "Awaiting a reply. please wait.",
          "network_verify_server_status": "Verify server status.",
          "network_server_banner": "Server banner",
          "network_server_banner_desc":
              "Banner to be shown in the Electrum console.",
          "network_server_features": "Server features",
          "network_server_features_desc":
              "List of features and services supported by the server.",
          "network_header": "Block header",
          "network_block_header_desc":
              "The header of the current block chain tip.",
          "network_update_node_provider": "Update node provider",
          "network_security_title":
              "Ensuring wallet security: tips for adding node providers",
          "network_security_desc":
              "Ensuring the security of your wallet is paramount. When adding a new provider, it's crucial to verify the RPC endpoint's accuracy to prevent potential security compromises. Before integration, double-check the RPC URL for correctness. Take an additional layer of caution by cross-referencing the current server header with a trusted block explorer or other reliable sources. These measures enhance security, providing confidence that the provider added to your wallet is secure and free from any malicious intent.",
          "network_add_to_providers": "Add to providers.",
          "network_update_network_providers": "Update network providers.",
          "network": "Network",
          "network_change_detect_desc":
              "Prioritize the use of the 'Update Network Provider' option before making any changes.",
          "network_no_provider_detected":
              "No node provider detected. Please add a provider for the network.",
          "network_add_provider": "Tap to add new service provider.",
          "network_explorer_address_link": "Explore Address Link",
          "network_explorer_transaction_link": "Explore Transaction Link",
          "network_evm_explorer_address_desc":
              "To retrieve the current link in the explorer, please use #address as a placeholder for the actual address in the link, such as https://example.com/address/#address.",
          "network_evm_explorer_transaction_desc":
              "To retrieve the current link in the explorer, please use #txid as a placeholder for the actual transaction in the link, such as https://example.com/tx/#txid.",
          "validate_link_desc":
              "Please enter a valid URL starting with 'http' or 'https'.",
          "default_providers": "Default providers.",
          "api_unknown_error":
              "An unidentified error occurred during the request",
          "api_http_timeout_error":
              "Request Timeout: The server did not respond within the specified time frame",
          "api_http_client_error":
              "ClientException: An error occurred on the client side during the request.",
          "bch_nft_wrong_capability":
              "It is not possible to alter a mutable NFT into a minting state",
          "network_electrum_genesis_hash": "Genesis hash",
          "network_genesis_hash_validator":
              "The Genesis Hash is incompatible with the current network.",
          "network_security_issue": "Security issue",
          "network_electrum_incorrect_genesis_hash":
              "The Genesis Hash is not compatible with the current network. You may encounter inaccurate information, or the server may belong to another network. Are you certain about this?",
          "network_incorrect_chain_id":
              "The Chain ID is not compatible with the current network. You may encounter inaccurate information, or the server may belong to another network. Are you certain about this?",

          "network_provider_log_details": "Provider Log Details",
          "network_total_request": "Total requests",
          "network_total_success_request": "Total Success Requests",
          "network_request_details": "Request details",
          "request": "Request",
          "response": "Response",
          "error": "Error",
          "status": "Status",
          "pro_transaction_builder": "Transaction Composer Pro",
          "bch_pro_builder_desc":
              "Enable Cashtoken functionality, including minting, burning, spending, and sending NFTs.",
          "toggle_currency": "Toggle Currency",
          "view_on_coingecko": "View ___1__ on CoinGecko",
          "network_tron_provider_desc":
              "For the time being, the Tron network exclusively supports the Trongrid API.",
          "min": "MIN",
          "bitcoin_rbf_error":
              "When using RBF, make sure your UTXOs have been confirmed; otherwise, you may encounter a non-final error",
          "inaccessible_key_algorithm":
              "Key algorithm inaccessible in multisig account.",
          "destination_info": "Destination info",
          "destination_info_desc": "The information about destination account",
          "executable": "Executable",
          "import_spl_tokens": "Import SPL Tokens",
          "unable_to_locate_token":
              "Unable to locate any tokens in your account",
          "unable_to_locate_jetton":
              "Unable to locate any Jetton tokens in your account",
          "cardano_networks": "ADA",
          "select_era_for_generate_addr":
              "Please select the Cardano era to generate the address.",
          "shelly": "Shelley",
          "byron": "Byron",
          "recommended_address_type":
              "We recommend using the latest era (Shelley) to access all network features.",
          "cardano_era": "Cardano Era",
          "master_key_generation": "Master Key Generation",
          "cardano_bip32_master_key":
              "Cardano supports two different methods for generating the BIP32 master key.",
          "choose_master_key_gen":
              "Please choose the master key generation method.",
          "ledger": "Ledger",
          "icarus": "Icarus",
          "shelley_address_format": "Shelley address format",
          "base": "Base",
          "reward": "Reward",
          "enterprise": "Enterprise",
          "use_legacy": "Use legacy",
          "seed_generation": "Seed Generation",
          "seed_generation_type":
              "Please select the method for generating the seed",
          "byron_legacy_seed": "Byron Legacy Seed",
          "bip39_seed": "BIP-39 Seed",
          "byron_legacy": "Byron legacy",
          "first_index": "First index",
          "second_index": "second index",
          "invalid_derivation_index": "Invalid derivation index",
          "basic": "Basic",
          "n_asset": "___1__ Asset",
          "remaining_asset_amount": "Remaining asset amount",
          "remaining_asset_amount_and_receiver":
              "Remaining asset amount of UTXO and receiver address.",
          "assets": "Assets",
          "tap_to_add_assets_for_recipient": "Tap to add assets for recipient",
          "set_amount_for_each_assets_or_zero":
              "Set the amount for each asset you wish to transfer; otherwise, leave it as zero.",
          "setup_recipient_assets": "Setup recipient assets",
          "a_minimum_a_ada_required": "A minimum of 1 ADA output is required.",
          "unsuported_feature": "Unsuported feature",
          "cosmos_networks": "Cosmos and forked",
          "ton_networks": "Ton networks",
          "add_least_one_receipt": "Add at least one recipient",
          "the_amount_is_unspecified": "The amount is unspecified.",
          "elliptic_curve_options": "Elliptic Curve Options",
          "address_generation_algorithm":
              "Address Generation Algorithm Selection",
          "amount_must_exceed": "The output amount must exceed ___1__.",
          "back_to_the_page": "Back to the page",
          "label": "Label",
          "metadatum_label": "Metadatum label",
          "enther_valid_un_label": "Please enter a valid unsigned number.",
          "label_already_exists": "The label you entered already exists.",
          "no_account_chosen": "No account has been chosen.",
          "associated_token_program": "Associated Token Program",
          "create_associated_token_account": "Create Associated Token Account",
          "mint": "Mint",
          "token_program": "Token Program",
          "owner_address": "Owner address",
          "mint_address": "Mint address",
          "mint_address_desc": "The mint account address",
          "program_address": "Program address",
          "program_address_desc": "The address of token program",
          "associated_token_address": "Associated token address",
          "new_account_address": "New Account address",
          "solana_new_account_desc":
              "Please provide the address for the account you wish to create, the account should be imported to your wallet before creation",
          "owner_of_account": "The owner of account",
          "account_size": "Account size",
          "lamports": "Lamports",
          "create_account": "Create Account",
          "solana_create_account_desc":
              "A created account is initialized to be owned by a built-in program called the System program.",
          "setup_account_size": "Setup account size",
          "solana_create_account_lamports_desc":
              "Amount of lamports to transfer to the created account",
          "required_signer_account_missing":
              "Required signer account is missing",
          "solana_account_size_desc":
              "the amount of memory allocated to store data associated with the account on the blockchain",
          "mint_authority": "Mint authority",
          "decimals": "Decimals",
          "solana_mint_decimal_desc":
              "Number of base 10 digits to the right of the decimal place",
          "mint_authority_desc": "The authority of mint tokens.",
          "freeze_authority": "Freeze authority",
          "freeze_authority_desc": "The freeze authority of the mint.",
          "program_id": "Program ID",
          "solana_program_id_desc": "The unique identifier of the application",
          "mint_address_to_initialize": "The mint address to initialize.",
          "setup_token_decimal": "Setup token decimals",
          "initialize_mint": "Initialize mint",
          "initiailize_mint_desc":
              "Initializing a mint in Solana creates a new token type.",
          "transfer_symbol": "Transfer ___1__",
          "mint_to": "Mint to",
          "mint_address_mint_desc": "The mint address",
          "mint_to_desc": "Mints new tokens to an account.",
          "authority": "Authority",
          "mint_to_authority_desc": "The mint's minting authority.",
          "mint_to_destination_desc": "The account to mint tokens to.",
          "unknown_token": "Unknown token",
          "mint_to_amount_desc": "The amount of new tokens to mint.",
          "use_owner_account_instead_pda_desc":
              "The account to mint tokens to. Utilize owner account. application automatically locates current PDA account.",
          "name": "Name",
          "update_token": "Update token",
          "update_token_information": "Update token information",
          "update_token_desc": "Update the name and symbol of the token",
          "token_symbol_validator":
              "The token symbol must be at least 2 characters long",
          "token_denom_validator":
              "The token denom must be at least 2 characters long",
          "token_name_validator":
              "The token name must be at least 3 characters long",
          "create_new_provider": "Create New Provider",
          "gnesis_hash_desc":
              "The genesis hash is the unique identifier for the initial block in a blockchain network, often used for network bootstrapping and verifying network state",
          "policy_id": "Policy ID",
          "utxos_amount": "UTXOs amount",
          "create_a_new_token": "Create a new token",
          "ada_asset_name_validator": "Please provide a name for the asset.",
          "ada_create_new_token_desc":
              "Kindly specify the asset name and total supply for your new token.",
          "asset_name": "Asset name",
          "name_of_token": "Name of token",
          "total_supply_desc":
              "Please specify the initial token supply amount.",
          "setup_supply": "Setup supply",
          "tap_to_input_total_supply": "Tap to input total supply",
          "owner_of_token": "The owner of token",
          "tap_to_select_account": "Tap to select account",
          "setup_mint": "Setup mint",
          "byron_reward_does_not_support_minting_token":
              "The Byron and Reward address does not support the initialization of minting tokens.",
          "certificates": "Certificates",
          "add_certificate_to_transaction":
              "Add certificates to the transaction",
          "tap_to_add_certificate": "Tap to add certificate",
          "deregistration": "Deregistration",
          "registration": "Registration",
          "delegation": "Delegation",
          "certificate_type": "Certificate type",
          "add_certificate_to_transaction_desc":
              "Please choose the certificate you would like to include in the transaction.",
          "certificate": "Certificate",
          "stake_address": "Stake address",
          "setup_certificate": "Setup certificate",
          "stake_registration": "Stake Registration",
          "stake_address_validator":
              "The account does not possess a stake address",
          "stake_deregistration": "Stake Deregistration",
          "stake_delegation": "Stake Delegation",
          "deposit": "Deposit",
          "transaction_deposits_list": "List of required transaction deposits",
          "refund_deposit": "Refund deposit",
          "unable_to_spend_from_stake_address":
              "Unable to spend from a stake address.",
          "cannot_send_ada_to_stake_address":
              "Sending ADA or assets to a stake address is not allowed.",
          "stake_key_derivation": "Stake key derivation",
          "ada_base_stake_key_same_error":
              "ensure that the base key and stake key are not generated using the same key.",
          "feature__unavailable_for_multi_signature":
              "The feature is unavailable for multi-signature addresses.",
          "select_creation_type": "Select creation type",
          "setup_address_derivation_keys_desc":
              "In the setup derivation, you can select imported keys if they exist.",
          "please_following_steps_to_generate_address":
              "Please follow these steps to generate an address.",
          "stake_key": "Stake key",
          "main_key": "Main key",
          "base_key": "Base key",
          "switch_between_keys":
              "Please switch between keys to view information about each one.",
          "retrieve_account_informations":
              "Please wait while we retrieve the account informations.",
          "public_keys": "Public keys",
          "Invalid_coin_default_path": "Invalid coin default path",
          "invalid_hd_wallet_derivation_path":
              "Invalid HD wallet derivation path",
          "invalid_substrate_path": "Invalid substrate path.",
          "derivation_path": "Derivation path",
          "hd_wallet_path_max_indeqxes":
              "only supports up to ___1__ HD wallet indexes.",
          "byron_legacy_hd_path_max_indexes":
              "only supports up to ___1__ HD wallet indexes.",
          "unsupported_hd_wallet_index": "Unsupported hd wallet index.",
          "hd_wallet_hardened_desc":
              "For hardened indices, append ' or h to the end of the index.",
          "hd_wallet_substrate_hardened_desc":
              "For hardened indices, append // to the start of the index.",
          "imported_": "Imported(___1__)",
          "hd_path": "HD Path",
          "hd_path_key": "HD Path key",
          "byron_legacy_hd_path_desc":
              "Please set up the HD Path and HD Path key, or disable manual configuration to generate them automatically from the key.",
          "invalid_byron_legacy_hd_path_key":
              "Invalid byron legacy HD path key",
          "byron_legacy_hd_wallet_length_desc":
              "Byron Legacy only supports the first two HD wallet indexes, such as m/1/2.",
          "byron_legacy_hd_path_key_desc":
              "Invalid HD Path key bytes. Please provide the HD path key in hexadecimal format.",
          "byron_legacy_hd_path_key_length_desc":
              "The HD path key should be 32 bytes in length.",
          "byron_legacy_hd_path_key_desc2":
              "Please provide the HD path key in hexadecimal format.",
          "manually_set_hd_path": "Manually set HD path details.",
          "byron_legacy_hd_path_generate_from_master_key_desc":
              "Do not toggle on for generating from master key.",
          "wallet_type": "Wallet type",
          "types_of_wallet_contracts": "Types of Wallet Contracts",
          "ton_wallet_contract_desc":
              "Wallet Contracts on TON (V1, V2, V3, V4, V5) are smart contracts designed to manage cryptocurrency transactions with increasing levels of security, functionality, and customization.",
          "sub_wallet_id_validator":
              "The sub wallet id must be a value between 0 and ___1__.",
          "sub_wallet_id": "Sub wallet id",
          "sub_wallet_id_desc":
              "which allows you to create multiple wallets using the same public key (so you can have only one seed phrase and lots of wallets)",
          "ton_mnemonic_feature_desc":
              "We are using standard BIP-39 seed generation for the TON network. To use the Ton Mnemonic feature, generate a private key from your mnemonic in the settings (import key feature).",
          "ton_mnemonic": "Ton Mnemonic",
          "generate_ton_private_key":
              "Generate a private key from your TON mnemonic.",
          "network_settings": "Network settings",
          "ton_mnemonic_desc":
              "The TON network uses its algorithm to generate private keys from mnemonics. You can create or import a TON mnemonic, convert it to a private key, and import it into your wallet.",

          "external_mnemonic_desc2":
              "We don't store your mnemonic or mnemonic password in the wallet. Instead, we generate a private key for you to import into the wallet if desired",
          "mnemonic_password": "Mnemonic password.",
          "mnemonic_password_desc":
              "If your mnemonic has a password or you want to generate a mnemonic with a password, enable it.",
          "password_empty_validator": "Password must not be empty.",
          "create_import_mnemonic": "Create/Import Mnemonic",
          "choose_an_action": "Choose an Action",
          "enter_mnemonic_desc3":
              "Please enter your BIP39 mnemonic phrase below, consisting of 8 to 48 words, separated by spaces.",
          "generate_private_key": "Generate private key",
          "invalid_bip39_mnemonic_words": "Invalid BIP39 mnemonic words.",
          "validating_mnemonic": "Validating mnemonic",
          "validate_ton_mnemonic": "Validate Ton mnemonic",
          "validate_ton_mnemonic_desc":
              "Ensure the entered mnemonic is a valid TON mnemonic.",
          "generating_private_key": "Generating private key. Please wait.",
          "import_to_wallet": "Import to wallet.",
          "wrong_network_key_error":
              "The private key is not associated with the ___1__ network",
          "generate_ton_mnemonic": "Generate Ton mnemonic",
          "ton_mnemonic_words_desc":
              "You can generate a mnemonic phrase with 8 to 48 words, though most wallets support only 24-word mnemonics.",
          "ton_mnemonic_words_length_validator":
              "The TON mnemonic supports 8 to 48 words.",
          "generating_mnemonic": "Generating mnemonic. Please wait.",
          "transaction_is_not_ready": "Transaction is not ready.",
          "estimating_fee_please_wait": "Estimating fee. Please wait.",
          "bounce": "Bounce",
          "ton_bounce_desc":
              "Bounce: If the destination smart contract doesn't exist or throws an unhandled exception while processing the message, it will be bounced back with the remaining original value, minus transfer and gas fees.",
          "ton_bounce_desc2":
              "If the destination contract is missing or errors, the message returns with remaining value, minus fees.",
          "message_body": "Message body",
          "comment": "Comment",
          "binary_comment": "Binary comment",
          "cell": "Cell",
          "body_message_desc":
              "The body of the message can be embedded into the message itself, or be stored in a separate cell referred to from the message",
          "type_of_message_body": "Type of message body",
          "choose_the_type": "Choose the type",
          "ton_message_body_comment_validator":
              "Please enter a comment for your message body.",
          "invalid_hex_bytes_string": "Invalid hexadecimal byte string.",
          "ton_invalid_cell_string_data":
              "Invalid cell data. Please enter a valid string in base64 or hexadecimal format.",
          "enter_binary_message_as_hex":
              "Please enter the binary message in hexadecimal format.",
          "enter_comment_as_string_or_hex":
              "Please enter the comment in plain text or hexadecimal format.",
          "enter_cell_as_hex_or_base64":
              "Please enter a valid string in base64 or hexadecimal format.",
          "update_messsage": "Update message.",
          "internal_message_settings": "Internal message settings",
          "message_options": "Message options",
          "ton_bounceable_vs_non_bounceable":
              "Bounceable vs Non-Bounceable Addresses",
          "ton_address_type_desc":
              "We recommend using a stable, non-bounceable address for the wallet contract.",
          "bouncable": "Bounceable",
          "jettons": "Jettons",
          "no_jettons_found": "No jettons found in the account.",
          "import_jettons": "Import Jettons",
          "data_verification_failed": "Data verification failed.",
          "unable_to_retrieve_token_metadata":
              "Unable to retrieve token metadata.",
          "import_token_alert": "Warning: Fake Token Scam Alert",
          "import_token_desc":
              "Be cautious of fake token scams. Importing unverified tokens can compromise your blockchain account security. Always verify token authenticity to protect your digital assets.",
          "token_decimals_desc":
              "We can't detect token metadata. Token decimals have been set to zero.",
          "select_token": "Select Token",
          "jetton_transfer": "Jetton transfer",
          "select_jetton_desc": "Please select the jetton you want to transfer",
          "jetton_amount": "Jetton amount",
          "forward_amount": "Forward Ton amount",
          "ton_forward_amount_desc":
              "the amount of Ton to be sent to the destination address.",
          "total_amount": "Total amount",
          "setup_forward_amount": "Setup forward amount",
          "setup_jetton_amount": "Setup jetton amount",
          "setup_total_amount": "Setup total amount",
          "jetton_total_amount_desc":
              "Amount of transferred jettons in elementary units.",
          "the_jetton_amount_is_unspecified":
              "The jetton amount is unspecified.",
          "ton_total_amount_validator":
              "The total amount must be greater than the forward amount. (Forward amount + message fee = total amount)",
          "ton_jetton_transfer_desc":
              "Please make sure you understand the jetton transfer fields. If not, read this link before making a transaction.",
          "ton_total_amount_desc_2":
              "If the Forward amount is zero, the total minus the fee will be transferred to the destination. Otherwise, the total amount minus the Message fees and Forward fees will be returned to your account.",
          "remove_recipient": "Remove recipient",
          "remove_recipient_desc": "Remove the recipient?",
          "ton_transaction_error_desc": "Internal transaction failed: ___1__ .",
          "unknown_error": "Unknown error",
          "some_action_failed":
              "Some actions failed during the processing:  ___1__ .",
          "other_fees": "Other fees",
          "transaction_fees": "Transaction fees",
          "ton_transaction_fee_desc":
              "This is an estimated minimum fee and may not be exact.",
          "ton_transaction_fee_desc2":
              "Internal fees apply for smart contracts such as Jetton, NFS, etc.",
          "total_fees": "Total fees",
          "estimate_fee_error_desc":
              "Unable to process the estimate fee. Please ensure you have sufficient Balance to complete the transaction.",
          "arbitrary_request_number": "Arbitrary request number.",
          "query_id": "Query ID",
          "jetton_transfer_fields": "Jetton transfer fields.",
          "ton_query_id_validator": "Invalid Query Id",
          "jetton_destination_address_desc":
              "For transferring Jetton ensure the destination address is the owner of the Jetton, not the Jetton wallet address.",
          "url_does_not_exists": "URL does not exist.",
          "featuees": "Features",
          "ripple_key_conversion": "Ripple key conversion",
          "ripple_key_conversion_desc":
              "Generate private key from ripple seed or enteropy",
          "secret_key_conversion_desc2":
              "You can convert your specific blockchain key or recovery phrase into a private key, which can then be imported into a wallet to manage addresses, transactions, and other network operations.",
          "ripple_key": "Ripple key",
          "select_ripple_seed_or_entropy": "Please enter your Ripple key.",
          "example_s": "Example: ___1__ .",
          "ripple_seed_entropy_validator":
              "Please enter a valid ripple ___1__ .",
          "seed": "Seed",
          "entropy": "Entropy",
          "inidicate_type_of_ripple_key":
              "Indicate the type of your ripple key.",
          "ripple_key_type": "Ripple key type",
          "choose_key_algorithm_desc":
              "Which type of algorithm would you like to use to create the private key?",
          "import_private_key_desc":
              "Your private key has been successfully generated. click the 'Import to Wallet' button which can then be imported into a wallet to manage addresses, transactions, and other network operations.",
          "coin_type": "Coin type",
          "choose_key_coin_desc": "To which coin is your key-related?",
          "invalid_key": "The provided key is invalid.",
          "enter_extended_key_desc":
              "Please enter your extended key in Base58 format.",
          "enter_wif_key_desc": "Please enter your WIF key in Base58 format.",
          "enter_private_key_desc":
              "Please enter your private key in Hexadecimal format.",
          // "restore_from_backup": "Restore from backup.",
          "restore_backup_desc":
              "Restore your mnemonic, private key, or other information you generated with the app backup option.",
          "restore_encrypted_backup": "Restore encrypted backup",
          "restoring_backup_please_wait": "Restoring backup. please wait. ",
          "show_content": "Show content.",
          "backup_restored_desc": "Your backup has been successfully restored.",
          "qr_code": "QR Barcode",
          "submit": "Submit",
          "live_price": "Live price",
          "coin_gecko_desc":
              "We can also provide live price updates for your token balance using CoinGecko. To enable this, locate your token on CoinGecko, find the API ID on the token's page, and select the appropriate name here.",
          "retrieving_token_information": "Retrieving token. Please wait.",
          "coingecko_id": "CoingeckoId",
          "api_id": "API ID",
          "coingecko_api_id_validator":
              "The API ID must be at least 2 characters long",
          "retrieving_token_price": "Retrieving token price. Please wait.",
          "updating_token": "Updating token. Please wait. ",
          "token_updated_successfully":
              "The token has been successfully updated.",
          "invalid_api_id": "Invalid API ID.",
          "token_decimals": "Token decimals",
          "token_decimals_validator":
              "The number of token decimal places must be between 0 and 255.",
          "change_token_decimal_desc":
              "Warning: Changing the token decimal places can significantly impact token balances and transactions. For example, changing from 9 to 10 decimal places may cause balance discrepancies and potential loss of funds. Proceed with caution and ensure you understand the consequences before making this change. The number of decimal places must be between 0 and 255.",
          "change_token_decimal_desc3":
              "Warning: Changing token decimal places can significantly impact balances and transactions. Ensure the decimal setting is accurate before proceeding.",
          "change_decimals": "Change decimals",
          "change_token_decimal_desc2":
              "The token decimal places will be changed from ___1__ to ___2__ .",
          "customize_key_derivation": "Customize derivation",
          "ada_customize_derivation_desc":
              "Choose seed, master key, and address generation type",
          "choose_mnemonic_desc":
              "Choose between 12, 15, 18, 21, or 24 words to generate a mnemonic.",
          "choose_mnemonic_lang_desc":
              "Choose your mnemonic language. We recommend using English as it is more universal.",
          "wallet_already_exists": "Wallet already exists.",
          "unlock_access_desc":
              "This feature only works on an unlocked wallet. Please enter your wallet password to continue.",
          "unlock_wallet": "Unlock Wallet",
          "incomplete_wallet_setup": "Wallet setup is incomplete",
          "switch_wallets": "Switch wallets",
          "wallet_does_not_exists": "Wallet does not exists.",
          "wallet_settings": "Wallet settings",
          "wallet_settings_desc":
              "Modify your wallet name, set password requirements, and choose it as the default app wallet.",
          "wallet_name": "Wallet name",
          "wallet_identifier_name": "Wallet identifier name",
          "password_requirement": "Password requirement",
          "wallet_password_requirement_desc":
              "A password is required to access the wallet.",
          "wallet_password_requirement_desc2":
              "A password is required to access the wallet. When password protection is disabled, all features except actions requiring a password will remain accessible. For those actions, the wallet will prompt for the password, and the wallet will be unlocked upon entry.",
          "wallet_locktime_desc":
              "The wallet will be locked after this time period for wallets that require a password. otherwise, the wallet will be in read-only mode.",
          "default_wallet": "Default wallet",
          "default_wallet_desc":
              "This wallet loads first among multiple wallets.",
          "wallet_name_validator":
              "Wallet name must be between 3 and 15 characters long.",
          "wallet_name_validator2": "Wallet name already exists.",
          "wallet_name_exists": "A wallet with this name already exists.",
          "generate_keystore": "Generate keystore",
          "backup_extended_key": "Backup extended key",
          "backup_wif": "Backup WIF",
          "generate_keystore_desc": "Generate Keystore V3 from private key.",
          "verification_backup_review": "Backup Verification Review",
          "verification_backup_desc":
              "Please review the backup verification before importing it to your wallet.",
          "backup_verification_success_desc":
              "Backup successfully passed checksum verification",
          "backup_verification_failed_desc":
              "Verification failed. Please recheck your passphrase.",
          "unsuported_legacy_backup": "Unsupported: Legacy backup",
          "verified_accounts": "Verified accounts",
          "total_accounts": "Total accounts",
          "decrypting_backup_please_wait":
              "Decrypting your backup. This process may take up to 10 minutes.",
          "generating_wallet_please_wait": "Generating wallet. Please wait.",
          "verifying_backup_please_wait": "Verifying backup. Please wait",
          "unverified_account": "Unverified Account",
          "unverified_account_desc":
              "The verification of these accounts failed, so they cannot be imported into your wallet.",
          "switching_wallet": "Switching wallet. Please wait.",
          "signing_auth_validator":
              "This account is not authorized for signing.",
          "unsuported_key": "Unsupported key",
          "backup_key_type_desc":
              "Which type of key would you like to back up?",
          "use_key_store_backup_desc":
              "A keystore backup can be unlocked by any compliant Web3 wallet, such as TronLink, MetaMask, and others.",
          "invalid_backup_type_desc":
              "Invalid backup type. Expected a ___1__ but received an ___2__.",
          "mnemonic": "Mnemonic",
          "keystore": "Keystore",
          "legacy_backup": "Legacy backup?",
          "ton_wallet_validator_desc":
              "Wallet contract v1 only support on message per transaction.",
          "qr_code_scanner": "Barcode scanner",
          "getting_scanner_ready": "Getting scanner ready, please wait.",
          "ripple_address_validator_desc":
              "Please enter the Ripple address tag or disable this feature.",
          "insert_address_tag": "Enter the address tag",
          "ripple_xaddress_feature": "X-address feature.",
          "ripple_xaddress_tag_validator":
              "The provided tag does not match the x-address tag.",
          "page_closed": "Page closed.",
          "retrive_barcode_data": "Retrieve barcode data",
          "coin_not_found":
              "Unable to locate a proposal with the given coin name.",
          "keypair_type": "Keypair type",
          "choose_key_algorithm_desc2":
              "Which type of algorithm would you like to use to create the address?",
          "disable_standard_derivation_desc":
              "You can manually setup a derivation path.",
          "custom_path_derivation_desc":
              "Ensure you remember the chosen path for custom derivation. Forgetting it could result in losing your funds.",
          "substrate_key_derivation_desc":
              "The derivation path in Substrate is used to securely generate key pairs from a master seed. The path is specified using a hierarchical format with slashes (/), and it can include both hard and soft derivation segments.",
          "substrate_key_derivation_desc2":
              "Double Slash (//) for Hard Derivation: This indicates a hard derivation step, where the derived key is cryptographically isolated from the parent key. For example, //Account denotes a hard derivation step to derive a key named 'Account' from the master key.",
          "substrate_key_derivation_desc3":
              "Single Slash (/) for Soft Derivation: This indicates a soft derivation step, allowing public key derivation without needing the private key. For example, /0 denotes a soft derivation step to derive the first key under the 'Account key.",
          "substrate_customize_derivation_desc":
              "Using SR25519 key derivation.",
          "noce_connection_field":
              "Connection to the network node was unsuccessful.",
          "connection_attempt_unsuccessful": "Connection attempt unsuccessful.",
          "node_connectiong_please_wait":
              "Connecting to the node. Please wait.",
          "up_to_4_message_single_transaction":
              "Up to 4 messages can be added in a single transaction.",
          "base_fee": "Base fee",
          "len_fee": "Length fee",
          "weight_fee": "Weight fee",
          "tip": "Tip",
          "barcode_scanning_terminated":
              "Barcode scanning has been terminated.",
          "provider": "Provider",
          "account_options": "Account options",
          "node_connection_desc":
              "All actions are disabled until connection is established.",
          "testnet_price_desc":
              "You are on the testnet network, and prices are not valid.",
          "testnet": "Testnet",
          "coin_type_desc":
              "Coin type must be a positive number between 0 and 4294967295.",
          "slip_44_desc":
              "BIP-0044 defines a logical hierarchy for deterministic wallets. Level 2 of the hierarchy describes a coin type in use.",
          "barcode_scanner_not_supported_browser":
              "Barcode scanner is not supported in your browser.",
          "unknown_requester": "Unknown requester.",
          "eth_personal_sign_desc":
              "The message should be signed using 'personal_sign' method.",
          "message": "Message",
          "sign_message": "Sign message",
          "eth_sign_typed_data_desc":
              "The message should be signed using '___1__' method.",
          "version": "Version",
          "primary_type": "Primary type",
          "transaction_retrieval_requirment":
              "Transaction Retrieval Requirements",
          "eip_1559": "EIP-1559",
          "eip_1559_desc":
              "Some networks do not support this feature, resulting in `eth_feeHistory` retrieving inaccurate data. If you are unsure, please disable this option and use the legacy gas price instead.",
          "decryption_failed": "Decryption process failed.",
          "web3_accounts_permission_desc":
              "Please select the accounts you wish to grant app permissions to.",
          "initializing_requirements":
              "Initializing requirements. Please wait.",
          "request_completed_success": "Request completed successfully.",
          "ethereum_networks": "Ethereum networks.",
          "chain_permission_desc":
              "Switch to each network and grant the necessary permissions.",
          "import_providers": "Import network providers.",
          "network_providers_has_been_updated":
              "Network providers has been updated.",
          "ethereum_rpc_url_desc":
              "The RPC URL must be associated with the Ethereum network that has the chain ID ___1__ (___2__).",
          "coin_type_desc2":
              "The coin type is always determined by a hardened index. You can also set up a custom derivation on the setup address page.",
          "update_provider_desc":
              "Update, remove, or add a new provider to the Ethereum network.",
          "authenticated": "Authentication",
          "add_provider_authenticated": "Add authentication to your provider.",
          "authenticated_type": "Authentication Type",
          "authenticated_key": "Authentication key",
          "authenticated_value": "Authentication value",
          "example_value": "Example: ___1__",
          "authenticated_key_validator":
              "Please enter at least one character for the authentication key.",
          "authenticated_value_validator":
              "Please enter at least one character for the authentication value.",
          "value_is_to_large": "The provided value is too large.",
          "access_in_web3_apps": "Access in Web3 applications",
          "access_provider_in_web3_apps_desc":
              "Allow Web3 applications to use this provider for blockchain queries.",
          "update_providers": "Update providers.",
          "address_type": "Address type",
          "processing_request": "Processing request, please wait.",
          "protect_wallet": "Protect wallet",
          "required_password_to_sign_transaction":
              "A password is required to sign the transaction.",
          "wallet_is_not_available": "The wallet is not available",
          "new_tab": "New tab",
          "history": "History",
          "bookmark": "Bookmark",
          "bookmarks": "Bookmarks",
          "remove_all": "Remove all",
          "histories": "Histories",
          "file_does_not_exist": "File does not exists.",
          "web3_request_rejected_desc":
              "Request has been canceled or the client does not exist.",
          "active_chain": "Active chain",
          "web3_switch_chain_desc":
              "A request has been made for this chain. Clients can always request to switch chains.",
          "web_application_not_valid":
              "Invalid web application. The application or host was not found or is not valid.",
          "updating_permission": "Updating permission. please wait.",
          "enter_wallet_password_request":
              "Kindly enter your wallet password to proceed with the request.",
          "application_name": "Application name",
          "edit_application_name_desc":
              "You can edit the program name for easier identification.",
          "application_name_validator":
              "The application name must be at least 3 characters long.",
          "web3_activation": "Web3 activation",
          "web3_activation_desc":
              "You can also enable or disable the Web3 feature for this application. (Applying this change requires reloading the page.)",
          "eth_subscribe_websocket_requirment":
              "`eth_subscribe` method only works with the WebSocket protocol.",
          "switch_chain": "Switch ___1__ chain",
          "switch_chain_desc":
              "The client has sent a request to switch the chain.",
          "current_chain": "Current chain",
          "requested_chain": "Requested chain",
          "agree": "Agree",
          "unknown": "Unknown",
          "creation_contract": "Creation Contract",
          "method_name": "Method name",
          "method_selector": "Method selector",
          "transfer_amount": "Transfer amount",
          "transaction_type": "Transaction type",
          "smart_contract": "Smart contract",
          "network_does_not_exist": "Network does not exists.",
          "web3_request_account_desc":
              "The request should be processed using this account.",
          "client": "Client",
          "web3_client_desc": "This request was generated by the application.",
          "web3_request_chain_desc":
              "The request must be processed using this chain.",
          "web3_success_response_desc":
              "The response has been successfully generated.",
          "web3_sending_response_to_client":
              "Sending the response to the client. Please wait.",
          "web3_sending_response_error_desc":
              "The client did not receive the response as it was closed during transmission.",
          "web3_response_successfully_desc":
              "The client has successfully received the response.",
          "verifying_contract": "Verifying Contract",
          "remove_network": "Remove network",
          "remove_network_desc2":
              "Are you sure you want to remove the network from the wallet?",
          "remove_network_desc":
              "All accounts, contacts, and any other chain-related data will be permanently removed from the wallet. This action cannot be undone.",
          "removing_chain_please_wait": "Removing chain. please wait.",
          "chain_removed_desc":
              "The client has successfully removed from wallet.",
          "contract": "Contract",
          "transfer_token_desc": "The amount of token will be transferred.",
          "transaction_data": "Transaction data",
          "tron_contract": "Tron contract",
          "tron_transaction_type": "Tron transaction type",
          "tron_transaction_destination_desc":
              "Transaction destination, such as TRX receiver, token recipient, or smart contract.",
          "tron_total_spent_desc": "Total TRX to be spent in this transaction.",
          "update_client_permission_desc":
              "Please select the network where you want to update the client's permissions",
          "contract_information": "Contract information",
          "information": "Information",
          "transaction_id": "Transaction ID",
          "tron_call_token": "Call TRC-10 token",
          "tron_call_token_desc": "Token transfer during contract interaction",
          "tron_call_token_value_desc":
              "The amount of a TRC-10 token during contract interaction",
          "tron_networks": "Tron networks.",
          "solana_networks": "Solana networks.",
          "default_address": "Default address",
          "default_address_desc":
              "Enabling multiple account permissions allows Web3 apps to automatically detect the default address.",
          "tron_owner_contract": "Owner address of contract",
          "tron_owner_contract_desc":
              "in multi-sig transaction, this may be different from the account address",
          "insufficient_balance": "Insufficient balance",
          "insufficient_balance_desc":
              "The transaction might have failed due to insufficient balance. Do you still want to proceed?",
          "instructions": "Instructions",
          "simulate_transaction": "Simulate transaction",
          "transaction_simulation_failed": "Transaction simulation failed.",
          "transaction_simulation_success": "Transaction simulation success.",
          "transaction_simulate_please_wait":
              "Simulating transaction. Please wait.",
          "transaction_simulation_failed_retry":
              "Transaction simulation failed. Tap to retry",
          "transactions": "Transactions",
          "multiple_transaction_desc":
              "Multiple transaction requests detected. Please review each transaction before submitting.",
          "signing_transaction_please_wait":
              "Signing transaction. Please wait.",
          "send_transactions": "Send transactions",
          "sign_transactions": "Sign transactions",
          "transaction_signed": "Transaction has been signed.",
          "total_transaction_fee": "Total transaction fee",
          "fee_estimate_failed": "Fee estimation failed",
          "submit_transaction": "Submit transaction.",
          "simulation_failed_continue_desc":
              "Some transaction simulations failed. Do you want to continue?",
          "simulation_process_continue_desc":
              "Some transaction simulations are in process. Do you want to continue?",
          "total_transaction_const": "Total transaction cost",
          "simulation_are_not_ready":
              "Some transaction simulations are not complete.",
          "web3_permission_error_desc":
              "Insufficient permissions to complete this request.",
          "change_balance": "Change balance",
          "solana_change_balance_desc":
              "Remaining balance after transaction submission.",
          "solana_change_balance_desc2":
              "In a multiple transaction request with the same owner, the balance change applies only to this instruction and does not affect previous or subsequent simulations.",
          "replace_recent_block_hash": "Replace recent block hash",
          "replace_block_hash_desc":
              "this feature only effect transactions with one signature requirement",
          "message_amount": "Message amount",
          "amount_of_ton_message": "Amount of TON Linked to the Message",
          "transaction_messages": "Transaction messages",
          "ton_tx_message_details": "TON transaction message details.",
          "message_payload": "Message payload",
          "jetton_info": "Jetton info",
          "jetton_transfer_amount": "Jetton transfer amount",
          "content_of_payload": "The content of payload.",
          "payload_deserialize_failed":
              "Failed to deserialize and access the payload content.",
          "unknown_payload_desc":
              "Unknown payload detected. Some payloads may have full access to contracts. Only accept Web3 transactions from trusted sites.",
          "deploy_contract": "Deploy contract",
          "initialization_state": "Initialization state",
          "encrypted_message": "Encrypted message",
          "use_wallet_id": "Use Wallet id",
          "ton_v5_wallet_desc":
              "The Wallet ID may resemble a Sub Wallet ID, but it follows a different serialization concept. To understand this better, you should read about version 5.",
          "wallet_id": "Wallet ID",
          "unknow_jetton_owner": "Unknown Jetton Owner",
          "switch_permission_chain_desc":
              "To switch chains, please select the desired chain and update the permissions accordingly.",
          "writable": "Writable",
          "read_only": "Read only",
          "sign_message_private_key":
              "The message should be signed using account private key.",
          "sign_message_private_key_desc":
              "Sign Message: Warning! The message you're about to sign could contain anything, including transactions. We cannot validate the contents of the message. Only proceed if you fully trust the request. Otherwise, you may risk losing your funds.",
          "signing_request": "Signing request",
          "eth_sendTransaction": "Send Transaction",
          "personal_sign": "Personal Sign",
          "eth_signTypedData": "Sign Typed Data",
          "eth_signTypedData_v3": "Sign Typed Data V3",
          "eth_signTypedData_v4": "Sign Typed Data V4",
          "eth_requestAccounts": "Request Accounts",
          "wallet_addEthereumChain": "Add Ethereum Chain",
          "wallet_switchEthereumChain": "Switch Ethereum Chain",
          "wallet_disconnect": "Disconnect",
          "solana_sendTransaction": "Send Transaction",
          "solana_sendAllTransactions": "Send All Transactions",
          "solana_signAllTransactions": "Sign All Transactions",
          "solana_signMessage": "Sign Message",
          "solana_signTransaction": "Sign Transaction",
          "solana_requestAccounts": "Request Accounts",
          "ton_signMessage": "Sign Message",
          "ton_sendTransaction": "Send Transaction",
          "ton_signTransaction": "Sign Transaction",
          "ton_requestAccounts": "Request Accounts",
          "tron_signTransaction": "Sign Transaction",
          "tron_signMessageV2": "Sign Message",
          "tron_requestAccounts": "Request Accounts",
          "muxed_address": "Muxed address",
          "pubkey_address": "Public key address",
          "stellar_muxed_address_desc":
              "a new type of Stellar account that makes it easy to map a single Stellar address to multiple users.",
          "id": "Id",
          "enter_stellar_muxed_id_desc":
              "The Id must be a value between 0 and 2^64-1.",
          "uint64_validator":
              "The ___1__ must be a value between 0 and 2^64-1.",
          "recipient_account_active": "The recipient account is active.",
          "recipient_account_inactive": "The recipient account is inactive.",
          "retrieve_account_activity_failed":
              "Failed to retrieve account activity.",
          "32bytes_hex_validator_desc":
              "The value must be a valid 32-byte hexadecimal string.",
          "text_max_validator": "Text must be ___1__ characters max.",
          "add_stellar_memo_type_desc":
              "Please choose the type of Stellar memo to add to the transaction.",
          "stellar_memo_text_desc":
              "Memo can be up to 28 characters. Note: the text is deserialized using UTF-8 encoding.",
          "stellar_memo": "Stellar transaction memo",
          "stellar_memo_desc":
              "Stellar offers different memo types for transactions, each designed for a specific purpose.",
          "stellar_memo_desc2":
              "If no memo is needed, select '___1__' and use '___2__' to confirm.",
          "stellar": "Stellar",
          "stellar_starting_balance_desc":
              "The starting balance for a non-active account must reach ___1__ XLM.",
          "submit_transaction_error": "Transaction submission error. ___1__",
          "fee_zero_validator_desc": "Transaction fee must not be zero.",
          "add_operation": "Add Operation",
          "tap_to_add_new_operation":
              "Tap to add a new operation to the transaction",
          "change_trust": "Change trust",
          "asset_type": "Asset type",
          "stellar_invalid_asset4_validator":
              "Invalid asset code: must contain 1 to 4 alphanumeric characters (a-z, A-Z, 0-9).",
          "stellar_invalid_asset12_validator":
              "Invalid asset code: must contain 5 to 12 alphanumeric characters (a-z, A-Z, 0-9).",
          "asset_issue_address_validator":
              "Cannot use the contract address as the asset issuer address.",
          "setup_asset": "Setup asset",
          "asset": "Asset",
          "pool_id": "Pool ID",
          "stellar_liquidity_pool_id_desc":
              "Stellar Liquidity Pool ID: A unique 32-byte hash representing the liquidity pool asset, used for facilitating decentralized trading between two assets on the Stellar network.",
          "tap_to_select_or_create_asset": "Tap to select or create an asset",
          "pick_an_asset": "Pick an asset",
          "change_trust_desc":
              "The Stellar changeTrust operation lets an account establish, modify, or remove trust lines for an asset. This is necessary before holding or transacting with non-native assets like tokens issued by other accounts.",
          "modify_trust_line_desc":
              "Please select an asset to modify the trust line.",
          "change_trust_limit":
              "the maximum amount of an asset that an account is willing to trust",
          "limit": "Limit",
          "setup_amount": "Setup amount",
          "stellar_change_trust_limit_zero_desc":
              "A limit of zero means the trust line is removed.",
          "payment": "Payment",
          "stellar_payment_desc":
              "The Stellar payment operation sends a specified amount of an asset from one account to another, supporting both XLM and tokens.",
          "select_stellar_payment_assets_desc":
              "Please select the asset you want to transfer.",
          "stellar_new_token_created":
              "Token not found in your account. A new token will be created.",
          "create_assets": "Create an asset.",
          "remove_operation_close_page_desc":
              "For removing the operation please close the page.",
          "update_operation": "Update operation",
          "send_asset": "Send asset",
          "stellar_path_receive_send_asset_desc":
              "The asset being sent by the sender. It is the currency or token that will be deducted from the sender's account and converted into the recipient's desired asset.",
          "stellar_path_receive_destination_desc":
              "The account that will receive the payment. This is the recipient's address, who will receive the destination asset.",
          "send_max": "Send max",
          "stellar_path_receive_send_max_desc":
              "The maximum amount of the Send asset that the sender is willing to pay. The actual amount sent may be less, but it will never exceed this limit. If the network can't convert the Send asset into the destination asset within this maximum, the operation will fail.",
          "destination_asset": "Destination asset",
          "stellar_path_receive_dest_asset_desc":
              "The asset that the recipient will receive. This is the currency or token that the operation aims to deliver to the destination account, after any necessary conversions from the send asset",
          "destination_amount": "Destination amount",
          "stellar_path_receive_dest_amount_desc":
              "The exact amount of destination asset that the recipient will receive. This value is guaranteed by the operation, meaning the recipient will always receive this specified amount if the transaction succeeds",
          "stellar_path_payment_strict_receive_desc":
              "This operation allows the sender to specify the exact amount the recipient will receive, while the network calculates the amount of the sending asset needed, up to a specified maximum. If the conversion cannot be completed within the limit, the operation fails",
          "stellar_path_payment_strict_receive": "Path Payment Strict Receive",
          "stellar_path_receive_path_desc":
              "A list of intermediate assets used for converting the send_asset to the dest_asset. These assets serve as hops in the payment path, allowing the network to find the best conversion route if no direct trade exists between the two assets. This field is optional.",
          "path_already_exist": "The path already exists.",
          "stellar_path_send_send_asset_desc":
              "The asset being sent from the sender's account. It is the currency or token that will be deducted from the sender’s balance and converted into the desired asset for the recipient.",
          "stellar_path_receive_send_amount_desc":
              "The exact amount of the sendAsset that the sender will transfer. This amount is fixed, and the operation will convert it into the recipient's desired asset, regardless of how much the recipient ends up receiving.",
          "send_amount": "Send amount",
          "stellar_path_send_destination_desc":
              "The account that will receive the payment. This field specifies the recipient's address, indicating where the converted asset will be sent once the transaction is completed.",
          "stellar_path_send_dest_asset_desc":
              "The asset that the recipient will receive. This specifies the currency or token that the operation aims to deliver to the destination account after converting from the sendAsset",
          "stellar_path_send_dest_min_desc":
              "The minimum amount of destination asset that the recipient must receive. If the conversion from send asset does not result in at least this specified amount, the operation will fail to ensure that the recipient is adequately compensated.",
          "stellar_path_send_path_desc":
              "A list of intermediate assets used to facilitate the conversion from sendAsset to destAsset. This optional field allows the network to find the best conversion route through multiple assets if a direct trade between the two assets is not available.",
          "minimum_destination_amount": "Minimum Destination Amount",
          "stellar_path_payment_strict_send": "Path Payment Strict Send",
          "stellar_path_payment_strict_send_desc":
              "This operation allows the sender to specify an exact amount of a sending asset to convert into a desired destination asset. The operation guarantees a minimum amount of the destination asset to be received by the recipient, and if the conversion cannot be completed to meet this requirement, the operation will fail.",
          "create_an_account": "Create an account.",
          "stellar_create_account_operation_desc":
              "This operation is used to create a new Stellar account by specifying the account's destination and funding it with an initial balance. It requires the source account to have sufficient funds to cover the minimum balance requirement and transaction fees. Once executed, the new account becomes active on the Stellar network.",
          "starting_balance": "Starting balance",
          "stellar_create_account_starting_balance_desc":
              "The initial amount of Lumens (XLM) to fund the newly created account. This value must meet the minimum balance requirement set by the Stellar network, ensuring that the account remains active.",
          "transaction_operation": "Transaction operation",
          "stellar_transaction_operation_desc":
              "Please choose the operation you would like to configure for the transaction.",
          "operation_type": "Operation type",
          "stellar_account_inactive_desc":
              "The destination account is inactive. Be sure to include a Create Account operation; otherwise, the transaction will fail.",
          "assets_not_found_in_account":
              "We couldn't detect any assets in your account",
          "account_is_active": "the account is already active.",
          "time_bound": "Time bound (Maximum time)",
          "stellar_time_bound_desc":
              "Specifies a time window for when a Stellar transaction is valid. Without it, the transaction never expires.",
          "stellar_time_bound_auto_desc":
              "The timebound (maximum time) will be set to 1 minute before the transaction is signed.",
          "stellar_time_bound_none_desc":
              "The time bound for the transaction will not be set.",
          "time_bound_type": "Type of timebound",
          "expiration_time": "Expiration time",
          "stellar_time_bound_max_time_desc":
              "The latest ledger time by which the transaction must be included. If the transaction is not confirmed by this time, it will be rejected.",
          "tap_to_choose_data": "Tap to choose a date.",
          "setup_time_bound": "Setup time bound",
          "time_is_insufficient": "The entered time is insufficient.",
          "manual": "Manual",
          "auto": "Auto",
          "timebound_expired": "The timebound has expired.",
          "transaction_empty_operation_validator_desc":
              "at least one operation is required.",
          "selling": "Selling",
          "stellar_manage_sell_offer_selling":
              "The asset you are offering to sell in exchange for another asset.",
          "stellar_manage_sell_offer_amount":
              "The total quantity of the selling asset that you want to offer in the exchange.",
          "buying": "Buying",
          "stellar_manage_sell_offer_buying":
              "The asset you want to receive in exchange for the asset you're selling.",
          "price": "Price",
          "stellar_manage_sell_offer_price":
              "The rate at which you are willing to sell the selling asset in terms of the buying asset, expressed as the amount of the buying asset you receive for each unit of the selling asset.",
          "offer_id": "Offer id",
          "stellar_manage_sell_offer_offer_id":
              "A unique identifier for the offer. An OfferID of 0 indicates that a new offer will be created, while a non-zero OfferID indicates that an existing offer will be updated.",
          "setup_price": "Setup price",
          "tap_to_setup_price": "Tap to setup price",
          "exchange_entred_price_desc":
              "You will receive ___1__ for each ___2__.",
          "exchange_entred_price_buy_desc":
              "You will pay ___1__ for each ___2__.",
          "setup_offer_id": "Setup offer id",
          "different_selling_from_buying_validator_desc":
              "The buying asset must be different from the selling asset.",
          "stellar_manage_sell_offer": "Manage sell offer",
          "stellar_manage_sell_offer_desc":
              "is an operation in the Stellar network that allows users to create, update, or delete a sell offer for a specific asset. This operation is primarily used in the context of trading assets on the Stellar decentralized exchange (DEX).",
          "stellar_manage_buy_offer_selling":
              "The asset you are offering to sell in exchange for another asset.",
          "buy_amount": "Buy amount",
          "stellar_manage_buy_offer_buy_amount":
              "The amount of the asset you wish to purchase.",
          "stellar_manage_buy_offer_buying":
              "The asset you want to acquire in exchange for the selling asset.",
          "stellar_manage_buy_offer_price":
              "The exchange rate at which you are willing to buy the asset, expressed as a fraction.",
          "stellar_manage_buy_offer": "Manage buy offer",
          "stellar_manage_buy_offer_desc":
              "is an operation in Stellar that allows users to create, update, or delete a buy order for an asset, specifying the asset to acquire, the selling asset, the amount to buy, and the price.",
          "stellar_networks": "Stellar networks",
          "stellar_web3_signing_operations_desc":
              "Please ensure you fully understand each operation before signing the transaction.",
          "transaction_version": "Transaction version",
          "version_1": "Version 1",
          "fee_bump_transaction": "Fee bump transaction",
          "stellar_requestAccounts": "Request Accounts",
          "stellar_signTransaction": "Sign Transaction",
          "stellar_signMessage": "Sign Message",
          "stellar_sendTransaction": "Send transaction",
          "create_passive_sell_offer": "Create Passive Sell Offer",
          "set_options": "Set Options",
          "allow_trust": "Allow Trust",
          "account_merge": "Account Merge",
          "inflation": "Inflation",
          "manage_data": "Manage Data",
          "bump_sequence": "Bump Sequence",
          "create_claimable_balance": "Create Claimable Balance",
          "claim_claimable_balance": "Claim Claimable Balance",
          "begin_sponsoring_future_reserves":
              "Begin Sponsoring Future Reserves",
          "end_sponsoring_future_reserves": "End Sponsoring Future Reserves",
          "revoke_sponsorship": "Revoke Sponsorship",
          "clawback": "Clawback",
          "clawback_claimable_balance": "Clawback Claimable Balance",
          "set_trust_line_flags": "Set Trust Line Flags",
          "liquidity_pool_deposit": "Liquidity Pool Deposit",
          "liquidity_pool_withdraw": "Liquidity Pool Withdraw",
          "invoke_host_function": "Invoke Host Function",
          "extend_footprint_ttl": "Extend Footprint TTL",
          "restore_footprint": "Restore Footprint",
          "low": "Low",
          "medium": "Medium",
          "accessibility": "Accessibility",
          "stellar_low_operation_desc": "low-risk operation.",
          "stellar_medium_operation_desc": "Medium-risk operation.",
          "stellar_high_operation_desc": "High-risk operation.",
          "source_account": "Source account",
          "stellar_high_operation_desc2":
              "High-risk operation. Please ensure you fully understand this operation before proceeding, as you may lose funds or control of your account.",
          "soroban_data": "Soroban data",
          "fee_source": "Fee source",
          "secret_key": "Secret key",
          "stellar_base32_secret_key_validator":
              "Invalid Stellar secret key. The key must be a 56-character Base32 string.",
          "stellar_key_conversion": "Stellar key conversion",
          "stellar_key_conversion_desc":
              "Convert a Stellar Base32 secret key into an Ed25519 private key for secure cryptographic operations on the Stellar network.",

          "stellar_base32_secret_key_desc2":
              "Please enter a valid Stellar Base32 secret key.",
          "solana_key_conversion": "Solana key conversion",
          "solana_key_conversion_desc":
              "Convert a Solana Base58 keypair into an Ed25519 private key for secure cryptographic operations on the Solana network.",
          "solana_base58_secret_key_validator":
              "Invalid Solana keypair. The key must be at least an 88-character Base58 string.",
          "solana_base58_secret_key_desc2":
              "Please enter a valid Solana Base58 keypair.",
          "sub_address": "SubAddress",
          "xmr_sub_address_desc":
              "A Monero subaddress is a unique, privacy-enhancing address derived from a main wallet address, allowing users to segregate funds without revealing their main address.",
          "major_index": "Major index",
          "minor_index": "Minor index",
          "sync_options": "Sync options",
          "monero_sync_options": "Monero account synchronization options.",
          "monero_sync_options_desc":
              "Options for synchronizing Monero accounts by fetching unspent transaction outputs (UTXOs).",
          "monero_wallet_rpc_sync_desc":
              "Monero Wallet RPC synchronization option.",
          "monero_wallet_rpc_sync_desc1":
              "sends a request to your wallet and retrieves all incoming and outgoing transfers to synchronize with the current state.",
          "wallet_rpc_url": "Wallet RPC endpoint URL",
          "wallet_rpc_url_desc":
              "Enter your Wallet RPC endpoint URL, including the port if applicable.",
          "endpoint_url": "Endpoint URL",
          "sync_now": "Sync now",
          "monero_wallet_transaction_sync_desc":
              "Transaction synchronization option.",
          "monero_wallet_transaction_sync_desc2":
              "Synchronize your wallet's current state with its transaction history by providing your transaction IDs. We will retrieve and validate your unspent transactions.",
          "enter_transaction_ids_desc":
              "Enter your transaction IDs, Each transaction ID must be 64 hexadecimal characters and separated by spaces.",
          "transaction_ids": "Transaction IDs",
          "enter_transaction_ids_validator":
              "Please enter at least one transaction ID to begin synchronization.",
          "enter_transaction_ids_validator2":
              "Some of the provided transaction IDs are not valid 32-byte hexadecimal strings",
          "some_transaction_missing":
              "Certain transactions appear to be missing. Please ensure they are valid and accessible.",
          "page_required_address":
              "At least one active address is required to access the requested page.",
          "duplicate_transaction_ids_detected":
              "Duplicate transaction IDs detected.",
          "invalid_daemon_repsone": "Invalid daemon response",
          "monero_empty_outputs_desc":
              "We did not find any outputs for your accounts in these transactions.",
          "failed_to_parse_tx": "Failed to parse the transaction.",
          "output_has_already_spent": "The output has already been spent.",
          "output_is_ready_to_spent": "The output is ready to be spent.",
          "payment_information": "Payment informations.",
          "monero_payment_synced_desc":
              "The following payments are already synced with your accounts.",
          "sync_more": "Sync more",
          "monero_select_utxo_desc":
              "You can select UTXOs from both the primary address and subaddresses.",
          "monero_tx_integrated_address_alert":
              "Integrated addresses cannot be used in a transaction with multiple recipients.",
          "failed_to_unlock_output": "Failed to unlock the output.",
          "output_is_not_ready_for_spending":
              "The output is not yet ready for spending.",
          "show_proofs": "Show proofs",
          "transaction_proofs": "Transaction proofs.",
          "monero_tx_proof_desc":
              "These proofs are for each recipient of the current transaction, serving as evidence that you sent the specified amount.",
          "monero_tx_proof_desc1": "Each proof's message has been set to None.",
          "proof": "Proof",
          "invalid_daemon_distribution_response":
              "Invalid daemon output Distribution response.",
          "generate_rct_faild":
              "Failed to generate Ring Confidential Transaction (RCT)",
          "monero_utxo_lake_of_confirmatins_desc":
              "Lack of confirmations. UTXOs must have at least 10 confirmations before they can be spent.",
          "account_tx_detected_desc":
              "Account transaction detected. Tap to proceed.",
          "monero_block_height_sync_desc":
              "Synchronizing transactions from a specified block height.",
          "monero_block_height_sync_desc2":
              "Synchronize your wallet's current state by specifying a start and end block height. We will retrieve and validate all transactions within the range, ensuring your unspent outputs are accurately updated.",
          "monero_block_height_sync_desc3":
              "This process may take significant time, especially for ranges spanning millions of blocks, potentially a day or longer. Ensure you accurately set the start and end block heights to include all relevant transactions.",
          "start_at_block": "Start at block",
          "end_at_block": "End at block",
          "monero_rct_block_validator":
              "Wallet supports RCT Transactions only from block ___1__ onward.",
          "monero_sync_block_validator":
              "End block must be greater than start block.",
          "submiting_sync_process": "Submitting synchronization process.",
          "select_accounts_for_syncing":
              "Select the accounts you want to sync.",
          "primary_account": "Primary account.",
          "addresses": "Addresses",
          "at_least_one_account_required": "At least one address is required.",
          "only_on_request_can_be_processed":
              "Only one request can be processed at a time.",
          "monero_invalid_end_block_height_validator":
              "The end block is greater than the current block height.",
          "tap_to_add_account": "Tap to add a new account.",
          "wallet_rpc": "Wallet RPC",
          "block": "Block",
          "invalid_url": "Invalid url.",
          "key_derivation_disabled_desc":
              "Derivation disabled for this key type",
          "monero_fetching_Wallet_available_transfers":
              "Fetching wallet available transfers. Please wait.",
          "monero_wallet_rpc_sync_desc2":
              "The default Monero Wallet RPC URL ends with 'json_rpc'. Please ensure you have entered the correct URL.",
          "monero_wallet_rpc_sync_no_tx_found_desc":
              "No incoming transactions were found for your current account or subaccounts",
          "wallet_rpc_different_account_response_desc":
              "Monero wallet returned an account that does not match any of your wallet accounts.",
          "monero_fetching_Wallet_addresses":
              "Fetching wallet addresses. Please wait.",
          "monero_wallet_rpc_safty_interacting_desc":
              "For safety when interacting with Wallet RPC, ensure that you enable the '--restricted-rpc' option when running the Wallet RPC.",
          "sync_information": "Sync Information",
          "view_account_block_sync": "View account block sync information",
          "related_accounts": "Related account.",
          "current_block_height": "Current block height",
          "fetched_blocks": "Fetched blocks",
          "setup_fee_manually":
              "Unable to determine the network fee. Please enter it manually.",
          "create_token": "Create token",
          "compressed_public_key": "Compressed public key",
          "generatare_from_compressed_public_key":
              "Generate from the compressed public key.",
          "public_key_required_derive_address":
              "Public key needed to derive the address",
          "add_to_address": "Add to addresses",
          "review_addresses": "Review addresses",
          "some_addresses_exist": "Some addresses already exist.",
          "account_tokens": "Account tokens",
          "choose_payment_currency": "Choose Payment Currency",
          "xrp_create_token_desc":
              "Ensure the token does not already exist. If you attempt to create a token that already exists in your account with the same issuer and currency, the existing token will be selected instead.",
          "ripple_provider_network_id_validator":
              "The Network id is incompatible with the current network.",
          "api_url": "API URL",
          "ton_unable_to_retrieve_workchain":
              "Unable to retrieve the network workchain ID",
          "spl_token_invalid_associated_account_address":
              "The destination address does not have an associated token account for the specified SPL token.",
          "solana_destination_address_invalid_public_key":
              "The destination address is not a valid Solana public key.",
          "system_program": "System program",
          "spl_token": "SPL-Token",
          "spl_token2022": "SPL-Token2022",
          "solana_spl_token_required_public_key":
              "Sending tokens to an inactive account requires a valid public key instead of a PDA address.",
          "invalid_address": "The provided address is invalid",
          "cardano_enter_pool_id_desc":
              "Enter the unique ID of your stake pool for delegation.",
          "setup_pool_id": "Setup pool ID",
          "cardano_pool_id_validator": "Please enter a valid Cardano pool ID.",
          "signer_account_does_not_exists":
              "The Signer account has not been found.",
          "reward_address": "Reward address",
          "cardano_network_magic_validator":
              "The network magic is incompatible with the current network.",
          "assets_balance_not_supported_desc":
              "The current version of the wallet does not support or validate asset metadata, and the balance only accepts whole numbers (no decimals).",
          "pick_token": "Pick token",
          "cosmos_pick_token_transfer_desc":
              "Select the token you want to transfer, or close the page to switch to the native chain token.",
          "cosmos_transfer_import_token_desc":
              "If your token isn't listed here, you can import it on the account page.",
          "insufficient_token_balance": "Insufficient token balance",
          "requested_chain_differs":
              "The requested chain differs from your wallet's chain.",
          "page_required_provider":
              "The page requires at least one active service provider.",
          "mainnet": "Mainnet",
          "invalid_chain_type": "Invalid chain type.",
          "chain_type": "Chain type",
          "select_cosmos_chain_type_desc":
              "Please select the chain type to retrieve all related chains.",
          "retrieving_chains": "Retrieving chains. Please wait.",
          "import_manually": "Import manually",
          "chain_not_found_import_manually_desc":
              "We couldn't find the chain with the provided name. Please import it manually.",
          "select_network_to_import_desc":
              "Select the network you want to import.",
          "unsuported_network": "Network not supported",
          "fee_token": "Fee token",
          "denom": "Denom",
          "token_demination_desc": "Please enter the token denomination",
          "key_alg": "Key algorithm",
          "cosmos_key_alg_desc":
              "Algorithm used for key generation and transaction signing",
          "cosmos_key_alg_desc2":
              "Ensure your network supports this key algorithm; otherwise, you may risk losing funds.",
          "native_token": "Native token",
          "enter_tendermint_rpc_desc":
              "Enter the Tendermint RPC URL of the chain for interaction.",
          "unsupported_network_key_alg":
              "The network's key algorithm is not supported.",
          "unable_to_find_network_token_denom":
              "Unable to find the native token denomination for the network.",
          "import_network_experimental_feature_desc":
              "This feature is experimental. Please carefully verify all information about the chain before importing it into your wallet.",
          "cosmis_fee_limit_desc":
              "Specify the maximum gas units for this transaction on the Cosmos blockchain.",
          "automatically_setup_fee": "Automatically set up fee?",
          "switch_to_automatic_fee_desc":
              "Do you want to switch to the automatic fee?",
          "invalid_token_exponent": "Invalid token exponent.",
          "tap_to_setup_native_token": "Tap to set up the native token.",
          "fee_tokens": "Fee tokens",
          "tap_to_add_new_fee_token": "Tap to add a new fee token",
          "token_name": "Token name",
          "token_decimal_max18_validator":
              "Token decimals must be between 0 and 18.",
          "setup_token": "Setup token",
          "remove_token_from_fee_token_list_desc":
              "Remove token from the fee tokens list?",
          "at_least_one_fee_token_required":
              "At least one fee token is required.",
          "network_token_required": "The network's native token is required.",
          "cosmos_update_token_desc":
              "Ensure the token denomination and decimals are entered correctly; otherwise, the import operation will fail.",
          "cosmos_fee_token_desc":
              "The token is used for paying fees. In most networks, this is the native token.",
          "select_key_algorithm_desc": "Please select a key algorithm.",
          "min_gas_price": "Min gas price",
          "avarage_gas_price": "Avarage gas price",
          "high_gas_price": "High gas price",
          "comsos_gas_price_desc":
              "This field is multiplied by the transaction gas limit to calculate the transaction fee.",
          "gas_price_validator":
              "Please enter a valid gas price as a double value.",
          "stellar_asset_trust_path_limit_exceeded":
              "Asset trust path limit exceeded.",
          "stellar_destination_lacks_trust_path":
              "The destination lacks a trust path for this token.",
          "tx_submit_response_failed_desc":
              "Failed to submit the transaction response. Please check the block explorer for details.",
          "seed_phrase": "Seed Phrase",
          "external_keys": "External keys",
          "activity": "Activity",
          "transaction": "Transaction",
          "monero_mnemonic": "Monero Mnemonic",
          "generate_monero_private_key":
              "Generate a private key from your Monero mnemonic.",
          "monero_mnemonic_desc":
              "The Monero network uses its algorithm to generate private keys from mnemonics. You can create or import a Monero mnemonic, convert it to a private key, and import it into your wallet.",
          "monero_menonic_validator":
              "Please enter your mnemonic phrase below, consisting of 12, 13, 24, or 25 words, separated by spaces.",
          "addresses_and_initial_sync_block":
              "The addresses and the initial sync block",
          "default_chain_sync": "Default chain synchronization",
          "requested_synchronizations": "Requested synchronizations ___1__",
          "available_synchronizations": "Available synchronizations",
          "faliled_blocks": "Failed blocks",
          "deserialization_blocks_failed":
              "These blocks failed during deserialization",
          "stream_closed_desc":
              "Cannot access the stream. it has already been closed",
          "stream_does_not_exists": "Stream does not exist.",
          "isolate_terminated_error":
              "An unexpected error occurred while processing the request. The isolate has terminated.",
          "canceled": "Canceled",
          "paused": "Paused",
          "synced": "Synced",
          "process": "In Process",
          "resume": "Resume",
          "pause": "Pause",
          "pending": "Pending",
          "updating_status_pls_wait": "Updating status. please wait.",
          "unsuported_digest_auth_algorithm":
              "Unsupported Digest Authentication algorithm. Only 'MD5' and 'MD5-sess' are supported.",
          "unsuported_digest_auth_qop":
              "Unsupported Digest Authentication Quality of Protection. Only 'auth' and 'auth-int' are supported.",
          "invalid_dgiest_auth_headers":
              "Invalid Digest Authentication headers.",
          "username": "Username",
          "authenticated_realm_validator":
              "Please enter at least one character for the realm.",
          "realm": "Realm",
          "maintain_monero_wallet_rpc_connection":
              "Maintain Wallet RPC Connection",
          "store_wallet_rpc_connection":
              "Your Wallet RPC information is stored to assist in syncing accounts, UTXOs, and transactions.",
          "already_connected_to_monero_wallet_rpc":
              "You are already connected to the Monero Wallet RPC.",
          "disconnect_from_wallet_rpc": "Disconnect from the Wallet RPC.",
          "disconnect_from_monero_wallet_rpc_desc":
              "The Wallet RPC information will be removed from your account. Are you sure you want to proceed?",
          "no_acitve_provider": "No provider is currently active.",
          "spend_public_key": "Spend public key",
          "view_public_key": "View public key",
          "spend_private_key": "Spend private key",
          "view_private_key": "View private key",
          "transaction_not_found": "Transaction not found.",
          "generate_transaction_proof": "Generate transaction proof",
          "choose_account_received_payment":
              "Choose the account that received the payment.",
          "monero_tx_proof_message_desc":
              "The message of the proof, if provided, is essential for verification.",
          "setup_message": "Setup message",
          "invalid_transaction_id":
              "Invalid transaction ID. the transaction ID must be a 32-byte hexadecimal string.",
          "monero_tx_proof_desc3":
              "Monero generates a transaction proof to verify payment details using the transaction ID, address, and an optional message.",
          "transaction_proof": "Transaction Proof",
          "payment_transaction_id": "The transaction ID of the payment.",
          "generating_proof_please_wait": "Generating proof. Please wait.",
          "verify_transaction_proof": "Verify transaction proof",
          "monero_verify_proof_desc":
              "Monero verifies a transaction proof using the transaction ID, recipient address, optional message, and the provided proof signature",
          "signature": "Signature",
          "monero_proof_validator":
              "Invalid Monero proof. the proof must start with 'InProofV2' or 'OutProofV2'",
          "message_of_the_proof": "The message of the proof",
          "verify": "Verify",
          "verification_failed_no_amount_received":
              "Verification failed. No amount received in this transaction.",
          "create_sign_monero_tx_desc":
              "Creating and signing ___1__ transaction, this may take up to 6 minutes.",
          "spent_in_pool": "Spent in pool",
          "data_casting_failed": "Data conversion unsuccessful",
          "cosmos_enter_hrp_desc":
              "Enter the network address prefix (HRP), or leave blank to determine it from the RPC.",
          "enter_network_hrp_validator": "Please enter a valid network HRP.",
          "address_prefix_hrp": "Address prefix (HRP)",
          "unable_to_retrieve_hrp":
              "Unable to retrieve HRP from RPC. Please provide it.",
          "different_network_hrp":
              "Invalid HRP. The network returned a different HRP.",
          "add_new_network": "Add new ___1__ network",
          "http_api_url": "HTTP API URL",
          "json_rpc_solidity_url": "JSON RPC URL(EVM)",
          "network_title_http_wss_url":
              "Please provide the HTTP or Websocket address, including the http or ws prefix. If applicable, include the port number. For example, https://example.com:8080",
          "create_sign_transaction":
              "Creating and signing transaction. Kindly await completion.",
          "monero_slow_chain_tracking_alert":
              "Currently, account chain tracking is very slow. We recommend using the sync option to update your account state efficiently.",
          "paste_your_backup_here": "Paste the backup of your wallet here",
          "constants": "Constants",
          "access_network_constants": "Access network constants.",
          "retrieving_constants_please_wait":
              "Retrieving Constants, please wait",
          "storages": "Storages",
          "query_network_storages": "Query network storages",
          "query_again": "Query again",
          "retrieving_data_please_wait": "Retrieving data, please wait",
          "get_storages": "Query Storages",
          "query_storages_n": "Query Storages ( ___1__ )",
          "inputs_not_needed": "Inputs not needed.",
          "enter_hex_bytes": "Enter the value in hexadecimal byte format.",
          "bytes": "Bytes",
          "invalid_hex_validator":
              "Invalid hex format. Please enter the value in hexadecimal format",
          "invalid_hex_length":
              "The hexadecimal value must be a ___1__-character string (___2__ bytes).",
          "runtime_apis": "Runtime API's",
          "interact_with_substrate_network_run_time_api":
              "Interact with network runtime API's.",
          "call_api": "Call API",
          "call_again": "Call again",
          "tap_to_create_object": "Tap to create ___1__ object.",
          "create_extrinsic": "Create Extrinsic",
          "create_and_sign_extrinsic": "Create and sign extrinsic",
          "create_payload": "Create payload",
          "address_decoder": "Address decoder",
          "utf8_encoder": "UTF-8 encoder",
          "spec_version": "Spec Version",
          "bytes_tools": "Bytes tools",
          "bytes_tools_desc":
              "Bytes Tools: Convert hex bytes to addresses or compute hashes from them",
          "convert": "Convert",
          "block_hash": "Block Hash",
          "finaliz_block_era": "Finaliz Block and Era",
          "finaliz_block": "Finaliz Block",
          "genesis_hash": "Genesis hash",
          "era": "Era",
          "quick_era": "Era: Validated for approximately 150 blocks.",
          "substrate_quick_block_access": "Quick block access",
          "serialized_data": "Serialized Data",
          "serialized_call": "Serialized Call",
          "sing_and_setup_extrinsic": "Sign and setup extrinsic",
          "payload_info": "Payload info",
          "substrate_determine_address_signature_failed":
              "Unable to determine the metadata address or signature type.",
          "create_and_review_extrinsic": "Create and review extrinsic",
          "some_input_not_filled": "Some inputs are not filled.",
          "extrinsic": "Extrinsic",
          "payload": "Payload",
          "unsigned_transaction": "Unsigned Transaction",
          "unsigned_extrinsic_desc": "Create without signature.",
          "submit_extrinsic": "Submit Extrinsic",
          "fake_extrinsic_signature_desc":
              "The extrinsic contains a fake signature. The actual signature is added to the extrinsic when it is submitted.",
          "import_substrate_network": "Import substrate network",
          "token_decimal_maxn_validator":
              "Token decimals must be between 0 and ___1__.",
          "unsuported_network_metadata": "Unsuported network metadata.",
          "extrinsic_encoding_failed": "Extrinsic encoding failed.",
          "websocket_authenticated_unsuported_desc":
              "The provided authentication method is incompatible with WebSocket connections.",
          "network_type": "Network type",
          "ss58_prefix": "SS58 Prefix",
          "substrate_disable_transfer_option_desc":
              "Unable to find the transfer_allow_death and transfer_keep_alive methods. The transfer option will be disabled.",
          "substrate_unsuported_account_template_desc":
              "Unsupported account template. The account balance will always display as zero.",
          "add_or_updating_wallet_network":
              "Add or updating wallet network. please wait.",
          "page_not_found": "Page not found.",
          "substrate_networks": "Substrate networks",
          "web3_client_connection_failed":
              "The current Web3 request requires interaction with a node, but the connection to the node could not be established.",
          "web3_retrieval_requirment":
              "Web3 Retrieval Requirements. please wait.",
          "network_enable_web3_desc":
              "Ensure that after adding the chain, you update the application permissions to enable Web3 features for the network.",
          "number_to_decimal": "10^___1__ (___2__)",
          "update_metadata": "Update metadata",
          "substrate_update_metadata_desc":
              "The client has requested an update to your network metadata.",
          "invalid_spec_version": "Invalid spec version.",
          "select_provider_to_use":
              "Please select one of the providers you want to use when interacting chain",
          "keep_unlock": "Keep unlock",
          "wallet_lock_timer_desc":
              "The wallet will be locked after ___1__ seconds",
          "another_instance_already_active":
              "Another instance is already active.",
          "web3_permission": "Web3 Application Permission",
          "transaction_simulate_not_ready_desc":
              "Transaction simulation is not ready. Do you still want to proceed with sending the transaction?",
          "transaction_simulate_failed_desc":
              "Transaction simulation failed. Do you still want to proceed with sending the transaction?",
          "aptos_select_provider_desc":
              "Choose a network service for Full Node and GraphQL interaction.",
          "full_node": "Full Node",
          "graphql": "GraphQL",
          "token_balance_frozen_desc": "Token balance marked as frozen.",
          "leak_of_gas_token_desc":
              "Your account doesn't have enough Gas tokens to cover the fee.",
          "threshold_validator":
              "The threshold value must range between ___1__ and ___2__.",
          "setup_multisig_address": "Setup multisig address",
          "multisig_address": "Multisig address",
          "multisig_address_desc":
              "Multisig addresses enhance security by requiring multiple approvals for transactions, reducing the risk of unauthorized access.",
          "mutlisig_address_alert":
              "All options on this page are crucial. Missing any details or altering the account order may pose risks. Please fill them out carefully.",
          "multisig_address_weight_desc":
              "Address weight in a multi-sig determines its voting power for transaction approvals",
          "address_weight_validator":
              "Invalid address weight. It must be between ___1__ and ___2__ ",
          "invalid_signature": "Invalid signature.",
          "insufficient_signatures": "Insufficient signatures.",
          "exceeded_multisig_maximum_publickey":
              "Exceeded the maximum allowed public keys for a multisig account.",
          "multisig_address_infos": "Multisig address info",
          "invalid_account": "Invalid account.",
          "locking_script": "Locking Script",
          "at_least_n_account_required": "At least ___1__ address is required.",
          "aptos_required_signature_validator":
              "The required signature value must range between ___1__ and ___2__.",
          "aptos_required_signature_validator2":
              "The number of accounts must meet the specified required signature.",
          "required_signature": "Required signature",
          "required_signature_desc":
              "the number of signatures required to confirm the transaction",
          "aptos_mutli_ed25519_key_type_validator":
              "A MultiED25519 account can only be generated using an ED25519 public key.",
          "key_scheme": "Key scheme",
          "invalid_key_scheme": "Invalid key scheme.",
          "aptos_networks": "Aptos networks.",
          "transaction_content": "Transaction content",
          "transaction_owner": "Transaction owner",
          "transaction_fee_payer": "Transaction fee payer",
          "secondary_signer_addresses": "Secondary signer addresses",
          "simulate_content": "Simulate content",
          "sui_networks": "Sui networks.",
          "no_web3_activities": "No Web3 activities available.",
          "remove_activities": "Remove activities.",
          "delete_all_activities_desc": "Delete all application activities.",
          "delete_all_activities_desc2":
              "Delete all application activities? This action cannot be undone",
          "web3_applications": "Web3 applications",
          "update_dapp_permissions": "Update DApp permissions",
          "balance_changes": "Balance changes",
          "client_closed_durning_request":
              "The connection between the client and wallet was lost during the request.",
          "sui_key_conversion": "Sui key conversion",
          "sui_key_conversion_desc":
              "Convert a Sui Bech32 secret key into an private key for secure cryptographic operations on the Sui network.",
          "invalid_sui_secret_key": "Invalid Sui secret key.",
          "sui_bech32_secret_key_desc2":
              "Please enter a valid Sui Bech32 secret key. The key must start with 'suiprivkey'.",
          "n_style": "___1__ style",
          "aptos_key_conversion": "Aptos key conversion",
          "Aptos_key_conversion_desc":
              "Convert a Aptos AIP-80 private key style into an private key for secure cryptographic operations on the Aptos network.",
          "aptos_aip80_private_key_desc2":
              "Please enter a valid Aptos AIP-80 private key.  The key must start with 'ed25519-priv-' or 'secp256k1-priv-'",
          "invalid_aptos_private_key": "Invalid Aptos private key.",
        }
      };
}
