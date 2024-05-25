//SPDX-License-Identifier:MIT

pragma solidity >=0.8.0 <0.9.0;

import {Script, console} from "forge-std/Script.sol";
import {DeployMockDaoToken} from "../../test/mock/DeployMockDaoToken.sol";
contract HelperFiles is Script {
    uint256 private constant _TOKENSUPPLY = 10000000e18;
    uint8 private constant _TOEKNDECIMAL = 18;

    struct Configuration {
        address daoTokenAddress;
        address senderAddress;
        address aaveTokenAddress;
    }

    Configuration private _configuration;

    constructor() {
        _setDaoTokenAddress();
    }

    function _setDaoTokenAddress() private {
        if (block.chainid == 11155111) {
            _configuration = _getDaoTokenAddressSepolia();
        } else {
            _configuration = _getDaoTokenAddressAnvil();
        }
    }
    //DAO token address on the ethereum sepolia chain
    function _getDaoTokenAddressSepolia()
        private
        view
        returns (Configuration memory)
    {
        Configuration memory config = Configuration({
            daoTokenAddress: 0x9323C0F4eB8059648eE3f980547C79bEc9A8A46B,
            senderAddress: msg.sender,
            aaveTokenAddress: 0xBA12222222228d8Ba445958a75a0704d566BF2C8
        });
        return config;
    }

    //
    function _getDaoTokenAddressAnvil() private returns (Configuration memory) {
        if (
            _configuration.daoTokenAddress != address(0) &&
            _configuration.senderAddress != address(0) &&
            _configuration.aaveTokenAddress != address(0)
        ) {
            return _configuration;
        }
        address simulatedSender = makeAddr("Deployer");

        console.log(simulatedSender);
        vm.startPrank(simulatedSender);
        DeployMockDaoToken deployMockToken = new DeployMockDaoToken(
            "StakeMintToken",
            "STM",
            _TOEKNDECIMAL,
            _TOKENSUPPLY,
            simulatedSender
        );
        DeployMockDaoToken deployMockAaveToken = new DeployMockDaoToken(
            "AAVE",
            "AAVE",
            _TOEKNDECIMAL,
            _TOKENSUPPLY,
            simulatedSender
        );

        vm.stopPrank();

        Configuration memory config = Configuration({
            daoTokenAddress: address(deployMockToken),
            senderAddress: simulatedSender,
            aaveTokenAddress: address(deployMockAaveToken)
        });
        return config;
    }

    //getter functions

    function viewConfig() public view returns (Configuration memory) {
        return _configuration;
    }
}
