//SPDX-License-Identifier:MIT

pragma solidity >=0.8.0 <0.9.0;

import "forge-std/Script.sol";
import {StakeMint} from "../src/StakeMint.sol";

contract DeployStakeMint is Script {
    function run() external returns (StakeMint) {
        //DAOTOKEN: 0x9323C0F4eB8059648eE3f980547C79bEc9A8A46B
        vm.broadcast();
        StakeMint stakeMint = new StakeMint(
            0x9323C0F4eB8059648eE3f980547C79bEc9A8A46B
        );
        return stakeMint;
    }
}
