// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {Script} from "forge-std/Script.sol";
import "forge-std/console.sol";
import {Hooks} from "@uniswap/v4-core/contracts/libraries/Hooks.sol";
import {VolatilityOracle} from "../contracts/hooks/examples/VolatilityOracle.sol";
import {PoolManager} from "@uniswap/v4-core/contracts/PoolManager.sol";
import {IPoolManager} from "@uniswap/v4-core/contracts/interfaces/IPoolManager.sol";
import {Deployers} from "@uniswap/v4-core/test/foundry-tests/utils/Deployers.sol";
import {TokenFixture} from "@uniswap/v4-core/test/foundry-tests/utils/TokenFixture.sol";
import {TestERC20} from "@uniswap/v4-core/contracts/test/TestERC20.sol";
import {CurrencyLibrary, Currency} from "@uniswap/v4-core/contracts/types/Currency.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/contracts/types/PoolId.sol";
import {PoolModifyPositionTest} from "@uniswap/v4-core/contracts/test/PoolModifyPositionTest.sol";
import {TickMath} from "@uniswap/v4-core/contracts/libraries/TickMath.sol";
import {Oracle} from "../contracts/libraries/Oracle.sol";
import {PoolKey} from "@uniswap/v4-core/contracts/types/PoolKey.sol";
import {HookMiner} from "./utils/HookMiner.sol";

// modify from contract TestGeomeanOracle is Test, Deployers, TokenFixture {
contract Deployer is Script, Deployers, TokenFixture {
    using PoolIdLibrary for PoolKey;

    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    address deployerPublicKey = vm.envAddress("PUBLIC_KEY");

    int24 constant MAX_TICK_SPACING = 32767;
    uint160 constant SQRT_RATIO_2_1 = 112045541949572279837463876454;

    TestERC20 token0;
    TestERC20 token1;
    PoolManager manager;
    PoolKey key;
    PoolId id;

    PoolModifyPositionTest modifyPositionRouter;

    function run() public {
        setUp();
    }

    function setUp() public {
        initializeTokens();
        token0 = TestERC20(Currency.unwrap(currency0));
        token1 = TestERC20(Currency.unwrap(currency1));

        manager = new PoolManager(500000);

        // hook contracts must have specific flags encoded in the address
        uint160 flags = uint160(Hooks.BEFORE_INITIALIZE_FLAG); // | other if needed

        // Mine a salt that will produce a hook address with the correct flags
        (address hookAddress, bytes32 salt) = HookMiner.find(
            deployerPublicKey,
            flags,
            1000,
            type(VolatilityOracle).creationCode,
            abi.encode(address(manager))
        );
        // Deploy the hook using CREATE2
        vm.startBroadcast(deployerPrivateKey);
        VolatilityOracle volatilityOracle = new VolatilityOracle{salt: salt}(
            IPoolManager(address(manager))
        );
        require(
            address(volatilityOracle) == hookAddress,
            "CounterScript: hook address mismatch"
        );

        // key = PoolKey(
        //     currency0,
        //     currency1,
        //     0,
        //     MAX_TICK_SPACING,
        //     volatilityOracle
        // );

        // id = key.toId();

        // modifyPositionRouter = new PoolModifyPositionTest(manager);

        // token0.approve(address(volatilityOracle), type(uint256).max);
        // token1.approve(address(volatilityOracle), type(uint256).max);
        // token0.approve(address(modifyPositionRouter), type(uint256).max);
        // token1.approve(address(modifyPositionRouter), type(uint256).max);
        vm.stopBroadcast();
    }
}
