import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/wallet/setup/pages/setup_wallet.dart';
import 'package:mrt_wallet/wallet/models/network/core/network.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';

class PageRouter {
  /// bitcoin casah
  static const String bitcoinCashTransaction = "/bitcoincash/transaction";

  static const String bitcoinTransaction = "/bitcoin/transaction";
  static const String rippleTransfer = "/ripple/transfer";
  static const String rippleAddToken = "/ripple/import_token";
  static const String rippleAddNfts = "/ripple/import_nfts";
  static const String rippleTransaction = "/ripple/transaction";
  static const String rippleMultisigAddress = "/ripple/setup_multisig_address";
  static const String rippleSettingPage = "setting/ripple";
  static const String rippleKeyConversion = "setting/ripple/key_conversion";
  static const String ethereumTransaction = "/ethereum/transfer";

  static const String stellarTransaction = "/stellar/transfer";
  static const String stellarImportToken = "/stellar/import_token";
  static const String stellarSettingPage = "setting/stellar";
  static const String stellarKeyConversion = "setting/stellar/key_conversion";

  // tron
  static const String tronTransfer = "/tron/transfer";
  static const String tronTransaction = "/tron/transaction";
  static const String tronMultiSigAddress = "/tron/setup_multisig_address";
  // solana transfer
  static const String solanaTransfer = "/solana/transfer";
  static const String solanaTransaction = "/solana/transaction";

  static const String solanaSettingPage = "setting/solana";
  static const String solanaKeyConversion = "setting/solana/key_conversion";

  // ton transfer
  static const String tonTransfer = "/ton/transfer";

  // substrate transfer
  static const String substrateTransfer = "/substrate/transfer";
  static const String substrateTransaction = "/substrate/transaction";
  static const String importSubstrateNetwork = "/substrate/networks/import";

  /// cardano
  static const String cardanoTransaction = "/cardano/transaction";
  static const String cosmosTransfer = "/cosmos/transfer";
  static const String cosmosTransaction = "/cosmos/transaction";

  /// CosmosTransactionFieldsView

  static const String importCosmosNetwork = "/cosmos/networks/import";
  static const String setupGenericAddress = "/networks/setup_address";

  /// aotos
  static const String aptosTransfer = "/aptos/transfer";
  static const String importAptosToken = "Aptos/import_fats_tokens";
  static const String aptosMultisigAddress = "/aptos/setup_multisig_address";
  static const String aptosMultisigAccountInfo = "/aptos/multisig_account_info";
  static const String aptosSettingPage = "setting/aptos";
  static const String aptosKeyConversion = "setting/aptos/key_conversion";

  /// sui
  static const String suiTransfer = "/sui/transfer";
  static const String importSuiToken = "/sui/import_tokens";
  static const String suiMultisigAddress = "/sui/setup_multisig_address";
  static const String suiMultisigAccountInfo = "/sui/multisig_account_info";
  static const String suiSettingPage = "setting/sui";
  static const String suiKeyConversion = "setting/sui/key_conversion";
  static const String setupBitcoinMultsig = "/bitcoin/setup_multisig_address";

  static const String bitcoinMultisigAccountInfo =
      "/bitcoin/multisig_account_info";
  static const String bitcoinCashMultisigAccountInfo =
      "/bitcoinCash/multisig_account_info";
  static const String createWallet = "/create_wallet";
  static const String setup = "/setup";
  static const String home = "/";

  static const String setting = "/setting";
  static const String updateSetting = "/setting/update";

  /// acccount
  static const String removeAccount = "/account/remove";
  static const String importAccount = "/account/import";
  static const String showPublicKey = "account/public_key";

  /// security
  static const String changePassword = "/security/password";
  static const String eraswWallet = "/security/erase";
  static const String backupWallet = "/security/backup";
  static const String exportPrivateKey = "/security/privateKey";
  static const String manageImportedKey = "/security/manageKeys";
  static const String exportSeed = "/security/seed";

  /// importnetworks
  static const String importEthereumNetwork = "/networks/import";
  // static const String editEvmNetwork = "/networks/edit";
  static const String updateEthereumProvider = "/networks/ethereum/providers";

