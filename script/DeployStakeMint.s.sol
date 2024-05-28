//SPDX-License-Identifier:MIT
pragma solidity >=0.8.0 <0.9.0;

import {Script} from "forge-std/Script.sol";
import {StakeMint} from "../src/StakeMint.sol";
import {Users} from "../src/helpers/Users.sol";

contract DeployStakeMint is Script, Users {
    function run() external returns (StakeMint) {
        // vm.broadcast();
        vm.prank(i_owner);
        StakeMint stakeMint = new StakeMint();

        // vm.stopBroadcast();
        return (stakeMint);
    }
}
