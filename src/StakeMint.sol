//SPDX-License-Identfier:MIT
pragma solidity >=0.8.0 <0.9.0;

import {IStakeMint} from "../src/interfaces/IStakeMint.sol";
import {Owner} from "../src/helpers/Owner.sol";
import {Errors} from "../src/helpers/Errors.sol";
import {PriceConverter} from "../src/helpers/PriceConverter.sol";
import {ERC20TokenInterface} from "../src/interfaces/IERC20TokenInterface.sol";

contract StakeMint is IStakeMint, Owner, Errors {
    using PriceConverter for uint256;

    struct Assets {
        string name;
        address assetContractAddress;
        address priceFeedContractAddress;
    }
    // list of all assets allowed for deposit

    Assets[] private s_assets;
    //The amount of the value locked in US Dollar
    uint256 private s_tvl;
    // tracks the quantity of the asset in the contract. Eg 24WrappedEth

    // dollar value of all asset user locked in contract
    mapping(address depositorAddress => uint256 dollarValueLocked)
        private s_userValueLocked;

    // Quantity amount of a particular asset locked my a user. Eg how many WrappedEth
    mapping(address depositorAddress => mapping(address assetContractAddress => uint256 amount))
        private s_userAssetLocked;

    function addAsset(
        string calldata _name,
        address _assetContractAdress,
        address _assetPriceFeed
    ) public onlyOwner(getOwner()) returns (bool) {
        //Creating a new asset
        Assets memory newAsset = Assets({
            name: _name,
            assetContractAddress: _assetContractAdress,
            priceFeedContractAddress: _assetPriceFeed
        });
        // Pushing the new asset to the list
        s_assets.push(newAsset);
        emit AssetAdded(
            msg.sender,
            _assetContractAdress,
            _name,
            _assetPriceFeed,
            block.timestamp
        );
        return true;
    }

    function withdraw(
        uint256 _amount,
        uint256 _assetIndex
    ) public checkIndex(_assetIndex, s_assets.length) returns (bool) {
        //Read asset index from the list
        Assets memory asset = s_assets[_assetIndex];

        //check if user have enough balance deposited
        userBalanceInContract(
            s_userAssetLocked[msg.sender][asset.assetContractAddress],
            _amount
        );

        // convert the amount to USD
        uint256 amountInUsd = _amount.valueConverter(
            asset.priceFeedContractAddress
        );
        //Subtract the dollar value from user value locked in dollar
        s_userValueLocked[msg.sender] -= amountInUsd;

        //Subtract the dollar value from contract value locked in dollar
        s_tvl -= amountInUsd;

        // Subtract the amount from the asset valued locked by user
        s_userAssetLocked[msg.sender][asset.assetContractAddress] -= _amount;

        ERC20TokenInterface token = ERC20TokenInterface(
            asset.assetContractAddress
        );

        // Transfer the token amount requested to the sender
        bool isSucessful = token.transfer(msg.sender, _amount);

        // Check if the transfer was successful
        transactionIsuccessful(isSucessful);
        emit Withdraw(
            msg.sender,
            _amount,
            asset.name,
            asset.assetContractAddress
        );
        return true;
    }

    function deposit(
        uint256 _value,
        uint256 _assetIndex
    ) public checkIndex(_assetIndex, s_assets.length) returns (bool) {
        Assets memory asset = s_assets[_assetIndex];
        ERC20TokenInterface erc20Token = ERC20TokenInterface(
            asset.assetContractAddress
        );
        uint256 allowance = erc20Token.allowance(msg.sender, address(this));
        allowanceCheck(allowance, _value);
        bool isTransfered = erc20Token.transferFrom(
            msg.sender,
            address(this),
            _value
        );
        transactionIsuccessful(isTransfered);
        uint256 value = _value.valueConverter(asset.priceFeedContractAddress);
        s_tvl += value;
        s_userValueLocked[msg.sender] += value;
        emit Deposited(
            msg.sender,
            _value,
            asset.name,
            asset.assetContractAddress
        );
        return true;
    }

    function withdrawContractBalance(
        address asset,
        uint256 amount,
        address receiver
    ) public onlyOwner(getOwner()) balanceCheck(asset, address(this), amount) {
        ERC20TokenInterface token = ERC20TokenInterface(asset);
        bool isTransfered = token.transfer(receiver, amount);
        transactionIsuccessful(isTransfered);
    }

    /**
     * getters
     *
     */

    //TVL(total value locked in US dollar)
    function checkContractTotalValueLocked() public view returns (uint256) {
        return s_tvl;
    }

    // get total number of a asset locked in the contract
    function getContractAssetValueLocked(
        address asset
    ) public view returns (uint256) {
        ERC20TokenInterface token = ERC20TokenInterface(asset);
        uint256 balance = token.balanceOf(address(this));
        return balance;
    }
    //User total value Locked In dollar

    function getUserTotalValueLocked(
        address _user
    ) public view returns (uint256) {
        return s_userValueLocked[_user];
    }
    // get amount of an asset a user locked in contract

    function getUserAssetValueLocked(
        address _user,
        address _asset
    ) public view returns (uint256) {
        return s_userAssetLocked[_user][_asset];
    }

    function getAllowedAssets() public view returns (Assets[] memory) {
        return s_assets;
    }
}
