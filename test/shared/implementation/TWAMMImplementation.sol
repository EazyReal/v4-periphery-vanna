// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {BaseHook} from "../../../contracts/BaseHook.sol";
import {TWAMM} from "../../../contracts/hooks/examples/TWAMM.sol";
import {IPoolManager} from "@uniswap/v4-core/contracts/interfaces/IPoolManager.sol";
import {Hooks} from "@uniswap/v4-core/contracts/libraries/Hooks.sol";
import {PoolId} from "@uniswap/v4-core/contracts/libraries/PoolId.sol";

contract TWAMMImplementation is TWAMM {
    constructor(IPoolManager poolManager, uint256 interval, TWAMM addressToEtch) TWAMM(poolManager, interval) {
        Hooks.validateHookAddress(addressToEtch, getHooksCalls());
    }

    // make this a no-op in testing
    function validateHookAddress(BaseHook _this) internal pure override {}

    function getOrderPoolEarningsFactorAtInterval(PoolId id, bool zeroForOne, uint256 timestamp)
        external
        view
        returns (uint256 earningsFactor)
    {
        if (zeroForOne) return twammStates[id].orderPool0For1.earningsFactorAtInterval[timestamp];
        else return twammStates[id].orderPool1For0.earningsFactorAtInterval[timestamp];
    }

    function isCrossingInitializedTick(
        PoolParamsOnExecute memory pool,
        IPoolManager poolManager,
        IPoolManager.PoolKey memory poolKey,
        uint160 nextSqrtPriceX96
    ) external view returns (bool crossingInitializedTick, int24 nextTickInit) {
        return _isCrossingInitializedTick(pool, poolManager, poolKey, nextSqrtPriceX96);
    }
}
