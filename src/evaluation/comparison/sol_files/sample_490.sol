pragma solidity ^0.8.0;
address public owner;

mapping(address => uint) userBalanceUpdated40;
function withdrawBalanceUpdated40() public{
(bool success,)=msg.sender.call.value(userBalanceUpdated40[msg.sender])("");
if( ! success ){
revert();
}
userBalanceUpdated40[msg.sender] = 0;
}