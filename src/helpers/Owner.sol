//SPDX-License-Identifier:MIT
pragma solidity >=0.8.0 <0.9.0;
contract Owner {
    address private immutable i_owner;
    constructor() {
        i_owner = msg.sender;
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }
}
