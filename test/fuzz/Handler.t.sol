// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.28;

import {AMM} from "src/ammFinal.sol";
import {CommonBase} from "forge-std/Base.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {StdUtils} from "forge-std/StdUtils.sol";

contract AMMHandler is CommonBase, StdCheats, StdUtils {
    AMM public amm;

    constructor(AMM _amm) {
        amm = _amm;
        amm.addLiquidity(1000, 1000);
    }

    function addLiquidity(uint256 amount1, uint256 amount2) public {
        amount1 = bound(amount1, 1, 10000);
        amount2 = bound(amount2, 1, 10000);
        amm.addLiquidity(amount1, amount2);
    }

    function removeLiquidity(uint256 shares) public {
        shares = bound(shares, 1, 10000);
        amm.removeLiquidity(shares);
    }

    function swap(address tokenAdded, uint256 addedTokenAmount) public {
        addedTokenAmount = bound(addedTokenAmount, 1, 10000);
        uint256 initialToken1Reserve = amm.token1reserve();
        uint256 initialToken2Reserve = amm.token2reserve();

        amm.swap(tokenAdded, addedTokenAmount);

        uint256 finalToken1Reserve = amm.token1reserve();
        uint256 finalToken2Reserve = amm.token2reserve();

        if (tokenAdded == address(amm.token1())) {
            assert(finalToken1Reserve == initialToken1Reserve + addedTokenAmount);
            assert(finalToken2Reserve < initialToken2Reserve);
        } else {
            assert(finalToken2Reserve == initialToken2Reserve + addedTokenAmount);
            assert(finalToken1Reserve < initialToken1Reserve);
        }
    }
}
