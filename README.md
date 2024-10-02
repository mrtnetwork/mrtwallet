# About MRT Wallet

Welcome to MRT Wallet, the open-source wallet crafted for the decentralized future of finance. Our mission is to provide users with a secure and versatile solution supporting a wide range of cryptocurrencies, including Bitcoin, Bitcoin Cash, Litecoin, Dogecoin, Dash, Ethereum, Tron, Ripple, Solana, Cardano, Cosmos, Polkadot, and Kusama. Our roadmap includes cross-platform support across Android, Windows, macOS, web, and extensions for Chrome, Brave, and Mozilla Firefox.

## Networks

### Bitcoin

- **Features:** Comprehensive support for Bitcoin transactions.
- **Highlights:**
  - Robust support for P2TR, P2WPKH, P2WSH, P2SH, P2PKH, and multisignature functionalities.
  - Enhanced control over transactions, allowing you to effortlessly create, sign, and send transactions from multiple UTXOs and addresses.
  - Allows for multiple account transactions.

### Bitcoin Cash

- **Features:** Comprehensive support for Bitcoin Cash transactions.
- **Highlights:**
  - P2SH, P2SH32, P2PKH and token-aware addresses.
  - Enhanced control over transactions, supporting the creation, signing, minting and sending of Cash tokens.
  - Allows for multiple account transactions.

### Dogecoin

- **Features:** Seamless transaction creation and management on the Dogecoin network.
- **Highlights:** Extends capabilities to the playful realm of Dogecoin, ensuring a smooth and secure user experience.
- Allows for multiple account transactions.

### Dash

- **Features:** Exploration of the fast and efficient world of Dash.
- **Highlights:** Easy creation, signing, and sending of transactions with support for various Dash network functionalities.
- Allows for multiple account transactions.

### Bitcoin SV

- **Features:** Effortless navigation of Bitcoin SV transactions.
- **Highlights:**
  - User-friendly interface for smooth and secure transaction creation and management.
  - Support for handling P2PKH addresses, simplifying the Bitcoin SV experience.
  - Allows for multiple account transactions.

### Litecoin

- **Features:** Support for Litecoin transactions.
- **Highlights:** Dive into the silver to Bitcoin's gold with MRT Wallet, managing Litecoin transactions effortlessly with confidence.
- Allows for multiple account transactions.

### Ripple

- **Features:** Unlocking the potential of the Ripple network.
- **Highlights:** Comprehensive support for advanced cryptographic algorithms, NFTs, tokens, multisignature transactions, account settings, trust settings, escrow transactions, regular key settings, and more.

### Solana

- **Features:** Seamless support for Solana transactions.
- **Highlights:**
  - SPLToken transfer, account creation and token minting.
- **Web3 Support** Added support for interacting with Web3 on Chrome, Brave, Mozilla Firefox, Microsoft Edge, Android and macos platforms.

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
- **Web3 Support** Added support for interacting with Web3 on Chrome, Brave, Mozilla Firefox, Microsoft Edge, Android and macos platforms ([EIP-1193](https://eips.ethereum.org/EIPS/eip-1193), [EIP-6963](https://eips.ethereum.org/EIPS/eip-6963)).

### Tron

- **Features:** Seamless interaction with the Tron blockchain.
- **Highlights:** Confidence in sending TRX, TRC-20, and TRC-10 tokens. Support for native contracts, including multi-signature transactions. Control over updating account permissions, managing accounts, unstaking (v2), delegating resources, and creating/updating witnesses.
- **Web3 Support** Added support for interacting with Web3 on Chrome, Brave, Mozilla Firefox , Microsoft Edge, Android and macos platforms ([TIP-1193](https://github.com/tronprotocol/tips/blob/master/tip-1193.md)).

### Cosmos

- **Features:** Seamless support for Cosmos transactions.

### Thor

- **Features:** Seamless support for Thor transactions.

### Maya

- **Features:** Seamless support for Maya transactions.

### Ton

- **Features:** Seamless support for Ton transactions.
- **Highlights:** Jetton transfer, multiple message transfer.
- **Web3 Support** Added support for interacting with Web3 on Chrome, Brave, Mozilla Firefox, Microsoft Edge, Android and macos platforms.

### Stellar

- **Features:** Seamless Stellar transaction support.
- **Highlights:** Supports Payment, ChangeTrust, PathPayment, ManageBuyOffer, ManageSellOffer, and more.
- **Web3 Support** Compatible with Web3 on Chrome, Brave, Firefox, Edge, Android, and macOS for Soroban and native Stellar transactions.



### Kusama

- **Features:** Seamless support for Kusama transactions.

### Polkadot

- **Features:** Seamless support for Polkadot transactions.


## Web3

Added Web3 support for select networks. Check `mrt_wallet_web3_js_examples` folder for instructions on sending Web3 transactions to the wallet.


## Decentralized, Secure, and Open Source

At MRT Wallet, we believe in the power of decentralization. Our commitment to decentralization is at the core of our design philosophy, providing you with full control over your assets. Your private keys remain in your hands, ensuring the highest level of security.

We take pride in being fully open source. You can explore and audit our code on [GitHub](https://github.com/mrtnetwork/mrtwallet) under the Apache License 2.0. This commitment to transparency means that every line of code is accessible, empowering the community to verify the security and integrity of our wallet.


## Platform Support

MRT Wallet is available on multiple platforms to provide a seamless experience:

- **Android:** Take your wallet on the go with our Android app, ensuring you have secure access to your funds anytime, anywhere.

- **Windows:** Enjoy the convenience of MRT Wallet on your desktop. Our Windows version brings the power of decentralized finance to your fingertips.

- **Macos:** Enjoy the convenience of MRT Wallet on your desktop. Our Mac version brings the power of decentralized finance to your fingertips.

- **Web:** Access your wallet from any web browser with our web platform. Manage your assets with ease, all while enjoying the security and privacy MRT Wallet provides.

- **Browser Extensions:** Integrate seamlessly with your browser using our extensions for Chrome, Brave, and Mozilla Firefox, enhancing your web-based financial interactions.


## Community-Driven Development

MRT Wallet is not just a wallet; it's a community-driven project. We welcome collaboration, feedback, and contributions from the community. Together, we're building a decentralized future that prioritizes security, privacy, and inclusivity.

## Build Instructions

Clone the repository and build using Flutter:

- **WEB**

 you can view the web version of MRT Wallet at <https://mrtnetwork.github.io/mrtwallet/>.

```shell
gh repo clone mrtnetwork/mrtwallet
cd mrt_wallet
dart run web_builder -web --release --clean
```

- **Chrome/Brave extention**

```shell
gh repo clone mrtnetwork/mrtwallet
cd mrt_wallet
dart run web_builder -extention --release --clean
```

- **Firefox extention**

```shell
gh repo clone mrtnetwork/mrtwallet
cd mrt_wallet
dart run web_builder -extention --mozila --release --clean
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
