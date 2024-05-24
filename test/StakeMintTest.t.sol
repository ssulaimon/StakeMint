//SPDX-License-Identifier:MIT

pragma solidity >=0.8.0 <0.9.0;

import {Test, console} from "forge-std/Test.sol";
import {DeployStakeMint} from "../script/DeployStakeMint.s.sol";
import {ERC20TokenInterface} from "../src/interfaces/ITokenInterface.sol";
import {StakeMint} from "../src/StakeMint.sol";
contract StakeMintTest is Test {
    address private immutable INTERACTING_ADDRESS =
        makeAddr("interactingAddress");
    address sender;
    address aave;
    address dao;
    StakeMint stakeMint;

    ERC20TokenInterface aaveToken;
    ERC20TokenInterface daoToken;

    DeployStakeMint deployStakeMint;
    function setUp() external {
        deployStakeMint = new DeployStakeMint();
        (sender, aave, stakeMint, dao) = deployStakeMint.run();
        aaveToken = ERC20TokenInterface(aave);
        daoToken = ERC20TokenInterface(dao);
    }

    /*
    ERC20 token test 
    */
    //testing if my created address is the owner
    function testCheckAaveTokenOwner() public view {
        address owner = aaveToken.tokenOwner();
        assertEq(owner, sender);
    }
    // checking the balance of the prank address
    function testAaveAddressBalance() public view {
        uint256 balance = aaveToken.balanceOf(sender);
        assertEq(balance, 10000000e18);
    }

    /*
    Stakemint DEFI contract testing 
    */

    modifier prankInteraction() {
        vm.prank(INTERACTING_ADDRESS);
        _;
    }
    modifier ownerInteraction() {
        vm.prank(sender);
        _;
    }

    function testStakeMintContractBalance() public ownerInteraction {
        uint256 transferedValue = 100e18;

        daoToken.transfer(address(stakeMint), transferedValue);

        uint256 balance = stakeMint.daoTokenBalance();
        assertEq(balance, transferedValue);
    }

    function testOwnerAddress() public view {
        address owner = stakeMint.contractOwner();
        assertEq(owner, sender);
    }

    function testNotOWnerChangingRate() public prankInteraction {
        vm.expectRevert();
        stakeMint.changeRate(4000);
    }

    function testOwnerRateChange() public ownerInteraction {
        uint256 newRate = 300000;
        stakeMint.changeRate(newRate);
        uint256 currentRate = stakeMint.annualRate();
        assertEq(currentRate, newRate);
    }

    function testNotOwnerAddingAsset() public prankInteraction {
        vm.expectRevert();
        stakeMint.addAssetAllowed("AAVE", dao);
    }

    function testOwnerAddingAsset() public ownerInteraction {
        stakeMint.addAssetAllowed("AAVE", dao);
        uint256 assets = stakeMint.allowedAssets().length;
        assertEq(assets, 1);
    }
}
