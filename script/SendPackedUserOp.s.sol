// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {PackedUserOperation} from "@account-abstraction/interfaces/PackedUserOperation.sol";
import {MinimalAccount} from "../src/ethereum/MinimalAccount.sol";

contract SendPackedUserOp is Script {
    function run() public {}

    function deployMinimalAccount() public return (PackedUserOperation memory) {
        // 1. Generate the unsigned date
        // 2. Sign it and return it.
    }
}
