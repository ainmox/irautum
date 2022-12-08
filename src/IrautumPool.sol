pragma solidity 0.8.17;

import {IERC20} from "solidity-standard-interfaces/IERC20.sol";
import {IERC4626} from "solidity-standard-interfaces/IERC4626.sol";
import {UFixed256x18, UFixed80x18, UFixed16x4} from "solidity-fixed-point/FixedPointMath.sol";

import {IIrautumPool} from "./interfaces/IIrautumPool.sol";

contract IrautumPool is IIrautumPool {
    /// @inheritdoc IERC20
    uint256 public override totalSupply;

    /// @inheritdoc IERC20
    mapping(address => uint256) public override balanceOf;

    /// @inheritdoc IERC20
    mapping(address => mapping(address => uint256)) public override allowance;

    /// @inheritdoc IERC4626
    IERC20 public override asset;

    /// @inheritdoc IIrautumPool
    address public override admin;

    /// @inheritdoc IIrautumPool
    UFixed16x4 public override reserveFactor;

    /// @inheritdoc IIrautumPool
    UFixed80x18 public override minimumBorrowRate;

    /// @inheritdoc IIrautumPool
    UFixed80x18 public override maximumBorrowRate;

    /// @inheritdoc IIrautumPool
    UFixed80x18 public override optimalBorrowRate;

    /// @inheritdoc IIrautumPool
    UFixed16x4 public override optimalUtilization;

    struct State {
        // The last recorded total borrowed assets plus interest
        uint256 lastTotalBorrowed;
        // The last recorded total reserves
        uint256 lastTotalReserves;
        // The last recorded borrow growth factor
        UFixed256x18 lastBorrowGrowthFactor;
        //  The last recorded time that the pool was synchronized
        uint256 lastSyncTimestamp;
    }

    /// @inheritdoc IIrautumPool
    State public override state;

    /// @notice Gets the current block timestamp
    /// @return The current block timestamp
    function timestamp() public view returns (uint256) {
        return block.timestamp;
    }

    /// @inheritdoc IERC4626
    function totalAssets() external view returns (uint256) {
        (
            uint256 totalBorrowed,
            uint256 totalReserves,
            /* UFixed256x18 borrowGrowthFactor */,
            /* uint256 lastSyncTimestamp */
        ) = previewSyncState();

        return asset.balanceOf(address(this)) + totalBorrowed - totalReserves;
    }

    /// @inheritdoc IIrautumPool
    function utilization() external view returns (UFixed16x4) { }

    /// @inheritdoc IIrautumPool
    function borrowRate() external view returns (UFixed80x18) { }

    /// @inheritdoc IIrautumPool
    function supplyRate() external view returns (UFixed80x18) { }

    /// @inheritdoc IIrautumPool
    function previewSyncState()
        public
        view
        returns (
            uint256 totalBorrowed,
            uint256 totalReserves,
            UFixed256x18 borrowGrowthFactor,
            uint256 lastSyncTimestamp
        )
    { }

    /// @inheritdoc IIrautumPool
    function syncState()
        public
        returns (
            uint256 totalBorrowed,
            uint256 totalReserves,
            UFixed256x18 borrowGrowthFactor,
            uint256 lastSyncTimestamp
        )
    {
        (
            totalBorrowed,
            totalReserves,
            borrowGrowthFactor,
            lastSyncTimestamp
        ) = previewSyncState();

        if (lastSyncTimestamp < timestamp()) {
            state = State({
                lastTotalBorrowed: totalBorrowed,
                lastTotalReserves: totalReserves,
                lastBorrowGrowthFactor: borrowGrowthFactor,
                lastSyncTimestamp: lastSyncTimestamp
            });
        }
    }

    /// @inheritdoc IERC20
    function approve(address spender, uint256 value) external returns (bool success) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        success = true;
    }

    /// @inheritdoc IERC20
    function transfer(address recipient, uint256 amount) external returns (bool success) {
        uint256 balance = balanceOf[recipient];
        require(balance >= amount, "Insufficient balance");

        unchecked {
            balanceOf[msg.sender] = balance - amount;
            balanceOf[recipient] += amount;
        }

        emit Transfer(msg.sender, recipient, amount);

        success = true;
    }

    /// @inheritdoc IERC20
    function transferFrom(address owner, address recipient, uint256 amount) external returns (bool success) {
        uint256 spendable = allowance[owner][msg.sender];
        require(spendable >= amount, "Insufficient allowance");

        uint256 balance = balanceOf[recipient];
        require(balance >= amount, "Insufficient balance");

        unchecked {
            allowance[owner][msg.sender] = spendable - amount;
            balanceOf[owner] = balance - amount;
            balanceOf[recipient] += amount;
        }

        emit Transfer(owner, recipient, amount);

        success = true;
    }

    /// @inheritdoc IERC4626
    function convertToShares(uint256 assets) external view returns (uint256 shares) { }

    /// @inheritdoc IERC4626
    function convertToAssets(uint256 shares) external view returns (uint256 assets) { }

    /// @inheritdoc IERC4626
    function maxDeposit(address receiver) external view returns (uint256 maxAssets) { }

    /// @inheritdoc IERC4626
    function previewDeposit(uint256 assets) external view returns (uint256 shares) { }

    /// @inheritdoc IERC4626
    function deposit(uint256 assets, address receiver) external view returns (uint256 shares) { }

    /// @inheritdoc IERC4626
    function maxMint(address receiver) external view returns (uint256 maxShares) { }

    /// @inheritdoc IERC4626
    function previewMint(uint256 shares) external view returns (uint256 assets) { }

    /// @inheritdoc IERC4626
    function mint(uint256 shares, address receiver) external view returns (uint256 assets) { }

    /// @inheritdoc IERC4626
    function maxWithdraw(address owner) external view returns (uint256 maxAssets) { }

    /// @inheritdoc IERC4626
    function previewWithdraw(uint256 assets) external view returns (uint256 shares) { }

    /// @inheritdoc IERC4626
    function withdraw(uint256 assets, address receiver, address owner) external view returns (uint256 shares) { }

    /// @inheritdoc IERC4626
    function maxRedeem(address owner) external view returns (uint256 maxShares) { }

    /// @inheritdoc IERC4626
    function previewRedeem(uint256 shares) external view returns (uint256 assets) { }

    /// @inheritdoc IERC4626
    function redeem(uint256 shares, address receiver, address owner) external view returns (uint256 assets) { }
}