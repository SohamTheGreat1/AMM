// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.28;

import {Script} from "forge-std/Script.sol";
import {ERC20Mock} from "../lib/openzeppelin-contracts/contracts/mocks/token/ERC20Mock.sol";
import {AMM} from "../src/ammFinal.sol";

contract deployAMM is Script {
    uint256 public token1reserve = 1000;
    uint256 public token2reserve = 1000;

    function run() external returns(ERC20Mock token1, ERC20Mock token2, AMM amm) {
        vm.startBroadcast();
        token1 = new ERC20Mock();
        token2 = new ERC20Mock();

        amm = new AMM(address(token1), address(token2), token1reserve, token2reserve);
        vm.stopBroadcast();
        return (token1, token2, amm);
    }
}