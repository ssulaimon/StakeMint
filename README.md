# Project Name: Stakemint

## Description

Stakemint is a decentralized finance (DeFi) project where users can earn DAO tokens on their asset deposits within the protocol. Currently, the following assets are supported:
- AAVE
- USDT
- USDC
- WrappedETH (WETH)

More assets will be added in the future. The DAO token grants users decentralized voting rights within the protocol. The expected reward is 4% APY, which may change depending on the amount of tokens already distributed.

## Available Functions in the Contract

1. **depositAssets(assetIndex, amount)**:
   - Description: Allows users to deposit a specified amount of a supported asset into the protocol.
   - Parameters:
     - `index`: This is the assets index in the allowed asset list.
     - `amount`: The amount of the asset to deposit.

2. **withdrawAsset(asset, assetIndex)**:
   - Description: Allows users to withdraw a specified amount of a previously deposited asset from the protocol.
   - Parameters:
     - `asset`: The type of asset to withdraw.
     - `amount`: The amount of the asset to withdraw.

3. **claimRewards(assetIndex)**:
   - Description: Allows users to claim their earned DAO tokens based on their deposits.
   - Parameters:
        - `index`: The index of the asset to claim reward
   

## Owner Functions

4. **addAsset(name, contractAddress)**:
   - Description: Allows the protocol administrators to add a new supported asset.
   - Parameters:
     - `contractAddress`: The new asset to be added contract address (e.g., DAI).
     - `name`: The name of the asset 



## Getting Started

To interact with the Stakemint contract, you will need a Web3-compatible wallet and some cryptocurrency to deposit. Follow these steps:

1. **Connect your wallet**: Use a mobile Web3 provider like MetaMask to connect your wallet to the Stakemint protocol mobile.
2. **Select Asset**: Choose from the list of asset which you like to deposit
3. **Navigate To Stake**: Selecting the asset would navigate you to available functions in the app such as receive, send, stake. Select the stake to deposit.
4. **DEFI actions**: You can either stake, unstake or claim reward in the staking screen


## Contribution
For contributing or Issues you can raise an issue 

## Download

You can download the latest release of Stakemint [here](https://drive.google.com/file/d/1AsbJCSh6sxcwWU1_M7qqSd1K7HdMfOzK/view?usp=sharing).

## License

Stakemint is released under the MIT License.
