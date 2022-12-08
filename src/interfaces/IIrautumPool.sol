pragma solidity >=0.5.4;

import {IERC20} from "solidity-standard-interfaces/IERC20.sol";
import {IERC4626} from "solidity-standard-interfaces/IERC4626.sol";
import {UFixed256x18} from "solidity-fixed-point/FixedPointMath.sol";

/// @title Interface for an Irautum asset pool
/// @custom:coauthor Ainmox (https://github.com/ainmox)
interface IIrautumPool is IERC4626 {
    /// @notice The administrator of the pool
    /// @return The admin
    function admin() external view returns (address);

    /// @notice The proportion of the accrued interest that is retained for reserves
    /// @return The reserve factor
    function reserveFactor() external view returns (UFixed256x18);

    /// @notice The borrow rate when the utilization is at its minimum value
    /// @return The minimum borrow rate
    function minimumBorrowRate() external view returns (UFixed256x18);

    /// @notice The borrow rate when the utilization is at its maximum value
    /// @return The maximum borrow rate
    function maximumBorrowRate() external view returns (UFixed256x18);

    /// @notice The borrow rate when the utilization is at its optimal value
    /// @return The optimal borrow rate
    function optimalBorrowRate() external view returns (UFixed256x18);

    /// @notice The utilization that the pool is attempting to maintain
    /// @return The optimal utilization
    function optimalUtilization() external view returns (UFixed256x18);

    /// @notice The proportion of lent assets that are currently being borrowed
    /// @return The utilization
    function utilization() external view returns (UFixed256x18);

    /// @notice The current per second rate that borrowers accrue interest
    /// @return The borrow rate
    function borrowRate() external view returns (UFixed256x18);

    /// @notice The current per second rate that lenders accrue interest
    /// @return The supply rate
    function supplyRate() external view returns (UFixed256x18);

    /// @notice The last recorded state of the pool
    /// @return lastTotalBorrowed The last recorded total borrowed assets plus interest
    /// @return lastTotalReserves The last recorded total reserves
    /// @return lastBorrowGrowthFactor The last recorded borrow growth factor
    /// @return lastSyncTimestamp The last recorded time that the pool was synchronized
    function state()
        external
        view
        returns (
            uint256 lastTotalBorrowed,
            uint256 lastTotalReserves,
            UFixed256x18 lastBorrowGrowthFactor,
            uint256 lastSyncTimestamp
        );

    /// @notice Previews synchronizing the state of the pool
    /// @return totalBorrowed The total borrowed assets plus interest
    /// @return totalReserves The total reserves
    /// @return borrowGrowthFactor The borrow growth factor
    /// @return lastSyncTimestamp The last recorded time that the pool was synchronized, excluding this call
    function previewSyncState()
        external
        view
        returns (
            uint256 totalBorrowed,
            uint256 totalReserves,
            UFixed256x18 borrowGrowthFactor,
            uint256 lastSyncTimestamp
        );

    /// @notice Synchronizes the state of the pool
    /// @return totalBorrowed The total borrowed assets plus interest
    /// @return totalReserves The total reserves
    /// @return borrowGrowthFactor The borrow growth factor
    /// @return lastSyncTimestamp The last recorded time that the pool was synchronized, excluding this call
    function syncState()
        external
        returns (
            uint256 totalBorrowed,
            uint256 totalReserves,
            UFixed256x18 borrowGrowthFactor,
            uint256 lastSyncTimestamp
        );
}