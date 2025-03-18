//SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {AMM} from "src/ammFinal.sol";
import {deployAMM} from "script/deployAMM.s.sol";
import {ERC20Mock} from "lib/openzeppelin-contracts/contracts/mocks/token/ERC20Mock.sol";

contract AMMTest is Test {

    ERC20Mock token1 = new ERC20Mock();
    ERC20Mock token2 = new ERC20Mock();
    AMM amm = new AMM(address(token1), address(token2), 1000, 1000);


    function testConstantProduct() public view{
        uint256 token1reserve = amm.token1reserve();
        uint256 token2reserve = amm.token2reserve();
        uint256 constantProduct = amm.constantProduct();
        console.log("token1reserve: ", token1reserve);
        console.log("token2reserve: ", token2reserve);
        console.log("constantProduct: ", constantProduct);
        assertEq(constantProduct, token1reserve * token2reserve);
    }

    function testAddLiquidity() public {
        amm.addLiquidity(1000, 1000);
        assertEq(amm.totalSupply(), 1000);
    }

    function testNonNegative() public view {
        assertGe(amm.token1reserve(), 0);
        assertGe(amm.token2reserve(), 0);
    }

    function testRemoveLiquidity() public {
        amm.addLiquidity(1000, 1000);
        uint256 initialSupply = amm.totalSupply();
        amm.removeLiquidity(500);
        assertEq(amm.totalSupply(), initialSupply - 500);
    }

    function testSwap() public {
        amm.addLiquidity(1000, 1000);
        uint256 initialToken1Reserve = amm.token1reserve();
        uint256 initialToken2Reserve = amm.token2reserve();
        amm.swap(address(token1), 100);
        assertEq(amm.token1reserve(), initialToken1Reserve + 100);
        assertEq(amm.token2reserve(), initialToken2Reserve - 100);
    }

}