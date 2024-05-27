// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20} from "../src/helpers/ERC20Token.sol";

contract MyToken is ERC20 {
    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals,
        uint256 _totalSupply
    ) ERC20(name, symbol, decimals) {
        // Mint 100 tokens to msg.sender
        // Similar to how
        // 1 dollar = 100 cents
        // 1 token = 1 * (10 ** decimals)
        _mint(msg.sender, _totalSupply);
    }
}
