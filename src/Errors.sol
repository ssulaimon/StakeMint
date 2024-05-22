//SPDX-License-Identifier:MIT
pragma solidity >=0.8.0 <0.9.0;

error Error__OnlyOwner();

error Error__InsufficientAllowance();
error Error__TokenIsNotTransfered();
error Error__InsufficientBalance();
error Error__DepositAmountTooLow();

error Error__NoRewardYet();

error Error_OutOfIndex();
error Error_ClaimReward();

contract Errors {
    modifier outOfIndex(uint256 index, uint256 listLenght) {
        if (index > listLenght) {
            revert Error_OutOfIndex();
        }
        _;
    }
    modifier onlyOwner(address sender, address owner) {
        if (sender != owner) {
            revert Error__OnlyOwner();
        }
        _;
    }

    function allowanceChecker(
        uint256 _allowance,
        uint256 _amount
    ) internal pure {
        if (_amount > _allowance) {
            revert Error__InsufficientAllowance();
        }
    }
    function isTransfered(bool _result) internal pure {
        if (!_result) {
            revert Error__TokenIsNotTransfered();
        }
    }

    function checkBalance(uint256 _balance) internal pure {
        if (_balance < 1) {
            revert Error__InsufficientBalance();
        }
    }

    modifier amountChecker(uint256 amount) {
        if (amount < 1) {
            revert Error__DepositAmountTooLow();
        }
        _;
    }

    function timeChecker(uint256 _daysUsed) internal pure {
        if (_daysUsed < 1) {
            revert Error__NoRewardYet();
        }
    }

    function withdrawalError(
        uint256 _balance,
        uint256 _withdrawAmount
    ) internal pure {
        if (_withdrawAmount > _balance) {
            revert Error__InsufficientBalance();
        }
    }

    function isRewardClaimed(uint256 _rewardEarned) internal pure {
        if (_rewardEarned != 0) {
            revert Error_ClaimReward();
        }
    }
}
