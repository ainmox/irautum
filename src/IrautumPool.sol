pragma solidity 0.8.17;

import {IERC20} from "solidity-standard-interfaces/IERC20.sol";
import {IERC4626} from "solidity-standard-interfaces/IERC4626.sol";
import {FixedPointMath, UFixed256x18} from "solidity-fixed-point/FixedPointMath.sol";

import {IIrautumPool} from "./interfaces/IIrautumPool.sol";
import {IIrautumPoolDeployer} from "./interfaces/IIrautumPoolDeployer.sol";

contract IrautumPool is IIrautumPool {
    /// @inheritdoc IERC4626
    IERC20 public immutable override asset;

    /// @inheritdoc IIrautumPool
    uint256 public immutable depositLimit;

    /// @inheritdoc IIrautumPool
    UFixed256x18 public immutable override reserveFactor;

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

    /// @inheritdoc IERC20
    uint256 public override totalSupply;

    /// @inheritdoc IERC20
    mapping(address => uint256) public override balanceOf;

    /// @inheritdoc IERC20
    mapping(address => mapping(address => uint256)) public override allowance;

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

    constructor() {
        IIrautumPoolDeployer deployer = IIrautumPoolDeployer(msg.sender);

        IIrautumPoolDeployer.DeploymentParameters memory params = deployer.deploymentParameters();

        asset                  = params.asset;
        depositLimit           = params.depositLimit;
        reserveFactor          = params.reserveFactor;
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

    /// @notice Gets the current block timestamp
    /// @return The current block timestamp
    function timestamp() public view returns (uint256) {
        return block.timestamp;
    }

    /// @inheritdoc IERC4626
    function totalAssets() public view returns (uint256) {
        (
            uint256 totalBorrowed,
            uint256 totalReserves,
            /* UFixed256x18 borrowGrowthFactor */,
            /* uint256 lastSyncTimestamp */
        ) = previewSyncState();

        return asset.balanceOf(address(this)) + totalBorrowed - totalReserves;
    }

    /// @inheritdoc IIrautumPool
    function utilizationRate() public view returns (UFixed256x18 rate) {
        (
            uint256 totalBorrowed,
            uint256 totalReserves,
            /* UFixed256x18 borrowGrowthFactor */,
            /* uint256 lastSyncTimestamp */
        ) = previewSyncState();

        uint256 totalLoaned = asset.balanceOf(address(this)) + totalBorrowed - totalReserves;

        // Unsafe division is safe here since the result will return zero when dividing by zero
        rate = FixedPointMath.unsafeDiv(FixedPointMath.intoUFixed256x18(totalBorrowed), totalLoaned);
    }

    /// @inheritdoc IIrautumPool
    function borrowRate() public view returns (UFixed256x18 rate) {
        UFixed256x18 utilization = utilizationRate();

        if (utilization.cmp(optimalUtilizationRate) <= 0) {
            rate = minimumBorrowRate.add(slopeLowerBorrowRate.mul(utilization));
        } else {
            rate = optimalBorrowRate.add(slopeUpperBorrowRate.mul(utilization.unsafeSub(optimalUtilizationRate)));
        }
    }

    /// @inheritdoc IIrautumPool
    function supplyRate() external view returns (UFixed256x18 rate) {
        UFixed256x18 utilization = utilizationRate();

        if (utilization.cmp(optimalUtilizationRate) <= 0) {
            rate = minimumSupplyRate.add(slopeLowerSupplyRate.mul(utilization));
        } else {
            rate = optimalSupplyRate.add(slopeUpperSupplyRate.mul(utilization.unsafeSub(optimalUtilizationRate)));
        }
    }

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

        // Unchecked arithmetic is safe here because:
        // 1). It is asserted that balance >= amount
        // 2). It is asserted that the sum of all the balances is less than 2^256-1
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

        // Unchecked arithmetic is safe here because:
        // 1). It is asserted that spendable >= amount
        // 2). It is asserted that balance >= amount
        // 3). It is asserted that the sum of all the balances is less than 2^256-1
        unchecked {
            allowance[owner][msg.sender] = spendable - amount;
            balanceOf[owner] = balance - amount;
            balanceOf[recipient] += amount;
        }

        emit Transfer(owner, recipient, amount);

        success = true;
    }

    /// @inheritdoc IERC4626
    function convertToShares(uint256 assets) external view returns (uint256 shares) {
        shares = totalSupply > 0 ? assets * totalSupply / totalAssets() : assets;
    }

    /// @inheritdoc IERC4626
    function convertToAssets(uint256 shares) external view returns (uint256 assets) {
        assets = totalSupply > 0 ? shares * totalAssets() / totalSupply : shares;
    }

    /// @inheritdoc IERC4626
    function maxDeposit(address) external view returns (uint256 maxAssets) {
        uint256 loanedAssets = totalAssets();

        unchecked {
            maxAssets = loanedAssets > depositLimit ? depositLimit - loanedAssets : 0;
        }
    }

    /// @inheritdoc IERC4626
    function previewDeposit(uint256 assets) external view returns (uint256 shares) {
        shares = convertToShares(assets);
    }

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