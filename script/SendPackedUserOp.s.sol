// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {PackedUserOperation} from "@account-abstraction/interfaces/PackedUserOperation.sol";
import {MinimalAccount} from "../src/ethereum/MinimalAccount.sol";

contract SendPackedUserOp is Script {
    function run() public {}

    function deployMinimalAccount() public returns(PackedUserOperation memory) {
        // 1. Generate the unsigned date
        // 2. Sign it and return it.
    }

    function _generateUnsignedUserOperation(bytes memory calldata, address sender, uint256 nonce) internal pure returns(PackedUserOperation memory) {
        uint128 verificationGasLimit = 16777216;
        uint128 callGasLimit = verificationGasLimit;
        uint128 maxPriorityFeePerGas = 256;
        uint128 maxFeePerGas = maxPriorityFeePerGas;
        return PackedUserOperation({
            sender: sender,
            nonce: nonce,
            initCode: hex"",
            callData: calldata,
            accountGasLimits: bytes32(uint256(verificationGasLimit) << 128 | callGasLimit),
            preVerificationGas: verificationGasLimit,
            gasFee: bytes32(uint256(maxPriorityFeePerGas) << 128 | maxFeePerGas),
            paymasterAndData: hex"",
            signature: hex""
        })
    }
}
