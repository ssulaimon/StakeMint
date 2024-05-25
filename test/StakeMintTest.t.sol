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
    address stakeMintContractAddress;
    function setUp() external {
        deployStakeMint = new DeployStakeMint();
        (sender, aave, stakeMint, dao) = deployStakeMint.run();
        aaveToken = ERC20TokenInterface(aave);
        daoToken = ERC20TokenInterface(dao);
        stakeMintContractAddress = address(stakeMint);
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
    function testAllowance() public {
        vm.startPrank(sender);
        uint256 value = 10e18;
        aaveToken.approve(stakeMintContractAddress, value);
        uint256 allowance = aaveToken.allowance(
            sender,
            stakeMintContractAddress
        );
        assertEq(allowance, value);
        vm.stopPrank();
    }

    function testDeposit() public {
        vm.startPrank(sender);
        stakeMint.addAssetAllowed("AAVE", aave);
        uint256 value = 10e18;
        aaveToken.approve(stakeMintContractAddress, value);
        stakeMint.depositAssets(value, uint16(0));
        uint256 balance = stakeMint.assetTVL(uint16(0));
        assertEq(balance, value);
        vm.stopPrank();
    }

    function testUserBalance() public {
        vm.startPrank(sender);
        stakeMint.addAssetAllowed("AAVE", aave);
        uint256 value = 10e18;
        aaveToken.approve(stakeMintContractAddress, value);
        stakeMint.depositAssets(value, uint16(0));
        uint256 balance = stakeMint.userBalanceInContract(0, sender);
        assertEq(balance, value);
        vm.stopPrank();
    }

    function testWithdraw() public {
        vm.startPrank(sender);
        stakeMint.addAssetAllowed("AAVE", aave);
        uint256 value = 10e18;
        aaveToken.approve(stakeMintContractAddress, value);
        stakeMint.depositAssets(value, uint16(0));
        stakeMint.withdrawAsset(uint16(0), value, sender);
        uint256 balance = stakeMint.userBalanceInContract(0, sender);
        assertEq(balance, 0);
        vm.stopPrank();
    }
    function testUnableToWithdraw() public {
        uint256 value = 10e18;
        vm.prank(sender);
        stakeMint.addAssetAllowed("AAVE", aave);
        vm.prank(sender);
        aaveToken.approve(stakeMintContractAddress, value);
        vm.prank(sender);
        stakeMint.depositAssets(value, uint16(0));
        vm.expectRevert();
        vm.prank(INTERACTING_ADDRESS);
        stakeMint.withdrawAsset(uint16(0), value, INTERACTING_ADDRESS);
    }
    function testOutOfIndex() public {
        vm.expectRevert();
        stakeMint.assetTVL(uint16(3));
    }

    function testDaoTokenBalance() public {
        uint256 value = 200e18;
        vm.startPrank(sender);
        daoToken.transfer(stakeMintContractAddress, value);
        uint256 contractTokenBalance = stakeMint.daoTokenBalance();
        assertEq(contractTokenBalance, value);
        vm.stopPrank();
    }
    function testUserTransactions() public {
        uint256 value = 300e18;
        vm.startPrank(sender);
        stakeMint.addAssetAllowed("AAVE", aave);
        aaveToken.approve(stakeMintContractAddress, value);
        stakeMint.depositAssets(100e18, uint16(0));
        stakeMint.depositAssets(100e18, uint16(0));
        stakeMint.depositAssets(100e18, uint16(0));
        uint256 transaction = stakeMint.transactionReciept(sender).length;
        assertEq(transaction, 3);
        vm.stopPrank();
    }
    function testOverWithdraw() public {
        uint256 value = 300e18;
        vm.startPrank(sender);
        stakeMint.addAssetAllowed("AAVE", aave);
        aaveToken.approve(stakeMintContractAddress, value);

        stakeMint.depositAssets(value, uint16(0));
        vm.expectRevert();
        stakeMint.withdrawAsset(uint16(0), 400e18, sender);

        vm.stopPrank();
    }
}
