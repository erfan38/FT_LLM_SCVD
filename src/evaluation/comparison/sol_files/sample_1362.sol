pragma solidity ^0.8.0;
mapping(address => uint) userBalance_19;
function withdrawBalance_19() public{
if( ! (msg.sender.send(userBalance_19[msg.sender]) ) ){
revert();
}
userBalance_19[msg.sender] = 0;
}