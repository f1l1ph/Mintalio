## Mintalio

### Problem

Traditional loyalty programs often struggle with low customer engagement, lack of personalization, and limited customer ownership over rewards. They are typically centralized and offer generic, non-transferable points that fail to excite users, leading to decreased interest and participation.

### Proposed Solution

NFT-based loyalty programs solve these issues by leveraging blockchain technology to create unique, verifiable digital assets that customers truly own. These programs enhance engagement through exclusivity and gamification, provide transparency with immutable transaction records, and allow for transferability and potential value appreciation of rewards. This innovative approach revitalizes customer interest and offers a more personalized and empowering loyalty experience.

### Design

The goal is to develop a blockchain-based loyalty program where each user owns a unique loyalty card represented as an NFT, and accrues loyalty points represented as fungible tokens. Utilizing the [ERC-1155](https://ethereum.org/en/developers/docs/standards/tokens/erc-1155/) standard allows us to manage both token types within a single smart contract, enhancing efficiency and reducing deployment complexity.

#### **Smart Contract Structure**

The smart contract will be an ERC-1155 implementation that handles multiple token types:

1. **Loyalty Card NFTs (Non-Fungible Tokens):**

   - Each loyalty card is a unique NFT with a specific token ID.
     - Metadata associated with each NFT loyalty level.

1. **Loyalty Points:**
   - Loyalty points are represented as a simple `uint` associated with each NFT.
   - The contract deployer can assign and manage points for each loyalty card using dedicated functions.
   - Points can be accumulated and redeemed by users based on their loyalty status.

##### **1. Loyalty Card Implementation**

- **Minting Loyalty Cards:**
  - When a user joins the loyalty program, a unique NFT loyalty card is minted and assigned to their wallet address.
  - The token ID for each card is unique, ensuring non-fungibility.
- **Metadata Management:**
  - Metadata for each loyalty card includes:
    - Owner's wallet address.
    - Current loyalty level.
    - Other customizable attributes (e.g., membership tier).

##### **2. Loyalty Points System**

- **Earning Points:**
  - Users earn points through interactions such as purchases or participating in promotions.
  - The smart contract includes functions to increase a user's balance of loyalty point tokens.
  - Authorized addresses (e.g., the company's backend system) can call these functions securely.
- **Point Tracking:**
- Points are tracked by mapping user addresses to their `uint256` point balances.
- Points are managed as simple numeric values within the smart contract and are not represented as tokens.

#### **Leveling Mechanism**

- **Level Thresholds:**
  - Define levels (e.g., Silver, Gold, Platinum) based on point thresholds.
  - The smart contract checks point balances to determine if a user qualifies for a level upgrade.
- **Level Upgrades:**
  - Upon reaching a new level, the contract updates the user's loyalty card metadata.
  - Emits an event (`LevelUp`) that off-chain services can listen to for triggering additional actions (e.g., sending notifications via email).

#### **Point Redemption Process (Optional for now)**

- **Redeeming Points:**
  - Users can redeem points for rewards through functions in the smart contract.
  - The contract deducts the appropriate number of points from the user's balance.
  - Rewards can be:
    - Issued as new tokens (NFTs or fungible tokens).
    - Managed off-chain by emitting events for the backend to process.
- **Validation Checks:**
  - The contract ensures users have sufficient points before allowing redemption.
  - Includes safeguards against double-spending and unauthorized access.

#### **Security Considerations (Not in prototype, This is for future MVP)**

- **Access Control:**
  - Implement role-based access using OpenZeppelin's `AccessControl` library.
  - Only authorized accounts can mint tokens, adjust points, or modify levels.
- **Use of Audited Libraries:**
  - Base the contract on OpenZeppelin's ERC-1155 implementation to ensure compliance and security.
  - Regularly update dependencies to patch known vulnerabilities.
- **Data Integrity:**
  - All state-changing functions include proper validation.
  - Protect against common attacks like reentrancy, overflow/underflow, and unauthorized access.

#### **Integration with Backend Systems (Not in prototype, This is for future MVP)**

- **Event Listening:**
  - The backend system listens to contract events (e.g., `TransferSingle`, `LevelUp`) to update off-chain databases and trigger business logic.
- **API Development:**
  - Develop APIs that interact with the smart contract for functionalities like point allocation and redemption initiation.
- **User Interface:**
  - Build a user-friendly frontend that abstracts blockchain complexities.
  - Allow users to view their loyalty card, point balance, and available rewards.

#### **Testing and Auditing (Optional for now)**

- **Unit Testing:**
  - Write comprehensive tests covering all contract functionalities using frameworks like Truffle or Hardhat.
- **Security Audits:**
  - Perform internal code reviews and consider third-party audits to ensure contract security before deployment.

### Engineering

- Network: Base, Optimism or Arbitrum
- Smart contract language: Solidity
- Smart contract framework: Foundry

### Business Model

The business model capitalizes on multiple revenue streams:

- Charging of the trader's fee for rewinding and brokerage services
- Selling NFT loyalty cards and limited editions
- Earning royalties from secondary market trades (mint can be free and for every owner change there will be royalty fee)
- Boosting sales through heightened customer engagement (This opens up the possibility to charge merchants for points (purchases) made with these loyalty cards)

Additional opportunities include partnerships for co-branded NFTs:

- Subscription-based premium access
- Monetization of exclusive events
- Merchandise linked to the NFTs

By leveraging blockchain technology, the program reduces operational costs, enhances security, and builds customer trust through transparency and true ownership of rewards.

### Related Reading/Work

[Loyalty, Memberships and Ticketing: How NFTs Will Bring About Mass Adoption](https://www.coindesk.com/web3/2023/06/22/loyalty-memberships-and-ticketing-how-nfts-will-bring-about-mass-adoption/)

[NFT Loyalty Programs in Web3: Revolutionizing Customer Engagement and Loyalty Landscape](https://medium.com/predict/nft-loyalty-programs-in-web3-revolutionizing-customer-engagement-and-loyalty-landscape-a342c7ac3580)

## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
