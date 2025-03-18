// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {AMM} from "src/ammFinal.sol";
import {AMMHandler} from "./Handler.t.sol";
import {ERC20Mock} from "../../lib/openzeppelin-contracts/contracts/mocks/token/ERC20Mock.sol";

contract AMMHandlerTest is Test {
    AMM public amm;
    AMMHandler public handler;

    function setUp() public {
        ERC20Mock token1 = new ERC20Mock();
        ERC20Mock token2 = new ERC20Mock();
        amm = new AMM(address(token1), address(token2), 10000, 10000);

        token1.mint(address(this), 10000);
        token2.mint(address(this), 10000);

        token1.approve(address(amm), 10000);
        token2.approve(address(amm), 10000);
    }

    function testFuzz_AddLiquidity(uint256 amount1, uint256 amount2) public {
        amount1 = bound(amount1, 1, 10000);
        amount2 = bound(amount2, 1, 10000);
        uint256 initialToken1Reserve = amm.token1reserve();
        uint256 initialToken2Reserve = amm.token2reserve();
        uint256 initialTotalSupply = amm.totalSupply();

        handler.addLiquidity(amount1, amount2);
        uint256 finalToken1Reserve = amm.token1reserve();
        uint256 finalToken2Reserve = amm.token2reserve();
        uint256 finalTotalSupply = amm.totalSupply();

        assert(finalToken1Reserve == initialToken1Reserve + amount1);
        assert(finalToken2Reserve == initialToken2Reserve + amount2);
        assert(finalTotalSupply > initialTotalSupply);
    }

    function testFuzz_RemoveLiquidity(uint256 shares) public {
        shares = bound(shares, 1, 10000);
        uint256 initialToken1Reserve = amm.token1reserve();
        uint256 initialToken2Reserve = amm.token2reserve();
        uint256 initialTotalSupply = amm.totalSupply();

        handler.removeLiquidity(shares);
        uint256 finalToken1Reserve = amm.token1reserve();
        uint256 finalToken2Reserve = amm.token2reserve();
        uint256 finalTotalSupply = amm.totalSupply();

        assert(finalToken1Reserve < initialToken1Reserve);
        assert(finalToken2Reserve < initialToken2Reserve);
        assert(finalTotalSupply < initialTotalSupply);
    }

    function testFuzz_Swap(address tokenAdded ,uint256 addedTokenAmount) public {
        addedTokenAmount = bound(addedTokenAmount, 1, 10000);
        uint256 initialToken1Reserve = amm.token1reserve();
        uint256 initialToken2Reserve = amm.token2reserve();

        handler.swap(tokenAdded, addedTokenAmount);
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