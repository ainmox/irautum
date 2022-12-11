pragma solidity >=0.5.4;

import {IERC20} from "solidity-standard-interfaces/IERC20.sol";
import {IERC4626} from "solidity-standard-interfaces/IERC4626.sol";
import {UFixed256x18} from "solidity-fixed-point/FixedPointMath.sol";

/// @title Interface for an Irautum pool deployer
/// @custom:coauthor Ainmox (https://github.com/ainmox)
interface IIrautumPoolDeployer {
    struct DeploymentParameters {
        IERC20 asset;
        address admin;
        uint256 depositLimit;
        UFixed256x18 reserveFactor;
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

    /// @dev The deployment parameters of the pool being deployed
    /// @return The deployment parameters
    function deploymentParameters() external view returns (DeploymentParameters memory);
}