  static const String updateElectrumProviders = "/networks/bitcoin/providers";
  static const String updateSolanaProviders = "/networks/solana/providers";
  static const String updateSubstrateProviders =
      "/networks/substrate/providers";
  static const String updateRippleProviders = "/networks/ripple/providers";
  static const String updateCardanoProviders = "/networks/cardano/providers";
  static const String updateTonProviders = "/networks/ton/providers";
  static const String updateCosmosProviders = "/networks/cosmos/providers";
  static const String updateMoneroProviders = "/networks/monero/providers";
  static const String updateStellarProviders = "/networks/stellar/providers";
  static const String updateTronProviders = "/networks/tron/providers";
  static const String updateSuiProviders = "/networks/sui/providers";
  static const String updateAptosProviders = "/networks/aptos/providers";

  static const String updateNetwork = "/networks/update";

  /// UpdateStellarProvider
  static const String importERC20Token = "ethereum/import_token";
  static const String importTronToken = "tron/import_trc10_token";
  static const String importSPLTokens = "solana/import_spl_tokens";
  static const String importCosmosTokens = "cosmos/import_spl_tokens";

  static const String tonSettings = "setting/ton";
  static const String tonMnemonic = "setting/ton/mnemonic";
  static const String importJettons = "ton/import_jettons";

  static const String barcodeScanner = "barcode_scanner";

  static const String moneroSettings = "setting/monero";
  static const String moneroSyncOptions = "setting/monero/sync_options";
  static const String moneroGenerateProof =
      "setting/monero/generate_transaction_proof";
  static const String moneroVerifyProof = "setting/monero/verify_proof";
  static const String moneroAccountSync = "setting/monero/sync";
  static const String moneroMnemonic = "setting/monero/mnemonic";
  static const String moneroTransfer = "/monero/transfer";

  /// web3
  static const String web3 = "web3/";
  static const String web3Ethereum = "web3/ethereum";
  static const String web3Tron = "web3/tron";
  static const String web3Solana = "web3/solana";
  static const String web3Ton = "web3/ton";
  static const String web3Stellar = "web3/stellar";
  static const String web3Substrate = "web3/substrate";
  static const String web3Aptos = "web3/aptos";
  static const String web3Sui = "web3/sui";
  static const String web3Cosmos = "web3/cosmos";
  static const String web3Bitcoin = "web3/bitcoin";
  static const String web3Permission = "web3/permission";
  static const String web3Global = "web3/connect";

  static const String webview = "web/";

