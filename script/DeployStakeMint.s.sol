//SPDX-License-Identifier:MIT

pragma solidity >=0.8.0 <0.9.0;

import "forge-std/Script.sol";
import {StakeMint} from "../src/StakeMint.sol";
import {HelperFiles} from "./helper/HelperFiles.sol";

//   address daoTokenAddress;
//         address senderAddress;
//         address aaveTokenAddress;

contract DeployStakeMint is Script {
    function run() external returns (address, address, StakeMint, address) {
        HelperFiles helperFiles = new HelperFiles();
        (
            address daoTokenAddress,
            address senderAddress,
            address aaveTokenAddress
        ) = (
                helperFiles.viewConfig().daoTokenAddress,
                helperFiles.viewConfig().senderAddress,
                helperFiles.viewConfig().aaveTokenAddress
            );
        vm.prank(senderAddress);

        StakeMint stakeMint = new StakeMint(daoTokenAddress);

        return (senderAddress, aaveTokenAddress, stakeMint, daoTokenAddress);
    }
}
