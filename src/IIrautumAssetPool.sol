pragma solidity >=0.5.4;

import {IERC20} from "solidity-standard-interfaces/IERC20.sol";
import {IERC4626} from "solidity-standard-interfaces/IERC4626.sol";
import {UFixed80x18, UFixed16x4} from "solidity-fixed-point/FixedPointMath.sol";

/// @title Interface for an Irautum asset pool
/// @custom:coauthor Ainmox (https://github.com/ainmox)
interface IIrautumAssetPool is IERC4626 {
    /// @notice The administrator of the pool
    /// @return The admin
    function admin() external view returns (address);

    /// @notice The proportion of the accrued interest that is retained for reserves
    /// @return The reserve factor
    function reserveFactor() external view returns (UFixed16x4);

    /// @notice The borrow rate when the utilization is at its minimum value
    /// @return The minimum borrow rate
    function minimumBorrowRate() external view returns (UFixed80x18);

    /// @notice The borrow rate when the utilization is at its maximum value
    /// @return The maximum borrow rate
    function maximumBorrowRate() external view returns (UFixed80x18);

    /// @notice The borrow rate when the utilization is at its optimal value
    /// @return The optimal borrow rate
    function optimalBorrowRate() external view returns (UFixed80x18);

    /// @notice The utilization rate that the pool that the pool targets to maintain
    /// @return The optimal utilization
    function optimalUtilization() external view returns (UFixed16x4);

    /// @notice The proportion of lent assets that are currently being borrowed
    /// @return The utilization
    function utilization() external view returns (UFixed16x4);

    /// @notice The current per second rate that borrowers accrue interest
    /// @return The borrow rate
    function borrowRate() external view returns (UFixed80x18);

    /// @notice The current per second rate that lenders accrue interest
    /// @return The supply rate
    function supplyRate() external view returns (UFixed80x18);
}