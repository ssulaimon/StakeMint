//SPDX-License-Identifier:MIT

pragma solidity >=0.8.0 <0.9.0;

import {Test, console} from "forge-std/Test.sol";
import {StakeMint} from "../src/StakeMint.sol";

import "@contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol"

contract StakeMintTest is Test {
    StakeMint stakeMint;
    function setUp() external {
        stakeMint = new StakeMint(0x9323C0F4eB8059648eE3f980547C79bEc9A8A46B);
    }

    function testApy() public {
        uint256 anualRate = stakeMint.annualRate();
        console.log(anualRate);
        assertEq(anualRate, 4000);
    }

    function testChangeAnualRate() public {
        stakeMint.changeRate(3000);
        uint256 anualRate = stakeMint.annualRate();
        assertEq(anualRate, 3000);
    }
}
