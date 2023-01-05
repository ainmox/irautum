pragma solidity >=0.8.0 <0.9.0;

import {UFixed256x18} from "solidity-fixed-point/FixedPointMath.sol";

import {IrautumPool, PoolParameters} from "../src/IrautumPool.sol";
import {ERC20Mock} from "./mocks/ERC20Mock.sol";
import {ERC4626Test} from "erc4626-tests/ERC4626.test.sol";

contract IrautumPoolERC4626StdTest is ERC4626Test {
    function setUp() public override {
        ERC20Mock asset = new ERC20Mock();

        IrautumPool vault = new IrautumPool(PoolParameters({
            asset:                  asset,
            depositLimit:           type(uint256).max,
            optimalUtilizationRate: UFixed256x18.wrap(0),
            minimumBorrowRate:      UFixed256x18.wrap(0),
            maximumBorrowRate:      UFixed256x18.wrap(0),
            optimalBorrowRate:      UFixed256x18.wrap(0),
            slopeLowerBorrowRate:   UFixed256x18.wrap(0),
            slopeUpperBorrowRate:   UFixed256x18.wrap(0),
            minimumSupplyRate:      UFixed256x18.wrap(0),
            maximumSupplyRate:      UFixed256x18.wrap(0),
            optimalSupplyRate:      UFixed256x18.wrap(0),
            slopeLowerSupplyRate:   UFixed256x18.wrap(0),
            slopeUpperSupplyRate:   UFixed256x18.wrap(0)
        }));

        _underlying_     = address(asset);
        _vault_          = address(vault);
        _delta_          = 0;
        _vaultMayBeEmpty = false;
        _unlimitedAmount = false;
    }
}