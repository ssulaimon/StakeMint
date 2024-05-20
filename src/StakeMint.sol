//SPDX-License-Identifier:MIT
pragma solidity >=0.8.0 <0.9.0;

//0x9323C0F4eB8059648eE3f980547C79bEc9A8A46B

import {ERC20TokenInterface} from "./ITokenInterface.sol";

contract StakeMint {
    address owner;
    ERC20TokenInterface daoToken;
    uint256 public annualRate = 40000;
    mapping(address => mapping(address => uint256)) amountDeposited;
    mapping(address => mapping(address => uint)) timeDeposited;
    mapping(address => uint256) _assetTVL;
    event RewardClaimed(address indexed claimerAddress, uint256 indexed amount);
    event Deposited(address indexed depositor, uint256 indexed amount);
    event Withdraw(address indexed user, uint256 indexed amount);

    struct TransactionReciept {
        string assetName;
        uint256 amount;
        string functionCalled;
        uint16 decimal;
    }
    struct AllowedAssets {
        address contractAddress;
        string name;
    }

    AllowedAssets[] _allowedAssets;
    mapping(address => TransactionReciept[]) _transactionReciept;

    constructor(address _daoToken) {
        daoToken = ERC20TokenInterface(_daoToken);
        owner = msg.sender;
    }

    function transactionReciept(
        address _user
    ) public view returns (TransactionReciept[] memory) {
        return _transactionReciept[_user];
    }

    /**
    Get balance of dao tokens the contract holds for rewards
     */
    function daoTokenBalance() public view returns (uint256) {
        return daoToken.balanceOf(address(this));
    }

    /**
    view assets allowed for deposit in the contract
     */
    function allowedAssets() public view returns (AllowedAssets[] memory) {
        return _allowedAssets;
    }

    /**
    add an asset for earning purposes 
     */

    function addAssetAllowed(
        string memory _name,
        address _contractAddress
    ) public {
        require(msg.sender == owner, "Only owner can add asset");
        AllowedAssets memory asset = AllowedAssets({
            contractAddress: _contractAddress,
            name: _name
        });
        _allowedAssets.push(asset);
    }

    function decimal(string memory _assetName) internal pure returns (uint16) {
        bytes memory usdt = bytes("USDT");
        bytes memory usdc = bytes("USDC");
        bytes memory assetName = bytes(_assetName);
        if (
            keccak256(usdc) == keccak256(assetName) ||
            keccak256(usdt) == keccak256(assetName)
        ) {
            return 6;
        } else {
            return 18;
        }
    }

    /**
         amount of an asset locked up in the contract
        */
    function assetTVL(uint16 index) public view returns (uint256) {
        AllowedAssets memory asset = _allowedAssets[index];
        uint256 balance = _assetTVL[asset.contractAddress];
        return balance;
    }

    /**
    Deposit an asset to the contract
     */

    function depositAssets(uint256 _amount, uint16 _assetIndex) public {
        AllowedAssets memory asset = _allowedAssets[_assetIndex];
        uint16 assetDecimal = decimal(asset.name);
        ERC20TokenInterface token = ERC20TokenInterface(asset.contractAddress);
        uint256 allowance = token.allowance(msg.sender, address(this));
        require(allowance >= _amount, "Amount approve to be spent is lower");
        bool transfer = token.transferFrom(msg.sender, address(this), _amount);
        require(transfer, "Token not sent!!!");
        amountDeposited[msg.sender][asset.contractAddress] += _amount;
        timeDeposited[msg.sender][asset.contractAddress] = block.timestamp;
        _assetTVL[asset.contractAddress] += _amount;
        TransactionReciept memory reciept = TransactionReciept({
            assetName: asset.name,
            amount: _amount,
            functionCalled: "deposit",
            decimal: assetDecimal
        });
        _transactionReciept[msg.sender].push(reciept);
        emit Deposited(msg.sender, _amount);
    }

    /**
        calculate the amount an address is supposed to earn(DAO token)
        */
    function calculateReward(
        address _asset,
        address _userAddress
    ) internal view returns (uint256) {
        uint256 amount = amountDeposited[_userAddress][_asset];
        require(amount > 0, "You need to make deposit");
        uint256 daysUsed = (block.timestamp -
            timeDeposited[_userAddress][_asset]) / 1 days;
        require(daysUsed > 0, "No reward yet");

        uint256 dailyInterest = annualRate / 365;
        uint256 interest = dailyInterest * daysUsed;
        uint256 reward = (amount * interest) / 1000000;
        return reward;
    }

    /**
    view how much token the contract owe an address 
     */

    function checkReward(
        uint16 _index,
        address _userAddress
    ) public view returns (uint256) {
        AllowedAssets memory asset = _allowedAssets[_index];
        uint256 daysUsed = (block.timestamp -
            timeDeposited[_userAddress][asset.contractAddress]) / 1 days;

        if (amountDeposited[_userAddress][asset.contractAddress] == 0) {
            return 0;
        } else if (daysUsed <= 0) {
            return 0;
        } else {
            uint256 reward = calculateReward(
                asset.contractAddress,
                _userAddress
            );
            return reward;
        }
    }

    /**
    Claim earned tokens
     */
    function claimReward(uint16 _index) public {
        AllowedAssets memory asset = _allowedAssets[_index];
        uint16 assetDecimal = decimal(asset.name);
        uint256 expectedReward = checkReward(_index, msg.sender);
        daoToken.transfer(msg.sender, expectedReward);
        timeDeposited[msg.sender][asset.contractAddress] = block.timestamp;
        TransactionReciept memory reciept = TransactionReciept({
            assetName: "STM token",
            amount: expectedReward,
            functionCalled: "Claim Token",
            decimal: assetDecimal
        });

        _transactionReciept[msg.sender].push(reciept);
        emit RewardClaimed(msg.sender, expectedReward);
    }

    /**
    withdraw base asset 
     */

    function withdrawAsset(
        uint16 _index,
        uint256 _amount,
        address _ownerAddress
    ) public returns (bool) {
        AllowedAssets memory asset = _allowedAssets[_index];
        uint16 assetDecimal = decimal(asset.name);
        uint256 balance = amountDeposited[_ownerAddress][asset.contractAddress];
        require(balance > 0, "You don't have any token deposited");
        require(balance >= _amount, "You don't have enough balance");
        uint256 expectedReward = checkReward(_index, _ownerAddress);
        require(expectedReward == 0, "Please claim Dao token First!!");
        ERC20TokenInterface token = ERC20TokenInterface(asset.contractAddress);
        bool transfer = token.transfer(_ownerAddress, _amount);
        require(transfer, "Token not transfered");
        _assetTVL[asset.contractAddress] -= _amount;
        amountDeposited[_ownerAddress][asset.contractAddress] =
            amountDeposited[_ownerAddress][asset.contractAddress] -
            _amount;
        timeDeposited[_ownerAddress][asset.contractAddress] = 0;
        TransactionReciept memory reciept = TransactionReciept({
            assetName: asset.name,
            amount: _amount,
            functionCalled: "Withdraw",
            decimal: assetDecimal
        });
        _transactionReciept[_ownerAddress].push(reciept);
        emit Withdraw(_ownerAddress, _amount);
        return true;
    }

    function userBalanceInContract(
        uint16 index,
        address _owner
    ) public view returns (uint256) {
        AllowedAssets memory asset = _allowedAssets[index];
        return amountDeposited[_owner][asset.contractAddress];
    }
}
