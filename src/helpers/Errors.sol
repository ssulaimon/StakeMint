//SPDX-License-Identifier:MIT

pragma solidity >=0.8.0 <0.9.0;
import {ERC20TokenInterface} from "../../src/interfaces/IERC20TokenInterface.sol";

error Error__OnlyOwner();
error Error__InsufficientAllowance();
error Error__IndexOutOfBound();
error Error__InsufficientContractBalance();
error Error__TransactionRevert();

contract Errors {
    modifier onlyOwner(address _owner) {
        if (msg.sender != _owner) {
            revert Error__OnlyOwner();
        }
        _;
    }

    function allowanceCheck(
        uint256 _allowance,
        uint256 _depositAmount
    ) public pure {
        if (_depositAmount > _allowance) {
            revert Error__InsufficientAllowance();
        }
    }

    modifier checkIndex(uint256 index, uint256 arrayLength) {
        if (index > arrayLength) {
            revert Error__IndexOutOfBound();
        }
        _;
    }

    modifier balanceCheck(
        address asset,
        address owner,
        uint256 amount
    ) {
        ERC20TokenInterface token = ERC20TokenInterface(asset);
        uint256 balance = token.balanceOf(owner);
        if (amount > balance) {
            revert Error__InsufficientContractBalance();
        }
        _;
    }

    function transactionIsuccessful(bool state) internal pure {
        if (!state) {
            revert Error__TransactionRevert();
        }
    }
    function userBalanceInContract(
        uint256 balance,
        uint256 withdrawAmount
    ) internal pure {
        if (withdrawAmount > balance) {
            revert Error__InsufficientContractBalance();
        }
    }
}
