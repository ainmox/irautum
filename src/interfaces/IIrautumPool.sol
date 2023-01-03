pragma solidity >=0.5.4;

import {IERC20} from "solidity-standard-interfaces/IERC20.sol";
import {IERC4626} from "solidity-standard-interfaces/IERC4626.sol";
import {UFixed256x18} from "solidity-fixed-point/FixedPointMath.sol";

/// @title Interface for an Irautum asset pool
/// @custom:coauthor Ainmox (https://github.com/ainmox)
interface IIrautumPool is IERC4626 {
    /// @notice The maximum amount of assets that can be deposited into the pool
    /// @return The deposit limit
    function depositLimit() external view returns (uint256);

    /// @notice The utilization that the pool is attempting to maintain
    /// @return The optimal utilization
    function optimalUtilizationRate() external view returns (UFixed256x18);

    /// @notice The borrow rate when the utilization is at its minimum value
    /// @return The minimum borrow rate
    function minimumBorrowRate() external view returns (UFixed256x18);

    /// @notice The borrow rate when the utilization is at its maximum value
    /// @return The maximum borrow rate
    function maximumBorrowRate() external view returns (UFixed256x18);

    /// @notice The borrow rate when the utilization is at its optimal value
    /// @return The optimal borrow rate
    function optimalBorrowRate() external view returns (UFixed256x18);

    /// @notice The slope of the borrow rate when the utilization is below the optimal value
    /// @return The slope of the lower borrow rate
    function slopeLowerBorrowRate() external view returns (UFixed256x18);

    /// @notice The slope of the borrow rate when the utilization is above the optimal value
    /// @return The slope of the upper borrow rate
    function slopeUpperBorrowRate() external view returns (UFixed256x18);

    /// @notice The supply rate when the utilization is at its minimum value
    /// @return The minimum borrow rate
    function minimumSupplyRate() external view returns (UFixed256x18);

    /// @notice The supply rate when the utilization is at its maximum value
    /// @return The maximum supply rate
    function maximumSupplyRate() external view returns (UFixed256x18);

    /// @notice The supply rate when the utilization is at its optimal value
    /// @return The optimal supply rate
    function optimalSupplyRate() external view returns (UFixed256x18);

    /// @notice The slope of the supply rate when the utilization is below the optimal value
    /// @return The slope of the lower supply rate
    function slopeLowerSupplyRate() external view returns (UFixed256x18);

    /// @notice The slope of the supply rate when the utilization is above the optimal value
    /// @return The slope of the upper supply rate
    function slopeUpperSupplyRate() external view returns (UFixed256x18);

    /// @notice The proportion of lent assets that are currently being borrowed
    /// @return rate The utilization rate
    function utilizationRate() external view returns (UFixed256x18 rate);

    /// @notice The current per second rate that borrowers accrue interest
    /// @return rate The borrow rate
    function borrowRate() external view returns (UFixed256x18 rate);

    /// @notice The current per second rate that lenders accrue interest
    /// @return rate The supply rate
    function supplyRate() external view returns (UFixed256x18 rate);

    /// @notice The last recorded state of the pool
    /// @return lastTotalSupplied The last recorded total assets supplied for borrowing plus interest earned
    /// @return lastTotalBorrowed The last recorded total assets borrowed plus interest accrued
    /// @return lastBorrowGrowthFactor The last recorded borrow growth factor
    /// @return lastSyncTimestamp The last recorded time that the pool was synchronized
    function state()
        external
        view
        returns (
            uint256 lastTotalSupplied,
            uint256 lastTotalBorrowed,
            UFixed256x18 lastBorrowGrowthFactor,
            uint256 lastSyncTimestamp
        );

    /// @notice Previews synchronizing the state of the pool
    /// @return totalSupplied The total assets supplied for borrowing plus interest earned
    /// @return totalBorrowed The total borrowed assets plus interest accrued
    /// @return borrowGrowthFactor The borrow growth factor
    /// @return lastSyncTimestamp The last recorded time that the pool was synchronized, excluding this call
    function previewSync()
        external
        view
        returns (
            uint256 totalSupplied,
            uint256 totalBorrowed,
            UFixed256x18 borrowGrowthFactor,
            uint256 lastSyncTimestamp
        );

    /// @notice Synchronizes the state of the pool
    /// @return totalSupplied The total assets supplied for borrowing plus interest earned
    /// @return totalBorrowed The total borrowed assets plus interest accrued
    /// @return borrowGrowthFactor The borrow growth factor
    /// @return lastSyncTimestamp The last recorded time that the pool was synchronized, excluding this call
    function sync()
        external
        returns (
            uint256 totalSupplied,
            uint256 totalBorrowed,
            UFixed256x18 borrowGrowthFactor,
            uint256 lastSyncTimestamp
        );
}