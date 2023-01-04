pragma solidity 0.8.17;

import {IERC20} from "solidity-standard-interfaces/IERC20.sol";
import {FixedPointMath, UFixed256x18} from "solidity-fixed-point/FixedPointMath.sol";

struct Parameters {
    IERC20 asset;
    uint256 depositLimit;
    UFixed256x18 optimalUtilizationRate;
    UFixed256x18 minimumBorrowRate;
    UFixed256x18 maximumBorrowRate;
    UFixed256x18 optimalBorrowRate;
    UFixed256x18 slopeLowerBorrowRate;
    UFixed256x18 slopeUpperBorrowRate;
    UFixed256x18 minimumSupplyRate;
    UFixed256x18 maximumSupplyRate;
    UFixed256x18 optimalSupplyRate;
    UFixed256x18 slopeLowerSupplyRate;
    UFixed256x18 slopeUpperSupplyRate;
}

using Pool for Parameters global;

library Pool {
    /// @dev The borrow rate for a given utilization
    /// @param params The pool parameters
    /// @param utilization The utilization rate
    /// @return rate The borrow rate
    function borrowRate(Parameters memory params, UFixed256x18 utilization) internal pure returns (UFixed256x18 rate) {
        rate = calculateRate(
            utilization,
            params.optimalBorrowRate,
            params.minimumBorrowRate,
            params.maximumBorrowRate,
            params.optimalBorrowRate,
            params.slopeLowerBorrowRate,
            params.slopeUpperBorrowRate
        );
    }

    /// @dev The supply rate for a given utilization
    /// @param params The pool parameters
    /// @param utilization The utilization rate
    /// @return rate The supply rate
    function supplyRate(Parameters memory params, UFixed256x18 utilization) internal pure returns (UFixed256x18 rate) {
        rate = calculateRate(
            utilization,
            params.optimalSupplyRate,
            params.minimumSupplyRate,
            params.maximumSupplyRate,
            params.optimalSupplyRate,
            params.slopeLowerSupplyRate,
            params.slopeUpperSupplyRate
        );
    }

    /// @dev Calculates the rate for a given utilization
    /// @param utilization The utilization rate
    /// @param optimalUtilization The optimal utilization rate
    /// @param minimumRate The minimum rate
    /// @param maximumRate The maximum rate
    /// @param optimalRate The optimal rate
    /// @param slopeLowerRate The slope of the jump rate below the optimal rate
    /// @param slopeUpperRate The slope of the jump rate above the optimal rate
    /// @return rate The calculated rate
    function calculateRate(
        UFixed256x18 utilization,
        UFixed256x18 optimalUtilization,
        UFixed256x18 minimumRate,
        UFixed256x18 maximumRate,
        UFixed256x18 optimalRate,
        UFixed256x18 slopeLowerRate,
        UFixed256x18 slopeUpperRate
    ) private pure returns (UFixed256x18 rate) {
        if (utilization.cmp(optimalUtilization) <= 0) {
            rate = FixedPointMath.min(minimumRate.add(slopeLowerRate.mul(utilization)), optimalRate);
        } else {
            rate = FixedPointMath.min(optimalRate.add(slopeUpperRate.mul(utilization.unsafeSub(optimalUtilization))), maximumRate);
        }
    }
}