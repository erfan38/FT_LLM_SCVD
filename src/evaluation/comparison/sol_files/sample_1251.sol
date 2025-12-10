pragma solidity ^0.4.21;

contract TokenSaleChallenge {
mapping(address => uint256) public balanceOf;
uint256 constant PRICE_PER_TOKEN = 1 ether;

function TokenSaleChallenge(address _player) public payable {
require(msg.value == 1 ether);
}