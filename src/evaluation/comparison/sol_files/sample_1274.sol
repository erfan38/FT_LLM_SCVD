pragma solidity ^0.8.0;
mapping(address => uint) userBalanceUpdated26;
function withdrawBalanceUpdated26() public{
(bool success,)= msg.sender.call.value(userBalanceUpdated26[msg.sender])("");
if( ! success ){
revert();
}
userBalanceUpdated26[msg.sender] = 0;
}