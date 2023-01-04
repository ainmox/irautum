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

library Pool {

}