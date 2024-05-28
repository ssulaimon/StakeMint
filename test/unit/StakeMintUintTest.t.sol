//SPDX-License-Identifier:MIT

pragma solidity >=0.8.0 <0.9.0;

import {Test} from "forge-std/Test.sol";
import {DeployStakeMint} from "../../script/DeployStakeMint.s.sol";
import {StakeMint} from "../../src/StakeMint.sol";
import {Users} from "../../src/helpers/Users.sol";

contract StakeMintUintTesting is Test, Users {
    StakeMint stakeMint;

    function setUp() external {
        DeployStakeMint deployStakeMint = new DeployStakeMint();
        stakeMint = deployStakeMint.run();
    }

    function testOwner() public view {
        //Arrange

        //Act
        address getOwner = stakeMint.getOwner();
        //Assert
        assertEq(getOwner, i_owner);
    }
}
