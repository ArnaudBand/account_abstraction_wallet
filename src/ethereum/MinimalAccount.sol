// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IAccount} from "@account-abstraction/interfaces/IAccount.sol";
import {PackedUserOperation} from "@account-abstraction/interfaces/PackedUserOperation.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {SIG_VALIDATION_FAILED, SIG_VALIDATION_SUCCESS} from "@account-abstraction/core/Helpers.sol";
import {IEntryPoint} from "@account-abstraction/interfaces/IEntryPoint.sol";

contract MinimalAccount is IAccount, Ownable {

    error MinimalAccount__NotFromEntryPoint();

    IEntryPoint private immutable i_entryPoint;

    modifier requireFromEntryPoint() {
        if (msg.sender != address(i_entryPoint)) revert MinimalAccount__NotFromEntryPoint();
        _;
    }
    constructor(address _entryPoint) Ownable(msg.sender) {
        i_entryPoint = IEntryPoint(_entryPoint);
    }

    function validateUserOp(PackedUserOperation calldata userOp, bytes32 userOpHash, uint256 missingAccountFunds)
        external
        requireFromEntryPoint
        returns (uint256 validationData)
    {
        validationData = _validateSignature(userOp, userOpHash);
        // validateNonce();
        _payPrefund(missingAccountFunds);
    }

    function _validateSignature(PackedUserOperation calldata userOp, bytes32 userOpHash)
        internal
        view
        returns (uint256 validationData)
    {
        bytes32 ethSignedMessageHash = MessageHashUtils.toEthSignedMessageHash(userOpHash);
        address signer = ECDSA.recover(ethSignedMessageHash, userOp.signature);
        if (signer != owner()) return SIG_VALIDATION_FAILED;

        return SIG_VALIDATION_SUCCESS;
    }

    function _payPrefund(uint256 missingAccountFunds) internal {
        if (missingAccountFunds != 0) {
            (bool success, ) = payable(msg.sender).call{value: missingAccountFunds, gas: type(uint256).max}("");
            (success); // ensure the transfer is successful
        }
    }

    // Getter functions
    function getEntryPoint() external view returns (address) {
        return address(i_entryPoint);
    }
}
