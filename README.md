# About MRT Wallet

Welcome to MRT Wallet, the open-source wallet crafted for the decentralized future of finance. Our mission is to provide users with a secure and versatile solution supporting a wide range of cryptocurrencies, including Bitcoin, Bitcoin Cash, Litecoin, Dogecoin, Dash, Ethereum, Tron, Ripple, Solana, Cardano, Cosmos, Monero, Sui, Aptos, Polkadot, and Kusama. Our roadmap includes cross-platform support across Android, Windows, macOS, web, and extensions for Chrome, Brave, and Mozilla Firefox.

## Networks

### Bitcoin and forked networks

- **Features:** Full support for Bitcoin and transactions on forked Bitcoin-based networks.
- **Supported Networks:** Bitcoin, Bitcoin Cash, Litecoin, Dogecoin, Dash, Bitcoin SV, and more.
- **Web3:** Wallet Standard. (available on Chrome, Brave, Firefox, Microsoft Edge, Android, and macOS platforms.). [examples](https://github.com/mrtnetwork/mrt_wallet_web3_js_examples/blob/main/public/scripts/bitcoin.mjs)


### Ripple

- **Features:** Unlocking the potential of the Ripple network.
- **Highlights:** Comprehensive support for advanced cryptographic algorithms, NFTs, tokens, multisignature transactions, account settings, trust settings, escrow transactions, regular key settings, and more.


### Solana

- **Features:** Seamless support for Solana transactions.
- **Highlights:**
  - SPLToken transfer, account creation and token minting.
- **Web3:** Wallet Standard. (available on Chrome, Brave, Firefox, Microsoft Edge, Android, and macOS platforms.). [examples](https://github.com/mrtnetwork/mrt_wallet_web3_js_examples/blob/main/public/scripts/ws_solana.mjs)


### Cardano

- **Features:** Streamlined support for Cardano transactions.
- **Highlights:**
  - Full compatibility with Shelley and Byron addresses and transactions.
  - Facilitates minting and transfer of assets.
  - Integration for stake certificates.
  - Allows for multiple account transactions.


### Ethereum

- **Features:** Support for Ethereum transactions.
- **Highlights:** Compatibility with both legacy and EIP-1559 transactions. Import and manage ERC-20 assets effortlessly, and execute ERC-20 token transfers with ease.
- **Web3:** Wallet Standard, EIP-1193 and EIP-6963. (available on Chrome, Brave, Firefox, Microsoft Edge, Android, and macOS platforms.). [examples](https://github.com/mrtnetwork/mrt_wallet_web3_js_examples/tree/main/public/scripts)

### Tron

- **Features:** Seamless interaction with the Tron blockchain.
- **Highlights:** Confidence in sending TRX, TRC-20, and TRC-10 tokens. Support for native contracts, including multi-signature transactions. Control over updating account permissions, managing accounts, unstaking (v2), delegating resources, and creating/updating witnesses.
- **Web3:** Wallet Standard and TIP-1193. (available on Chrome, Brave, Firefox, Microsoft Edge, Android, and macOS platforms.). [examples](https://github.com/mrtnetwork/mrt_wallet_web3_js_examples/tree/main/public/scripts)


### Cosmos

- **Features:** Seamless support for Cosmos transactions.
- **Highlights:**
  - Support for Secp256k1, Secp256r1, Ed25519, and ETHSecp256k1
  - Supports importing networks based on forked Cosmos and Evmos chains.
- **Web3:** Wallet Standard. (available on Chrome, Brave, Firefox, Microsoft Edge, Android, and macOS platforms.). [examples](https://github.com/mrtnetwork/mrt_wallet_web3_js_examples/blob/main/public/scripts/ws_cosmos.mjs)


### Ton

- **Features:** Seamless support for Ton transactions.
- **Highlights:** Jetton transfer, multiple message transfer.
- **Web3:** Wallet Standard. (available on Chrome, Brave, Firefox, Microsoft Edge, Android, and macOS platforms.). [examples](https://github.com/mrtnetwork/mrt_wallet_web3_js_examples/blob/main/public/scripts/ws_ton.mjs)


### Stellar

- **Features:** Seamless Stellar transaction support.
- **Highlights:** Supports Payment, ChangeTrust, PathPayment, ManageBuyOffer, ManageSellOffer, and more.
- **Web3:** Wallet Standard. (available on Chrome, Brave, Firefox, Microsoft Edge, Android, and macOS platforms.). [examples](https://github.com/mrtnetwork/mrt_wallet_web3_js_examples/blob/main/public/scripts/ws_stellar.mjs)


### Substrate

- **Features:** Provides seamless support for Kusama, Polkadot transactions, and standalone chains.
- **Highlights:** Enables importing Substrate networks, interacting with metadata, creating extrinsics, querying storage, and making runtime calls.
- **Web3:** Wallet Standard and polkadotJs injected provider. (available on Chrome, Brave, Firefox, Microsoft Edge, Android, and macOS platforms.). [examples](https://github.com/mrtnetwork/mrt_wallet_web3_js_examples/blob/main/public/scripts/ws_substrate.mjs)


### Monero

- **Features:** Seamless support for Monero transactions, Generate and verify proof.


### SUI

- **Features:** Seamless support for Sui transactions.
- **Highlights:** Coin management, Multisig.
- **Web3:** Wallet Standard. (available on Chrome, Brave, Firefox, Microsoft Edge, Android, and macOS platforms.). [examples](https://github.com/mrtnetwork/mrt_wallet_web3_js_examples/blob/main/public/scripts/ws_sui.mjs)


### Aptos

- **Features:** Seamless support for Aptos transactions.
- **Highlights:** Coin management, Multikey, MultiED25519.
- **Web3:** Wallet Standard. (available on Chrome, Brave, Firefox, Microsoft Edge, Android, and macOS platforms.). [examples](https://github.com/mrtnetwork/mrt_wallet_web3_js_examples/blob/main/public/scripts/ws_aptos.mjs)


## Platform Support

MRT Wallet is available on multiple platforms to provide a seamless experience:

- **Android:** Take your wallet on the go with our Android app, ensuring you have secure access to your funds anytime, anywhere.

- **Windows:** Enjoy the convenience of MRT Wallet on your desktop. Our Windows version brings the power of decentralized finance to your fingertips.

- **Macos:** Enjoy the convenience of MRT Wallet on your desktop. Our Mac version brings the power of decentralized finance to your fingertips.

- **Web:** Access your wallet from any web browser with our web platform. Manage your assets with ease, all while enjoying the security and privacy MRT Wallet provides.

- **Browser Extensions:** Integrate seamlessly with your browser using our extensions for Chrome, Brave, and Mozilla Firefox, enhancing your web-based financial interactions.


## Build Instructions

Clone the repository and build using Flutter:

- **WEB**

 you can view the web version of MRT Wallet at <https://mrtnetwork.github.io/mrtwallet/>.

```shell
gh repo clone mrtnetwork/mrtwallet
cd mrt_wallet
dart run web_builder.dart -web --wasm --crypto --release --clean
```

- **Chrome, Edge, Brave extention**

```shell
gh repo clone mrtnetwork/mrtwallet
cd mrt_wallet
dart run web_builder.dart -extension --wasm --scripts --crypto --release --clean
```

- **Firefox extention**

```shell
gh repo clone mrtnetwork/mrtwallet
cd mrt_wallet
dart run web_builder.dart -extension --wasm --scripts --crypto --release --clean --mozila
```


- **Android**

```shell
gh repo clone mrtnetwork/mrtwallet
cd mrt_wallet
flutter pub get
flutter build apk 
```

- **Windows**

```shell
gh repo clone mrtnetwork/mrtwallet
cd mrt_wallet
flutter pub get
flutter build windows --release
```

- **Macos**

```shell
gh repo clone mrtnetwork/mrtwallet
cd mrt_wallet
flutter pub get
flutter build macos --release
```


## Community-Driven Development

MRT Wallet is not just a wallet; it's a community-driven project. We welcome collaboration, feedback, and contributions from the community. Together, we're building a decentralized future that prioritizes security, privacy, and inclusivity.


## Contributing

Contributions are welcome! Please follow these guidelines:

- Fork the repository and create a new branch.
- Make your changes and ensure tests pass.
- Submit a pull request with a detailed description of your changes.

## Feature requests and bugs

Please file feature requests and bugs in the issue tracker.

## Get Involved

Join us on our mission to redefine the landscape of decentralized finance. Contribute to our open-source project on [GitHub](https://github.com/mrtnetwork/mrtwallet) or connect with our community on [Telegram](https://t.me/blockchain_web3_solidity).

Thank you for choosing MRT Wallet as your trusted partner in the world of decentralized finance.

## Support

1KMRGUzRFCuR9y73gUnjxfC1Dte8Ua3vcp

bc1q92fvc5jm4k8e5wegzmhzdv72gwe43sgfnuspgzfmj7llkd8xhmusgd44qf
