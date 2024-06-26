// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ERC20TokenInterface {
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function tokenOwner() external view returns (address);

    function approve(address spender, uint256 value) external returns (bool);

    function balanceOf(address owner) external view returns (uint256);

    function decimals() external view returns (uint8);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}
