// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {MinimalAccount} from "../../src/ethereum/MinimalAccount.sol";
import {DeployMinimalAccount} from "../../script/DeployMinimalAccount.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {SendPackedUserOp, PackedUserOperation, IEntryPoint} from "script/SendPackedUserOp.s.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract MinimalAccountTest is Test {

    using MessageHashUtils for bytes32;

    MinimalAccount public minimalAccount;

    HelperConfig public config;
    DeployMinimalAccount public deployer;
    SendPackedUserOp sendPackedUserOp;

    ERC20Mock public usdc;

    uint256 constant AMOUNT = 1e18;
    address public randomUser = makeAddr("randomUser");

    function setUp() public {
        deployer = new DeployMinimalAccount();
        (config, minimalAccount) = deployer.deployMinimalAccount();
        usdc = new ERC20Mock();

        sendPackedUserOp = new SendPackedUserOp();
    }

    function testOwnerCanExecuteComands() public {
        assertEq(usdc.balanceOf(address(minimalAccount)), 0);
        address dest = address(usdc);
        uint256 value = 0;
        bytes memory funcData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(minimalAccount), AMOUNT);

        vm.prank(minimalAccount.owner());
        minimalAccount.execute(dest, value, funcData);

        assertEq(usdc.balanceOf(address(minimalAccount)), AMOUNT);
    }

    function testNonOwnerCannotExecuteComands() public {
        assertEq(usdc.balanceOf(address(minimalAccount)), 0);

        vm.prank(randomUser);
        vm.expectRevert(MinimalAccount.MinimalAccount__NotFromEntryPointOrOwner.selector);
        minimalAccount.execute(
            address(usdc), 0, abi.encodeWithSelector(ERC20Mock.mint.selector, address(minimalAccount), AMOUNT)
        );
    }

    function testRecoverSignedOp() public {
        // Arrange
        assertEq(usdc.balanceOf(address(minimalAccount)), 0);
        address dest = address(usdc);
        uint256 value = 0;
        bytes memory funcData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(minimalAccount), AMOUNT);
        bytes memory executeCalData = abi.encodeWithSelector(MinimalAccount.execute.selector, dest, value, funcData);
        PackedUserOperation memory packedUserOp =
            sendPackedUserOp.generateSignedUserOperation(executeCalData, config.getConfig());

        bytes32 userOpHash = IEntryPoint(config.getConfig().entryPoint).getUserOpHash(packedUserOp);
        // Act
        address actualSigner = ECDSA.recover(userOpHash.toEthSignedMessageHash(), packedUserOp.signature);
        // Assert
        assertEq(actualSigner, minimalAccount.owner());
    }
}
