pragma solidity ^0.8.0;
}


contract BasicToken is ERC20Basic {
using SafeMath for uint256;

mapping(address => uint256) balances;

uint256 totalSupply_;


function totalSupply() public view returns (uint256) {
return totalSupply_;
}