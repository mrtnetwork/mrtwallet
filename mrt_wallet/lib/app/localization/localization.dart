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
          "derive_network_address": "Deriving ___1__ Addresses",
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
          "setup_network_address": "Setup ___1__ address",
          "setup_network_address_desc":
              "You have not set up any ___1__ account. To begin setup, please click on the 'Setup Address' button.",
          "setup_address": "Setup Address",
          "choose_bitcoin_address_type": "Choose Address Type",
          "choose_bitcoin_address_type_desc":
              "Please select the address type to create an address.",
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
          "copied_to_clipboard": "Copied to cliboard.",
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
          "key_type": "key type",
          "imported": "Imported",
          "importing_key_pls_wait": "Importing key. please wait.",
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
          "service_provider": "Service provider",
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
              "X-address: The X-address is a more user-friendly and interoperable format for Ripple addresses. It includes an additional destination tag and an optional invoice ID, allowing for smoother transactions. The X-address is designed to simplify the process of sending and receiving Ripple payments while reducing errors often associated with using classic addresses.",
          "classic_address_desc":
              "Classic address: The classic address is the traditional format for identifying Ripple accounts. It consists of a series of letters and numbers that uniquely represent a Ripple account. Classic addresses can also include a destination tag, which is used to associate incoming payments with a specific account, particularly in cases where multiple users share the same receiving address.",
          "tag": "Tag",
          "x_address_desc2": "Understanding Ripple X-Address Tags",
          "x_address_desc3":
              "In the context of Ripple X-addresses, a tag is a supplementary identifier used to associate incoming payments with a specific account. This feature is especially useful for scenarios where multiple users share the same receiving address. By including a tag along with the X-address, the sender can specify which account the payment is intended for, ensuring that the funds are correctly attributed to the intended recipient within the target account. This is particularly important for exchanges and services that manage large volumes of transactions for numerous users using a single address. Therefore, the tag plays a crucial role in facilitating accurate and efficient routing of incoming payments within the Ripple network.",
          "assigning_tag": "Assigning a Tag to Your Ripple X-Address",
          "enter_tag_desc":
              "Please enter the desired tag for your account. The tag must be a value between 0 and 2^32-1.",
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
          "ripple_key_type": "Ripple key type",
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
              "The transaction requires the use of the following private keys for signing.",
          "amount_for_each_output":
              "Kindly input the preferred quantity for each output.",
          "cancel": "Cancel",
          "account_name": "Account name",
          "setup_or_update_account_name": "Establish or Refresh Account Name",
          "remove_account_name_desc":
              "If you wish to remove the account name, please confirm by entering an empty text."
        }
      };
}
