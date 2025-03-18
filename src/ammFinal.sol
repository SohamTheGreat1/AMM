// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract AMM{
    IERC20 public immutable token1;
    IERC20 public immutable token2;
    uint256 public token1reserve;
    uint256 public token2reserve;
    uint256 public totalSupply;
    uint256 public constantProduct = token1reserve * token2reserve;

    mapping(address => uint256) public balance;

    constructor(address _token1, address _token2, uint256 _token1reserve, uint256 _token2reserve) {
        token1 = IERC20(_token1);
        token2 = IERC20(_token2);
        token1reserve = _token1reserve;
        token2reserve = _token2reserve;
        totalSupply = 0;
    }

    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    function _mint(address to, uint256 _amount) public {
        balance[to] += _amount;
        totalSupply += _amount;
    }

    function _burn(address from, uint256 _amount) public {
        balance[from] -= _amount;
        totalSupply -= _amount;
    }

    function _update(uint256 _reserve1, uint256 _reserve2) public {
        token1reserve = _reserve1;
        token2reserve = _reserve2;
    }

    function addLiquidity(uint256 _amount1, uint256 _amount2) public returns (uint256 shares)
    {
        token1.transferFrom(msg.sender, address(this), _amount1);
        token2.transferFrom(msg.sender, address(this), _amount2);
        if (token1reserve > 0 || token2reserve > 0) {
            require(token1reserve * _amount2 == token2reserve * _amount1);
        }
        if (totalSupply == 0) {
            shares = sqrt(_amount1 * _amount2);
        } else {
            shares = min(
                (_amount1 * totalSupply) / token1reserve,
                (_amount2 * totalSupply) / token2reserve
            );
        }

        require(shares > 0);
        _mint(msg.sender, shares);
        _update(token1.balanceOf(address(this)), token2.balanceOf(address(this)));
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function removeLiquidity(uint256 _shares) public returns(uint256 amount1, uint256 amount2){ 
        uint256 bal1 = token1.balanceOf(address(this));
        uint256 bal2 = token2.balanceOf(address(this));

        amount1 = (_shares * bal1) / totalSupply;
        amount2 = (_shares * bal2) / totalSupply;
        require(amount1 > 0 && amount2 > 0);

        _burn(msg.sender, _shares);
        token1.transfer(msg.sender, amount1);
        token2.transfer(msg.sender, amount2);
    }

    function swap(address tokenAdded,uint256 addedTokenAmount) public {
        require(tokenAdded == address(token1) || tokenAdded == address(token2), "Token must be token1 or token2");
        require(addedTokenAmount > 0, "Added token amount must be greater than zero");

        uint256 swappedTokenAmount;
        

        if (tokenAdded == address(token1)) {
            token1.transferFrom(msg.sender, address(this), addedTokenAmount);
            swappedTokenAmount = (addedTokenAmount * token2reserve) / (token1reserve + addedTokenAmount);
            token2.transfer(msg.sender, swappedTokenAmount);
            token1reserve += addedTokenAmount;
            token2reserve -= swappedTokenAmount;
        } else {
            token2.transferFrom(msg.sender, address(this), addedTokenAmount);
            swappedTokenAmount = (addedTokenAmount * token1reserve) / (token2reserve + addedTokenAmount);
            token1.transfer(msg.sender, swappedTokenAmount);
            token2reserve += addedTokenAmount;
            token1reserve -= swappedTokenAmount;
        }
        emit Swap(msg.sender, tokenAdded, addedTokenAmount, swappedTokenAmount);
    }
    event Swap(address indexed sender, address tokenAdded, uint256 addedTokenAmount, uint256 swappedTokenAmount);

    function getReserves() public view returns (uint256, uint256) {
        return (token1reserve, token2reserve);
    }

    function getBalance(address account) public view returns (uint256) {
        return balance[account];
    }

    function getTotalSupply() public view returns (uint256) {
        return totalSupply;
    }
    
    function getTotalLiquidity() public view returns (uint256) {
        return token1reserve + token2reserve;
    }

    function getConstantProduct() public view returns (uint256) {
        return constantProduct;
    }

}