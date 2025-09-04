// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITrap {
    function collect() external view returns (bytes memory);
    function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory);
}

interface ILuminancePulseEmitter {
    function emitPulse(bytes calldata data) external;
}

/// @title LuminanceSurgeTrap — triggers when basefee OR gaslimit changes by more than a fixed threshold
contract LuminanceSurgeTrap is ITrap {
    uint256 public constant THRESHOLD_PERCENT = 1;  // Жёстко заданный порог 1%
    ILuminancePulseEmitter public pulseEmitter;

    constructor() {
        pulseEmitter = ILuminancePulseEmitter(address(0));
    }

    /// @notice Collect current block parameters
    function collect() external view override returns (bytes memory) {
        return abi.encode(block.basefee, block.gaslimit);
    }

    /// @notice Determines if a surge occurred based on provided data snapshots
    /// @param data Array with [current, previous] encoded snapshots
    /// @return triggered True if surge detected
    /// @return response Encoded structured response including values and deltas
    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
        if (data.length < 2) {
            return (false, abi.encode("Insufficient data"));
        }

        (uint256 currentBasefee, uint256 currentGaslimit) = abi.decode(data[0], (uint256, uint256));
        (uint256 previousBasefee, uint256 previousGaslimit) = abi.decode(data[1], (uint256, uint256));

        if (previousBasefee == 0 || previousGaslimit == 0) {
            return (false, abi.encode("Invalid baseline"));
        }

        uint256 basefeeChange = _percentChange(currentBasefee, previousBasefee);
        uint256 gaslimitChange = _percentChange(currentGaslimit, previousGaslimit);

        bool triggered = basefeeChange > THRESHOLD_PERCENT || gaslimitChange > THRESHOLD_PERCENT;

        bytes memory response = abi.encode(
            "Luminance surge detected",
            currentBasefee,
            previousBasefee,
            basefeeChange,
            currentGaslimit,
            previousGaslimit,
            gaslimitChange
        );

        return (triggered, triggered ? response : abi.encode("No surge detected", response));
    }

    /// @dev Helper to calculate percent change
    function _percentChange(uint256 current, uint256 previous) private pure returns (uint256) {
        if (previous == 0) return 0;
        uint256 diff = current > previous ? current - previous : previous - current;
        return (diff * 100) / previous;
    }

    /// @notice Optional: externally callable hook to emit pulse event on-chain
    /// @param data Arbitrary data to emit with the pulse event
    function emitPulseOnChain(bytes calldata data) external {
        require(address(pulseEmitter) != address(0), "PulseEmitter not set");
        pulseEmitter.emitPulse(data);
    }

    /// @notice Optional setter for pulseEmitter address, если нужна смена
    function setPulseEmitter(address newEmitter) external {
        pulseEmitter = ILuminancePulseEmitter(newEmitter);
    }
}
