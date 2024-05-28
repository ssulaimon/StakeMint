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
    mapping(address assetAddress => uint256 assetQuantity) private s_assetLocked;
    // dollar value of all asset user locked in contract
    mapping(address depositorAddress => uint256 dollarValueLocked) private s_userValueLocked;

    // Quantity amount of a particular asset locked my a user. Eg how many WrappedEth
    mapping(address depositorAddress => mapping(address assetContractAddress => uint256 amount)) private
        s_userAssetLocked;

    function addAsset(string calldata _name, address _assetContractAdress, address _assetPriceFeed)
        public
        onlyOwner(getOwner())
        returns (bool)
    {
        Assets memory newAsset =
            Assets({name: _name, assetContractAddress: _assetContractAdress, priceFeedContractAddress: _assetPriceFeed});
        s_assets.push(newAsset);
        return true;
    }

    function withdraw() public returns (bool) {}

    function deposit(uint256 _value, address _priceFeedAddress, uint256 _assetIndex)
        public
        checkIndex(_assetIndex, s_assets.length)
        returns (bool)
    {
        Assets memory asset = s_assets[_assetIndex];
        ERC20TokenInterface erc20Token = ERC20TokenInterface(asset.assetContractAddress);
        uint256 allowance = erc20Token.allowance(msg.sender, address(this));
        allowanceCheck(allowance, _value);
        uint256 value = _value.valueConverter(_priceFeedAddress);
        s_assetLocked[asset.assetContractAddress] = _value;
        s_tvl += value;
        s_userValueLocked[msg.sender] += value;
        return true;
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
    function getContractAssetValueLocked(address asset) public view returns (uint256) {
        return s_assetLocked[asset];
    }
    //User total value Locked In dollar

    function getUserTotalValueLocked(address _user) public view returns (uint256) {
        return s_userValueLocked[_user];
    }
    // get amount of an asset a user locked in contract

    function getUserAssetValueLocked(address _user, address _asset) public view returns (uint256) {
        return s_userAssetLocked[_user][_asset];
    }
}
