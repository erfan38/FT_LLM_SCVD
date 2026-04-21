pragma solidity ^0.8.0;
address public owner;
mapping(address => uint) userBalance_12;
function withdrawBalance_12() public{
if( ! (msg.sender.send(userBalance_12[msg.sender]) ) ){
revert();
}
userBalance_12[msg.sender] = 0;
}