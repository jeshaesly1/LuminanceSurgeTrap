// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITrap {
    function collect() external view returns (bytes memory);
    function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory);
}

contract LuminanceSurgeTrap is ITrap {
    uint256 private constant THRESHOLD_PERCENT = 1;

    function collect() external view override returns (bytes memory) {
        return abi.encode(block.basefee, block.gaslimit);
    }

    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
        if (data.length < 2) {
            return (false, abi.encode("Insufficient data"));
        }

        (uint256 currentBasefee, uint256 currentGaslimit) = abi.decode(data[0], (uint256, uint256));
        (uint256 previousBasefee, uint256 previousGaslimit) = abi.decode(data[1], (uint256, uint256));

        if (previousBasefee == 0 || previousGaslimit == 0) {
            return (false, abi.encode("Invalid baseline"));
        }

        if (_percentChange(currentBasefee, previousBasefee) > THRESHOLD_PERCENT || 
            _percentChange(currentGaslimit, previousGaslimit) > THRESHOLD_PERCENT) {
            return (true, abi.encode("Luminance surge detected"));
        }

        return (false, abi.encode("No surge detected"));
    }

    function _percentChange(uint256 current, uint256 previous) private pure returns (uint256) {
        if (current > previous) {
            return ((current - previous) * 100) / previous;
        } else {
            return ((previous - current) * 100) / previous;
        }
    }
}
