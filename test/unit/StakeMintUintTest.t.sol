//SPDX-License-Identifier:MIT

pragma solidity >=0.8.0 <0.9.0;

import {Test} from "forge-std/Test.sol";
import {DeployStakeMint} from "../../script/DeployStakeMint.s.sol";
import {StakeMint} from "../../src/StakeMint.sol";
import {Users} from "../../src/helpers/Users.sol";
import {TokensConfig} from "../../src/helpers/TokensConfig.sol";
import {AggregatorV3Interface} from "../../src/interfaces/IAggregatorV3Interface.sol";
import {ERC20TokenInterface} from "../../src/interfaces/IERC20TokenInterface.sol";

contract StakeMintUintTesting is Test, Users {
    StakeMint stakeMint;
    TokensConfig tokensConfig;

    function setUp() external {
        DeployStakeMint deployStakeMint = new DeployStakeMint();
        tokensConfig = new TokensConfig();

        stakeMint = deployStakeMint.run();
    }

    function testOwner() public view {
        //Arrange

        //Act
        address getOwner = stakeMint.getOwner();
        //Assert
        assertEq(getOwner, i_owner);
    }

    function testTokenOwnerBalance() public view {
        //Arranage
        address tokenContract = tokensConfig.getTokens()[0].contractAddress;
        ERC20TokenInterface token = ERC20TokenInterface(tokenContract);
        //act
        uint256 balance = token.balanceOf(i_owner);
        //assert
        assertEq(balance, tokensConfig.TOKENS_SUPPLY());
    }

    function testTokenPrice() public view {
        //Arrange
        address priceFeedContract = tokensConfig
        .getTokens()[0].priceFeedContract;
        AggregatorV3Interface aggregatorV3 = AggregatorV3Interface(
            priceFeedContract
        );
        //Act
        (, int256 answer, , , ) = aggregatorV3.latestRoundData();
        assertEq(uint256(answer), 3900e8);
    }

    function testOutOfIndex() public {
        vm.expectRevert();
        vm.prank(i_user);
        stakeMint.deposit(100e18, 0);
    }

    function testNotOwner() public {
        //Arrange

        (string memory name, address assetContract, address priceFeed) = (
            tokensConfig.getTokens()[0].name,
            tokensConfig.getTokens()[0].contractAddress,
            tokensConfig.getTokens()[0].priceFeedContract
        );
        vm.expectRevert();
        vm.prank(i_user);
        // Act

        //Assert
        stakeMint.addAsset(name, assetContract, priceFeed);
    }

    function addMultipleAsset(uint256 items) internal {
        for (uint256 index = 0; index < items; index++) {
            (string memory name, address assetContract, address priceFeed) = (
                tokensConfig.getTokens()[index].name,
                tokensConfig.getTokens()[index].contractAddress,
                tokensConfig.getTokens()[index].priceFeedContract
            );
            vm.prank(i_owner);
            stakeMint.addAsset(name, assetContract, priceFeed);
        }
    }
    function testAssetAdded() public {
        // Arrange
        addMultipleAsset(3);
        //Act
        uint256 assets = stakeMint.getAllowedAssets().length;
        //Assert
        assertEq(assets, 3);
    }
    function testTVL() public {
        //Arrange
        addMultipleAsset(1);
        vm.startPrank(i_owner);
        address tokenContract = tokensConfig.getTokens()[0].contractAddress;
        ERC20TokenInterface erc20TokenContract = ERC20TokenInterface(
            tokenContract
        );
        uint256 VALUE = 20e18;
        erc20TokenContract.approve(address(stakeMint), VALUE);
        stakeMint.deposit(VALUE, 0);
        uint256 tvl = stakeMint.checkContractTotalValueLocked();
        uint256 expectedValue = (3900e8 * VALUE) / 10e8;
        assertEq(expectedValue, tvl);
        vm.stopPrank();
    }
    function testInsufficientAllowance() public {
        addMultipleAsset(1);
        vm.prank(i_owner);
        vm.expectRevert();
        stakeMint.deposit(10e18, 0);
    }

    function testAssetLocked() public {
        //Arrange
        addMultipleAsset(1);
        address tokenContract = tokensConfig.getTokens()[0].contractAddress;
        ERC20TokenInterface token = ERC20TokenInterface(tokenContract);
        vm.prank(i_owner);
        token.transfer(i_user, 500e18);
        //Act
        vm.prank(i_user);
        token.approve(address(stakeMint), 500e18);
        vm.prank(i_user);
        stakeMint.deposit(500e18, 0);
        //Assert
        uint256 value = stakeMint.getContractAssetValueLocked(tokenContract);
        assertEq(value, 500e18);
    }
}
