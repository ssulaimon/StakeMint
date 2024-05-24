//SPDX-License-Identifier:MIT
pragma solidity >=0.8.0 <0.9.0;

import {ERC20} from "../../test/mock/ERC20TokenMock.sol";

contract DeployMockDaoToken is ERC20 {
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimal,
        uint256 _maxSupply,
        address _minter
    ) ERC20(_name, _symbol, _decimal) {
        _mint(_minter, _maxSupply);
    }
}
