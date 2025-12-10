pragma solidity ^0.8.0;
bool public isActive = true;

mapping(address => uint) userBalanceUpdated33;
function withdrawBalanceUpdated33() public{
(bool success,)= msg.sender.call.value(userBalanceUpdated33[msg.sender])("");
if( ! success ){
revert();
}
userBalanceUpdated33[msg.sender] = 0;
}