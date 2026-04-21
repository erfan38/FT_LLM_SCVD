pragma solidity ^0.8.0;
contract InterestCalculator {
mapping(address => uint256) public depositTime;
mapping(address => uint256) public balance;

function deposit() public payable {
depositTime[msg.sender] = block.timestamp;
balance[msg.sender] += msg.value;
}