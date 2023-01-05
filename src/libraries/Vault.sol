pragma solidity 0.8.17;

import {IERC4626} from "solidity-standard-interfaces/IERC4626.sol";
import {UFixed16x4} from "solidity-fixed-point/FixedPointMath.sol";

type Parameters is uint256;

using Vault for Parameters global;

library Vault {
    /// @dev Extracts the vault address from the parameters
    /// @return The vault address
    function vault(Parameters params) internal pure returns (IERC4626) {}

    /// @dev Extracts the borrow factor from the parameters
    /// @return The borrow factor
    function borrowFactor(Parameters params) internal pure returns (UFixed16x4) {}

    /// @dev Extracts the liquidation factor from the parameters
    /// @return The liquidation factor
    function liquidationFactor(Parameters params) internal pure returns (UFixed16x4) {}

    /// @dev Extracts the liquidation penalty from the parameters
    /// @return The liquidation penalty
    function liquidationPenalty(Parameters params) internal pure returns (UFixed16x4) {}
}