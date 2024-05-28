//SPDX-License-Identifier:MIT
pragma solidity >=0.8.0 <0.9.0;

import {Script} from "forge-std/Script.sol";

contract Users is Script {
    address immutable i_owner = makeAddr("owner");
    address immutable i_user = makeAddr("user");
}
