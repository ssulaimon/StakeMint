//SPDX-License-Identifier:MIT
pragma solidity >=0.8.0 <0.9.0;
import {Script} from "forge-std/Script.sol";
import {StakeMint} from "../src/StakeMint.sol";

contract DeployStakeMint is Script {
    function run() external returns (StakeMint, address) {
        address owner = makeAddr("owner");
        // vm.broadcast();
        vm.prank(owner);
        StakeMint stakeMint = new StakeMint();

        // vm.stopBroadcast();
        return (stakeMint, owner);
    }
}
