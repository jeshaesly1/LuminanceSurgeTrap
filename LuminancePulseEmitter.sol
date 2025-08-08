// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract LuminancePulseEmitter {
    event SurgePulse(bytes data);

    function emitPulse(bytes calldata data) external {
        emit SurgePulse(data);
    }
}
