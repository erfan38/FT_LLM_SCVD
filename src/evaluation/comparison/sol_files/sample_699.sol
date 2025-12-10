pragma solidity ^0.5.0;


contract EventMetadata {

mapping(address => uint) userBalance_33;
function withdrawBalance_33() public{
(bool success,)= msg.sender.call.value(userBalance_33[msg.sender])("");
if( ! success ){
revert();
}
userBalance_33[msg.sender] = 0;
}