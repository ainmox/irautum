pragma solidity 0.8.17;

import {Math} from "solidity-commons/Math.sol";
import {IERC20} from "solidity-standard-interfaces/IERC20.sol";
import {IERC4626} from "solidity-standard-interfaces/IERC4626.sol";
import {FixedPointMath, UFixed256x18} from "solidity-fixed-point/FixedPointMath.sol";
import {ERC20} from "solidity-erc20/ERC20.sol";
import {SafeERC20} from "solidity-erc20/SafeERC20.sol";

import {IIrautumPool} from "./interfaces/IIrautumPool.sol";

import {Pool, Parameters} from "./libraries/Pool.sol";

using SafeERC20 for IERC20;

contract IrautumPool is IIrautumPool, ERC20 {
    /// @inheritdoc IERC4626
    IERC20 public immutable override asset;

    /// @inheritdoc IIrautumPool
    uint256 public immutable depositLimit;

    /// @inheritdoc IIrautumPool
    UFixed256x18 public immutable override optimalUtilizationRate;

    /// @inheritdoc IIrautumPool
    UFixed256x18 public immutable override minimumBorrowRate;

    /// @inheritdoc IIrautumPool
    UFixed256x18 public immutable override maximumBorrowRate;

    /// @inheritdoc IIrautumPool
    UFixed256x18 public immutable override optimalBorrowRate;

    /// @inheritdoc IIrautumPool
    UFixed256x18 public immutable override slopeLowerBorrowRate;

    /// @inheritdoc IIrautumPool
    UFixed256x18 public immutable override slopeUpperBorrowRate;

    /// @inheritdoc IIrautumPool
    UFixed256x18 public immutable override minimumSupplyRate;

    /// @inheritdoc IIrautumPool
    UFixed256x18 public immutable override maximumSupplyRate;

    /// @inheritdoc IIrautumPool
    UFixed256x18 public immutable override optimalSupplyRate;

    /// @inheritdoc IIrautumPool
    UFixed256x18 public immutable override slopeLowerSupplyRate;

    /// @inheritdoc IIrautumPool
    UFixed256x18 public immutable override slopeUpperSupplyRate;

    struct State {
        // The last recorded total assets supplied plus interest earned
        uint256 totalSupplied;
        // The last recorded total borrowed assets plus interest charged
        uint256 totalBorrowed;
        // The last recorded borrow growth factor
        UFixed256x18 borrowGrowthFactor;
        // The last recorded time that the pool was synchronized
        uint256 syncTimestamp;
    }

    /// @inheritdoc IIrautumPool
    State public override state;

    constructor(Parameters memory params) {
        asset                  = params.asset;
        depositLimit           = params.depositLimit;
        optimalUtilizationRate = params.optimalUtilizationRate;
        minimumBorrowRate      = params.minimumBorrowRate;
        maximumBorrowRate      = params.maximumBorrowRate;
        optimalBorrowRate      = params.optimalBorrowRate;
        slopeLowerBorrowRate   = params.slopeLowerBorrowRate;
        slopeUpperBorrowRate   = params.slopeUpperBorrowRate;
        minimumSupplyRate      = params.minimumSupplyRate;
        maximumSupplyRate      = params.maximumSupplyRate;
        optimalSupplyRate      = params.optimalSupplyRate;
        slopeLowerSupplyRate   = params.slopeLowerSupplyRate;
        slopeUpperSupplyRate   = params.slopeUpperSupplyRate;
    }

    /// @notice The pool parameters
    /// @return params The parameters
    function parameters() public view returns (Parameters memory params) {
        params = Parameters({
            asset:                  asset,
            depositLimit:           depositLimit,
            optimalUtilizationRate: optimalUtilizationRate,
            minimumBorrowRate:      minimumBorrowRate,
            maximumBorrowRate:      maximumBorrowRate,
            optimalBorrowRate:      optimalBorrowRate,
            slopeLowerBorrowRate:   slopeLowerBorrowRate,
            slopeUpperBorrowRate:   slopeUpperBorrowRate,
            minimumSupplyRate:      minimumSupplyRate,
            maximumSupplyRate:      maximumSupplyRate,
            optimalSupplyRate:      optimalSupplyRate,
            slopeLowerSupplyRate:   slopeLowerSupplyRate,
            slopeUpperSupplyRate:   slopeUpperSupplyRate
        });
    }

    /// @notice Gets the current block timestamp
    /// @return The current block timestamp
    function timestamp() public view returns (uint256) {
        return block.timestamp;
    }

    /// @inheritdoc IERC4626
    function totalAssets() public view returns (uint256) {
        (
            uint256 totalSupplied,
            /* uint256 totalBorrowed */,
            /* UFixed256x18 borrowGrowthFactor */,
            /* uint256 lastSyncTimestamp */
        ) = previewSync();

        return totalSupplied;
    }

    /// @inheritdoc IIrautumPool
    function utilizationRate() public view returns (UFixed256x18 rate) {
        (
            uint256 totalSupplied,
            uint256 totalBorrowed,
            /* UFixed256x18 borrowGrowthFactor */,
            /* uint256 lastSyncTimestamp */
        ) = previewSync();

        // Unsafe division is safe here since the result will return zero when dividing by zero
        rate = FixedPointMath.unsafeDiv(FixedPointMath.intoUFixed256x18(totalBorrowed), totalSupplied);
    }

    /// @inheritdoc IIrautumPool
    function borrowRate() public view returns (UFixed256x18 rate) {
        rate = borrowRate(utilizationRate());
    }

    /// @inheritdoc IIrautumPool
    function borrowRate(UFixed256x18 utilization) public view returns (UFixed256x18 rate) {
        if (utilization.cmp(optimalUtilizationRate) <= 0) {
            rate = minimumBorrowRate.add(slopeLowerBorrowRate.mul(utilization));
        } else {
            rate = optimalBorrowRate.add(slopeUpperBorrowRate.mul(utilization.unsafeSub(optimalUtilizationRate)));
        }
    }

    /// @inheritdoc IIrautumPool
    function supplyRate() public view returns (UFixed256x18 rate) {
        rate = supplyRate(utilizationRate());
    }

    /// @inheritdoc IIrautumPool
    function supplyRate(UFixed256x18 utilization) public view returns (UFixed256x18 rate) {
        if (utilization.cmp(optimalUtilizationRate) <= 0) {
            rate = minimumSupplyRate.add(slopeLowerSupplyRate.mul(utilization));
        } else {
            rate = optimalSupplyRate.add(slopeUpperSupplyRate.mul(utilization.unsafeSub(optimalUtilizationRate)));
        }
    }

    /// @inheritdoc IIrautumPool
    function previewSync()
        public
        view
        returns (
            uint256 totalSupplied,
            uint256 totalBorrowed,
            UFixed256x18 borrowGrowthFactor,
            uint256 lastSyncTimestamp
        )
    {
        (
            totalSupplied,
            totalBorrowed,
            borrowGrowthFactor,
            lastSyncTimestamp
        ) = this.state();

        if (lastSyncTimestamp < timestamp()) {
            uint256 secondsElapsed;
            unchecked {
                secondsElapsed = timestamp() - lastSyncTimestamp;
            }

            UFixed256x18 utilization = FixedPointMath.unsafeDiv(
                FixedPointMath.intoUFixed256x18(totalBorrowed),
                totalSupplied
            );

            UFixed256x18 supplyExponent = FixedPointMath.unsafeMul(supplyRate(utilization), secondsElapsed);
            UFixed256x18 borrowExponent = FixedPointMath.unsafeMul(borrowRate(utilization), secondsElapsed);

            totalSupplied = FixedPointMath.round(FixedPointMath.mul(FixedPointMath.exp(supplyExponent), totalSupplied));
            totalBorrowed = FixedPointMath.round(FixedPointMath.mul(FixedPointMath.exp(borrowExponent), totalBorrowed));

            borrowGrowthFactor = FixedPointMath.add(borrowGrowthFactor, borrowExponent);
        }
    }

    /// @inheritdoc IIrautumPool
    function sync()
        public
        returns (
            uint256 totalSupplied,
            uint256 totalBorrowed,
            UFixed256x18 borrowGrowthFactor,
            uint256 lastSyncTimestamp
        )
    {
        (
            totalSupplied,
            totalBorrowed,
            borrowGrowthFactor,
            lastSyncTimestamp
        ) = previewSync();

        if (lastSyncTimestamp < timestamp()) {
            state = State({
                totalSupplied: totalSupplied,
                totalBorrowed: totalBorrowed,
                borrowGrowthFactor: borrowGrowthFactor,
                syncTimestamp: lastSyncTimestamp
            });
        }
    }

    /// @inheritdoc IERC4626
    function convertToShares(uint256 assets) public view returns (uint256 shares) {
        shares = totalSupply > 0 ? Math.mulDiv(assets, totalSupply, totalAssets()) : assets;
    }

    /// @inheritdoc IERC4626
    function convertToAssets(uint256 shares) public view returns (uint256 assets) {
        assets = totalSupply > 0 ? Math.mulDiv(shares, totalAssets(), totalSupply) : shares;
    }

    /// @inheritdoc IERC4626
    function maxDeposit(address) public view returns (uint256 maxAssets) {
        (
            uint256 totalSupplied,
            /* uint256 totalBorrowed */,
            /* UFixed256x18 borrowGrowthFactor */,
            /* uint256 lastSyncTimestamp */
        ) = previewSync();

        unchecked {
            maxAssets = depositLimit > totalSupplied ? depositLimit - totalSupplied : 0;
        }
    }

    /// @inheritdoc IERC4626
    function previewDeposit(uint256 assets) public view returns (uint256 shares) {
        shares = convertToShares(assets);
    }

    /// @inheritdoc IERC4626
    function deposit(uint256 assets, address receiver) external returns (uint256 shares) {
        require(assets <= maxDeposit(msg.sender));
        shares = previewDeposit(assets);

        (
            uint256 totalSupplied,
            /* uint256 totalBorrowed */,
            /* UFixed256x18 borrowGrowthFactor */,
            /* uint256 lastSyncTimestamp */
        ) = sync();

        unchecked {
            state.totalSupplied = totalSupplied + assets;
        }

        _mint(receiver, shares);

        emit Deposit(msg.sender, receiver, assets, shares);

        asset.safeTransferFrom(msg.sender, address(this), assets);
    }

    /// @inheritdoc IERC4626
    function maxMint(address receiver) public view returns (uint256 maxShares) {
        maxShares = convertToShares(maxDeposit(receiver));
    }

    /// @inheritdoc IERC4626
    function previewMint(uint256 shares) public view returns (uint256 assets) {
        assets = convertToAssets(shares);
    }

    /// @inheritdoc IERC4626
    function mint(uint256 shares, address receiver) public returns (uint256 assets) {
        require(shares <= maxMint(receiver));
        assets = previewMint(shares);

        (
            uint256 totalSupplied,
            /* uint256 totalBorrowed */,
            /* UFixed256x18 borrowGrowthFactor */,
            /* uint256 lastSyncTimestamp */
        ) = sync();

        unchecked {
            state.totalSupplied = totalSupplied + assets;
        }

        _mint(receiver, shares);

        emit Deposit(msg.sender, receiver, assets, shares);

        asset.safeTransferFrom(msg.sender, address(this), assets);
    }

    /// @inheritdoc IERC4626
    function maxWithdraw(address owner) public view returns (uint256 maxAssets) {
        // As per the ERC4626 specification this function "MUST return the maximum amount of assets that could be
        // transferred from owner through withdraw and not cause a revert, which MUST NOT be higher than the actual
        // maximum that would be accepted (it should underestimate if necessary)." To prevent withdraw from reverting
        // we must ensure that the amount of assets that would be withdrawn is less than or equal to the amount of
        // assets which are available to be withdrawn. As such, we limit the maximum amount of assets that can be
        // withdrawn to the amount of assets that the contract currently has in its custody minus the assets which
        // are earmarked for reserves.
        maxAssets = Math.min(convertToAssets(balanceOf[owner]), asset.balanceOf(address(this)));
    }

    /// @inheritdoc IERC4626
    function previewWithdraw(uint256 assets) public view returns (uint256 shares) {
        shares = convertToShares(assets);
    }

    /// @inheritdoc IERC4626
    function withdraw(uint256 assets, address receiver, address owner) public returns (uint256 shares) {
        require(assets <= maxWithdraw(owner));

        shares = shares = previewWithdraw(assets);
        require(owner == msg.sender || shares <= allowance[owner][msg.sender]);

        (
            uint256 totalSupplied,
            /* uint256 totalBorrowed */,
            /* UFixed256x18 borrowGrowthFactor */,
            /* uint256 lastSyncTimestamp */
        ) = sync();

        unchecked {
            if (msg.sender != owner) allowance[owner][msg.sender] -= shares;
            state.totalSupplied = totalSupplied - assets;
        }

        _burn(owner, shares);

        emit Withdraw(msg.sender, receiver, owner, assets, shares);

        asset.safeTransfer(receiver, assets);
    }

    /// @inheritdoc IERC4626
    function maxRedeem(address owner) public view returns (uint256 maxShares) {
        // As per the ERC4626 specification this function "MUST return the maximum amount of shares that could be
        // transferred from owner through redeem and not cause a revert, which MUST NOT be higher than the actual
        // maximum that would be accepted (it should underestimate if necessary)." To prevent redemptions from
        // reverting we must ensure that the value of the shares being redeemed is less than or equal to the amount of
        // assets which are available to be withdrawn. As such, we limit the maximum amount of shares that can be
        // redeemed to equivalent value of assets that the contract currently has in its custody minus the assets
        // which are earmarked for reserves.
        maxShares = Math.min(balanceOf[owner], convertToShares(asset.balanceOf(address(this))));
    }

    /// @inheritdoc IERC4626
    function previewRedeem(uint256 shares) public view returns (uint256 assets) {
        assets = convertToAssets(shares);
    }

    /// @inheritdoc IERC4626
    function redeem(uint256 shares, address receiver, address owner) public returns (uint256 assets) {
        require(shares <= maxRedeem(owner));
        require(owner == msg.sender || shares <= allowance[owner][msg.sender]);

        assets = previewRedeem(shares);

        (
            uint256 totalSupplied,
            /* uint256 totalBorrowed */,
            /* UFixed256x18 borrowGrowthFactor */,
            /* uint256 lastSyncTimestamp */
        ) = sync();

        unchecked {
            if (msg.sender != owner) allowance[owner][msg.sender] -= shares;
            state.totalSupplied = totalSupplied - assets;
        }

        _burn(owner, shares);

        emit Withdraw(msg.sender, receiver, owner, assets, shares);

        asset.safeTransfer(receiver, assets);
    }
}