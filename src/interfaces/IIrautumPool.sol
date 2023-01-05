pragma solidity >=0.5.4;

import {IERC20} from "solidity-standard-interfaces/IERC20.sol";
import {IERC4626} from "solidity-standard-interfaces/IERC4626.sol";
import {UFixed256x18, UFixed16x4} from "solidity-fixed-point/FixedPointMath.sol";

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

    /// @notice Gets if `vault` is supported
    /// @return supported `true` if the vault is supported, `false` otherwise
    function isSupportedVault(IERC4626 vault) external view returns (bool supported);

    /// @notice The parameters of a vault for a given index
    /// @param index The index of the vault in the parameters list
    /// @return vault The address of the vault
    /// @return borrowFactor The minimum loan to value ratio that a position must maintain for borrowing to be enabled
    /// @return liquidationFactor The minimum loan to value ratio that a position must maintain before liquidations are enabled
    /// @return liquidationPenalty The penalty applied to vault shares liquidated
    function vaultParameters(uint256 index)
        external
        view
        returns (
            IERC4626 vault,
            UFixed16x4 borrowFactor,
            UFixed16x4 liquidationFactor,
            UFixed16x4 liquidationPenalty
        );

    /// @notice The parameters of a vault for a given address
    /// @param vault The address of the vault
    /// @return index The index of the vault in the list
    /// @return borrowFactor The minimum loan to value ratio that a position must maintain for borrowing to be enabled
    /// @return liquidationFactor The minimum loan to value ratio that a position must maintain before liquidations are enabled
    /// @return liquidationPenalty The penalty applied to liquidated vault shares
    function vaultParameters(IERC4626 vault)
        external
        view
        returns (
            uint256 index,
            UFixed16x4 borrowFactor,
            UFixed16x4 liquidationFactor,
            UFixed16x4 liquidationPenalty
        );

    /// @notice The proportion of lent assets that are currently being borrowed
    /// @return rate The utilization rate
    function utilizationRate() external view returns (UFixed256x18 rate);

    /// @notice The current per second rate that borrowers accrue interest
    /// @return rate The borrow rate
    function borrowRate() external view returns (UFixed256x18 rate);

    /// @notice The borrow rate at a specific utilization
    /// @param utilization The utilization rate
    /// @return rate The borrow rate
    function borrowRate(UFixed256x18 utilization) external view returns (UFixed256x18 rate);

    /// @notice The current per second rate that lenders accrue interest
    /// @return rate The supply rate
    function supplyRate() external view returns (UFixed256x18 rate);

    /// @notice The supply rate at a specific utilization
    /// @param utilization The utilization rate
    /// @return rate The supply rate
    function supplyRate(UFixed256x18 utilization) external view returns (UFixed256x18 rate);

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

    /// @notice Previews synchronizing the pool
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

    /// @notice Synchronizes the pool
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

    /// @notice The maximum number of `vault` shares that can be deposited for `receiver`
    /// @param vault The address of the vault
    /// @param receiver The address of the receiver
    /// @return maxShares The maximum number of shares that can be deposited
    function maxDeposit(IERC4626 vault, address receiver) external view returns (uint256 maxShares);

    /// @notice Deposits `shares` of `vault` shares to `receiver`
    /// @param vault The address of the vault to deposit shares from
    /// @param shares The number of shares to deposit
    /// @param receiver The address to receive the deposited shares
    function deposit(IERC4626 vault, uint256 shares, address receiver) external;

    /// @notice The maximum number of `vault` shares that can be withdrawn from the position owned by `owner`
    /// @param vault The address of the vault
    /// @param owner The address of the owner
    /// @return maxShares The maximum number of shares that can be withdrawn
    function maxWithdraw(IERC4626 vault, address owner) external view returns (uint256 maxShares);

    /// @notice Withdraws `shares` of `vault` shares from the position owned by `owner`
    /// @param vault The address of the vault to withdraw shares from
    /// @param shares The number of shares to withdraw
    /// @param owner The address of the owner
    function withdraw(IERC4626 vault, uint256 shares, address receiver, address owner) external;

    /// @notice The maximum amount of assets that can be borrowed from the position owned by `owner`
    /// @param owner The address of the owner
    /// @return maxAssets The maximum amount of assets that can be borrowed
    function maxBorrow(address owner) external view returns (uint256 maxAssets);

    /// @notice Borrows `assets` assets from the position owned by `owner` and sends them to `receiver`
    /// @param assets The amount of assets to borrow
    /// @param receiver The address to receive the borrowed assets
    /// @param owner The address of the owner
    function borrow(uint256 assets, address receiver, address owner) external;

    /// @inheritdoc IERC4626
    function asset() external view override returns (IERC20);

    /// @inheritdoc IERC4626
    function totalAssets() external view override returns (uint256);

    /// @inheritdoc IERC4626
    function convertToShares(uint256 assets) external view override returns (uint256 shares);

    /// @inheritdoc IERC4626
    function convertToAssets(uint256 shares) external view override returns (uint256 assets);

    /// @inheritdoc IERC4626
    function maxDeposit(address receiver) external view override returns (uint256 maxAssets);

    /// @inheritdoc IERC4626
    function previewDeposit(uint256 assets) external view override returns (uint256 shares);

    /// @inheritdoc IERC4626
    function deposit(uint256 assets, address receiver) external override returns (uint256 shares);

    /// @inheritdoc IERC4626
    function maxMint(address receiver) external view override returns (uint256 maxShares);

    /// @inheritdoc IERC4626
    function previewMint(uint256 shares) external view override returns (uint256 assets);

    /// @inheritdoc IERC4626
    function mint(uint256 shares, address receiver) external override returns (uint256 assets);

    /// @inheritdoc IERC4626
    function maxWithdraw(address owner) external view override returns (uint256 maxAssets);

    /// @inheritdoc IERC4626
    function previewWithdraw(uint256 assets) external view override returns (uint256 shares);

    /// @inheritdoc IERC4626
    function withdraw(uint256 assets, address receiver, address owner) external override returns (uint256 shares);

    /// @inheritdoc IERC4626
    function maxRedeem(address owner) external view override returns (uint256 maxShares);

    /// @inheritdoc IERC4626
    function previewRedeem(uint256 shares) external view override returns (uint256 assets);

    /// @inheritdoc IERC4626
    function redeem(uint256 shares, address receiver, address owner) external override returns (uint256 assets);
}