pragma solidity ^0.8.0;
mapping(address => uint) userBalance_40;
function withdrawBalance_40() public{
(bool success,)=msg.sender.call.value(userBalance_40[msg.sender])("");
if( ! success ){
revert();
}
userBalance_40[msg.sender] = 0;
}