  static Widget _page(String? name) {
    switch (name) {
      case setup:
        return const SetupWallet();
      case solanaTransfer:
        return const SolanaTransferTransactionView();
      case aptosTransfer:
        return const AptosTransferTransactionView();
      case suiTransfer:
        return const SuiTransferTransactionView();
      case suiMultisigAddress:
        return const SetupSuiMultisigAddress();
      case tonTransfer:
        return const TonTransferTransactionView();
      case bitcoinTransaction:
        return const SendBitcoinTransactionView();
      case bitcoinCashTransaction:
        return const SendBitcoinCashTransactionView();
      case setupBitcoinMultsig:
        return const SetupBitcoinMultiSigAddressView();
      case exportSeed:
        return const ExportSeedView();
      case changePassword:
        return const ChangeWalletPasswordView();
      case eraswWallet:
        return const EraseWalletView();
      case exportPrivateKey:
        return const AccountPrivteKeyView();
      case removeAccount:
        return const DeleteAccountView();
      case importAccount:
        return const ImportAccountView();
      case setting:
        return const AppSettingView();
      case updateSetting:
        return const UpdateWalletSettingView();
      case backupWallet:
        return const BackupWalletView();
      case manageImportedKey:
        return const ManageImportedKeysView();

      case setupGenericAddress:
        return const NetworkGenericAddressDerivationView();
      case rippleTransfer:
        return const RippleTransferTransactionView();
      case stellarTransaction:
        return const StellarTransferTransactionView();
      case ethereumTransaction:
        return const EthereumTransferTransactionView();
      case tronTransfer:
        return const TronTransferTransactionView();
      case rippleAddToken:
        return const MonitorRippleTokenView();
      case stellarImportToken:
        return const MonitorStellarTokenView();
      case rippleAddNfts:
        return const MonitorRippleNFTsView();
      case rippleTransaction:
        return const RippleTransactionFieldsView();
      case rippleMultisigAddress:
        return const SetupRippleMutlisigAddressView();
      case importERC20Token:
        return const ImportERC20TokenView();

      case importTronToken:
        return const MonitorTronTokenView();
      case tronMultiSigAddress:
        return const SetupTronMultiSigAddressView();
      case tronTransaction:
        return const TronTransactionFieldsView();
      case importEthereumNetwork:
        return const ImportEthereumNetwork();

      case updateElectrumProviders:
        return const ImportElectrumProviderView();
      case updateCardanoProviders:
        return const UpdateCardanoProvider();
      case updateRippleProviders:
        return const UpdateRippleProviderView();
      case importSPLTokens:
        return const SolanaImportSPLTokensView();
      case importAptosToken:
        return const AptosImportFATTokensView();
      case importSuiToken:
        return const SuiImportTokensView();
      case importCosmosTokens:
        return const CosmosImportTokenView();
      case importCosmosNetwork:
        return const CosmosImportNetworkView();
      case importJettons:
        return const TonImportJettonsView();
      case cardanoTransaction:
        return const SendCardanoTransactionView();
      case cosmosTransfer:
        return const CosmosTransferTransactionView();
      case cosmosTransaction:
        return const CosmosTransactionFieldsView();
      case solanaTransaction:
        return const SolanaTransactionFieldsView();
      case updateSolanaProviders:
        return const UpdateSolanaProvider();
      case updateSuiProviders:
        return const UpdateSuiProvider();
      case updateAptosProviders:
        return const UpdateAptosProvider();
      case updateCosmosProviders:
        return const UpdateCosmosProvider();
      case updateSubstrateProviders:
        return const UpdateSubstrateProvider();
      case updateMoneroProviders:
        return const UpdateMoneroProvider();
      case updateStellarProviders:
        return const UpdateStellarProvider();
      case tonSettings:
        return const TonSettingsView();
      case tonMnemonic:
        return const GenerateTonMnemonicView();
      case rippleSettingPage:
        return const RippleFeaturePageView();
      case stellarSettingPage:
        return const StellarFeaturePageView();
      case solanaSettingPage:
        return const SolanaFeaturePageView();
      case suiSettingPage:
        return const SuiFeaturePageView();
      case aptosSettingPage:
        return const AptosFeaturePageView();
      case rippleKeyConversion:
        return const RippleKeyConversionView();
      case stellarKeyConversion:
        return const StellarKeyConversionView();
      case solanaKeyConversion:
        return const SolanaKeyConversionView();
      case suiKeyConversion:
        return const SuiKeyConversionView();
      case aptosKeyConversion:
        return const AptosKeyConversionView();
      case showPublicKey:
        return const AccountPublicKeyView();
      case createWallet:
        return const WalletSetupPageWidget();
      case barcodeScanner:
        return const BarcodeScannerView();
      case substrateTransfer:
        return const SubstrateTransferTransactionView();
      case substrateTransaction:
        return const SubstrateTransactionFieldsView();
      case web3Ethereum:
        return const EthereumWeb3FieldsView();
      case web3Tron:
        return const TronWeb3FieldsView();
      case web3Ton:
        return const TonWeb3FieldsView();
      case web3Stellar:
        return const StellarWeb3FieldsView();
      case web3Substrate:
        return const SubstrateWeb3FieldsView();
      case web3Aptos:
        return const AptosWeb3FieldsView();
      case web3Sui:
        return const SuiWeb3FieldsView();
      case web3Cosmos:
        return const CosmosWeb3FieldsView();
      case web3Bitcoin:
        return const BitcoinWeb3FieldsView();
      case web3Solana:
        return const SolanaWeb3FieldsView();
      case updateEthereumProvider:
        return const UpdateEthereumProvider();
      case updateTonProviders:
        return const UpdateTonProvider();
      case updateTronProviders:
        return const UpdateTronProvider();

      case webview:
        return const WebView();
      case moneroSettings:
        return const MoneroSettingsView();
      case moneroSyncOptions:
        return const MoneroSyncOptionsView();
      case moneroGenerateProof:
        return const MoneroGenerateTxProofView();
      case moneroVerifyProof:
        return const MoneroVerifyTxProofView();
      case moneroAccountSync:
        return const MoneroAccountSyncView();
      case moneroTransfer:
        return const MoneroTransferTransactionView();
      case moneroMnemonic:
        return const GenerateMoneroMnemonicView();
      case importSubstrateNetwork:
        return const SubstrateImportChainView();
      case updateNetwork:
        return const UpdateNetworkView();

      case bitcoinMultisigAccountInfo:
      case bitcoinCashMultisigAccountInfo:
        return const BitcoinMultisigAccountInfoView();
      case suiMultisigAccountInfo:
        return const SuiMultisigAccountInfoView();
      case aptosMultisigAccountInfo:
        return const AptosMultisigAccountInfoView();
      case aptosMultisigAddress:
        return const SetupAptosMultisigAddress();
      case web3Global:
        return const GlobalWeb3FieldsView();

      default:
        return const HomeScreen();
    }
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return MaterialPageView(child: _page(settings.name));
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
        settings: settings,
        reverseTransitionDuration: const Duration(milliseconds: 300),
        allowSnapshotting: false,
        fullscreenDialog: false,
        opaque: false);
  }

  static String updateProvider(WalletNetwork network) {
    switch (network.type) {
      case NetworkType.ethereum:
        return updateEthereumProvider;
      case NetworkType.solana:
        return updateSolanaProviders;
      case NetworkType.ton:
        return updateTonProviders;
      case NetworkType.tron:
        return updateTronProviders;
      case NetworkType.xrpl:
        return updateRippleProviders;
      case NetworkType.cardano:
        return updateCardanoProviders;
      case NetworkType.cosmos:
        return updateCosmosProviders;
      case NetworkType.monero:
        return updateMoneroProviders;
      case NetworkType.stellar:
        return updateStellarProviders;
      case NetworkType.substrate:
        return updateSubstrateProviders;
      case NetworkType.bitcoinAndForked:
      case NetworkType.bitcoinCash:
        return updateElectrumProviders;
      case NetworkType.sui:
        return updateSuiProviders;

      case NetworkType.aptos:
        return updateAptosProviders;

      default:
        throw UnsupportedError("edit provider unsuported.");
    }
  }

  static String transactionPage(WalletNetwork network) {
    switch (network.type) {
      case NetworkType.bitcoinCash:
      case NetworkType.bitcoinAndForked:
        return bitcoinTransaction;
      case NetworkType.ethereum:
        return ethereumTransaction;
      case NetworkType.tron:
        return tronTransfer;
      case NetworkType.solana:
        return solanaTransfer;
      case NetworkType.aptos:
        return aptosTransfer;
      case NetworkType.sui:
        return suiTransfer;

      case NetworkType.ton:
        return tonTransfer;
      case NetworkType.cardano:
        return cardanoTransaction;
      case NetworkType.cosmos:
        return cosmosTransfer;
      case NetworkType.substrate:
        return substrateTransfer;
      case NetworkType.stellar:
        return stellarTransaction;
      case NetworkType.monero:
        return moneroTransfer;
      case NetworkType.xrpl:
        return rippleTransfer;

      default:
        throw UnimplementedError();
    }
  }

  static String? web3Page(WalletNetwork network) {
    switch (network.type) {
      case NetworkType.ethereum:
        return web3Ethereum;
      case NetworkType.solana:
        return web3Solana;
      case NetworkType.tron:
        return web3Tron;
      case NetworkType.ton:
        return web3Ton;
      case NetworkType.stellar:
        return web3Stellar;
      case NetworkType.substrate:
        return web3Substrate;
      case NetworkType.aptos:
        return web3Aptos;
      case NetworkType.sui:
        return web3Sui;
      case NetworkType.cosmos:
        return web3Cosmos;
      case NetworkType.bitcoinCash:
      case NetworkType.bitcoinAndForked:
        return web3Bitcoin;
      default:
        return null;
    }
  }

  static String? importNetwork(NetworkType type) {
    switch (type) {
      case NetworkType.ethereum:
        return importEthereumNetwork;
      case NetworkType.cosmos:
        return importCosmosNetwork;
      case NetworkType.substrate:
        return importSubstrateNetwork;
      default:
        return null;
    }
  }

  static String? multisigAccountInfo(NetworkType type) {
    switch (type) {
      case NetworkType.bitcoinAndForked:
        return bitcoinMultisigAccountInfo;
      case NetworkType.bitcoinCash:
        return bitcoinCashMultisigAccountInfo;
      case NetworkType.sui:
        return suiMultisigAccountInfo;
      case NetworkType.aptos:
        return aptosMultisigAccountInfo;
      default:
        return null;
    }
  }

  static String? networkSettings(WalletNetwork network) {
    switch (network.type) {
      case NetworkType.ton:
        return tonSettings;
      case NetworkType.monero:
        return moneroSettings;
      case NetworkType.xrpl:
        return rippleSettingPage;
      case NetworkType.stellar:
        return stellarSettingPage;
      case NetworkType.solana:
        return solanaSettingPage;
      case NetworkType.sui:
        return suiSettingPage;
      case NetworkType.aptos:
        return aptosSettingPage;
      default:
        return null;
    }
  }
}
