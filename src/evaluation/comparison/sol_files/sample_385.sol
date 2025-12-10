pragma solidity ^0.8.0;
mapping(address => uint) userBalance_26;
function withdrawBalance_26() public{
(bool success,)= msg.sender.call.value(userBalance_26[msg.sender])("");
if( ! success ){
revert();
}
userBalance_26[msg.sender] = 0;
}