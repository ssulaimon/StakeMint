//SPDX-License-Identifier:MIT

pragma solidity >=0.8.0 <0.9.0;
import {Test} from "forge-std/Test.sol";
import {DeployStakeMint} from "../../script/DeployStakeMint.s.sol";
import {StakeMint} from "../../src/StakeMint.sol";

contract StakeMintUintTesting is Test {
    StakeMint stakeMint;
    address owner;
    address immutable i_USER = makeAddr("USER");
    function setUp() external {
        DeployStakeMint deployStakeMint = new DeployStakeMint();
        (stakeMint, owner) = deployStakeMint.run();
    }

    function testOwner() public view {
        //Arrange

        //Act
        address getOwner = stakeMint.getOwner();
        //Assert
        assertEq(getOwner, owner);
    }
}
