//SPDX-License-Identifier:MIT

pragma solidity >=0.8.0 <0.9.0;

error Error__OnlyOwner();
error Error__InsufficientAllowance();
error Error__IndexOutOfBound();

contract Errors {
    modifier onlyOwner(address _owner) {
        if (msg.sender != _owner) {
            revert Error__OnlyOwner();
        }
        _;
    }

    function allowanceCheck(uint256 _allowance, uint256 _depositAmount) public pure {
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
}
