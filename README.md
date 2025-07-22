# 🏦 FundMe Smart Contract Project

A sample Ethereum smart contract built with [Foundry](https://book.getfoundry.sh/) that allows users to fund a contract with ETH based on the real-time ETH/USD price from a Chainlink price feed. Only the contract owner can withdraw funds. The project supports both local development with mocks and real deployments on Sepolia or zkSync.

This project was developed as part of Cyfrin Updraft's Solidity Smart Contract Developer Foundry Fundamentals course, serving as a hands-on learning experience with Foundry, smart contracts, and Chainlink oracles

---

## 🧰 Features

- 🪙 `FundMe.sol` contract that:
  - Accepts ETH funding if above a minimum USD threshold.
  - Supports real-time conversion via Chainlink price feed.
  - Restricts withdrawal access to the contract owner.
  - Emits `Funded` and `Withdrawn` events.

- 🔬 Full test coverage:
  - Unit and integration tests with [Forge](https://book.getfoundry.sh/forge/).
  - zkSync-compatible test helpers.
  - Mock support for local environments.

- 🧪 MockV3Aggregator contract for testing price feed logic.

- 🛠️ Script-based deployment and interaction:
  - `DeployFundMe.s.sol` for deployment.
  - `Interactions.s.sol` for funding and withdrawing.
  - `HelperConfig.s.sol` for per-network configuration.


## 🚀 Getting Started

### 🛠 Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation) (install with `curl -L https://foundry.paradigm.xyz | bash`)
- Optional: Alchemy or Infura RPC for testnet deployment

### 📦 Install Dependencies

```bash
forge install
```

### 🔨 Compile Contracts

```bash
forge build
```

### 🧪 Run Tests

```bash
forge test
```

### 🧪 Test Coverage

```bash
forge coverage
```

### ▶️ Run Specific Test

```bash
forge test --match-test testWithdrawFromASingleFunder -vvvv
```

### ⚙️ Run zkSync-related Tests

```bash
forge test --zksync
```
🔁 Requires ffi = true and zkSync Foundry toolchain.

### 📤 Deploy Contract

🖥 Local / Anvil

```bash
forge script script/DeployFundMe.s.sol:DeployFundMe \
  --rpc-url http://localhost:8545 \
  --broadcast \
  --legacy
```
🌐 Sepolia or Custom Network

```bash
forge script script/DeployFundMe.s.sol:DeployFundMe \
  --rpc-url <YOUR_RPC_URL> \
  --broadcast \
  --verify
```

### 🧬 Configuration

Update chain-specific values in HelperConfig.s.sol:

```
uint256 public constant LOCAL_CHAIN_ID = 31337;
uint256 public constant ETH_SEPOLIA_CHAIN_ID = 11155111;
uint256 public constant ZKSYNC_SEPOLIA_CHAIN_ID = 300;

```
Each network is associated with a real or mock Chainlink price feed.

### 📁 Project Structure

```
├── src/                  # Main contract code (e.g., FundMe.sol)
├── script/               # Deployment & helper scripts
├── test/                 # Unit and integration tests
├── lib/                  # External dependencies (e.g., foundry-devops)
├── foundry.toml          # Foundry project configuration

```

### 📜 License
MIT