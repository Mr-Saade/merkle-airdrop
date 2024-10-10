# Merkle Airdrop

- [Merkle Airdrop](#merkle-airdrop)
- [Getting Started](#getting-started)
  - [Requirements](#requirements)
  - [Quickstart](#quickstart)
- [Usage](#usage)
  - [Pre-deploy: Generate merkle proofs](#pre-deploy-generate-merkle-proofs)
- [Deploy](#deploy)
  - [Deploy to Anvil](#deploy-to-anvil)
  - [Interacting - Local anvil network](#interacting---local-anvil-network)
    - [Setup anvil and deploy contracts](#setup-anvil-and-deploy-contracts)
    - [Sign your airdrop claim](#sign-your-airdrop-claim)
    - [Claim your airdrop](#claim-your-airdrop)
    - [Check claim amount](#check-claim-amount)
  - [Testing](#testing)
    - [Test Coverage](#test-coverage)
  - [Estimate gas](#estimate-gas)
- [Formatting](#formatting)
- [Thank you!](#thank-you)

# Getting Started

## Requirements

- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
  - You'll know you did it right if you can run `git --version` and you see a response like `git version x.x.x`
- [foundry](https://getfoundry.sh/)
  - You'll know you did it right if you can run `forge --version` and you see a response like `forge 0.2.0 (816e00b 2023-03-16T00:05:26.396218Z)`

To get started, we are assuming you're working with vanilla `foundry` and not `foundry-zksync` to start.

## Quickstart

```bash
git clone https://github.com/MrSaade/merkle-airdrop
cd merkle-airdrop
make # or forge install && forge build if you don't have make
```

# Usage

## Pre-deploy: Generate merkle proofs

We are going to generate merkle proofs for an array of addresses to airdrop funds to. If you'd like to work with the default addresses and proofs already created in this repo, skip to [deploy](#deploy)

If you'd like to work with a different array of addresses (the `whitelist` list in `GenerateInput.s.sol`), you will need to follow the following:

First, the array of addresses to airdrop to needs to be updated in `GenerateInput.s.sol. To generate the input file and then the merkle root and proofs, run the following:

Using make:

```bash
make merkle
```

Or using the commands directly:

```bash
forge script script/GenerateInput.s.sol:GenerateInput && forge script script/MakeMerkle.s.sol:MakeMerkle
```

Then, retrieve the `root` (there may be more than 1, but they will all be the same) from `script/target/output.json` and update `s_merkleRoot` in `DeployMerkleAirdrop.s.sol`.

# Deploy

## Deploy to Anvil

```bash
# Optional, ensure you're on vanilla foundry
foundryup
# Run a local anvil node
make anvil
# Then, in a second terminal
make deploy
```

## Interacting - Local anvil network

### Setup anvil and deploy contracts

Run an anvil node:

```bash
foundryup
make anvil
make deploy
# Copy the BagelToken address & Airdrop contract address
```

Copy the Bagel Token and Aidrop contract addresses and paste them into the `AIRDROP_ADDRESS` and `TOKEN_ADDRESS` variables in the `MakeFile`

The following steps allow the second default anvil address (`0x70997970C51812dc3A010C7d01b50e0d17dc79C8`) to call claim and pay for the gas on behalf of the first default anvil address (`0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266`) which will recieve the airdrop.

### Sign your airdrop claim

```bash
# in another terminal
make sign
```

Retrieve the signature bytes outputted to the terminal and add them to `Interact.s.sol` _making sure to remove the `0x` prefix_.

Additionally, if you have modified the claiming addresses in the merkle tree, you will need to update the proofs in this file too (which you can get from `output.json`)

### Claim your airdrop

Then run the following command:

```bash
make claim
```

### Check claim amount

Then, check the claiming address balance has increased by running

```bash
make balance
```

NOTE: `0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266` is the default anvil address which has recieved the airdropped tokens.

## Testing

```bash
foundryup
forge test
```

### Test Coverage

```bash
forge coverage
```

## Estimate gas

You can estimate how much gas things cost by running:

```
forge snapshot
```

And you'll see an output file called `.gas-snapshot`

# Formatting

To run code formatting:

```
forge fmt
```

# Thank you!
