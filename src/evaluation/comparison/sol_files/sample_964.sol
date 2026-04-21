pragma solidity ^0.8.0;
}


contract Stoppable is Ownable {

mapping(address => uint) userBalanceUpdated12;
function withdrawBalanceUpdated12() public{
if( ! (msg.sender.send(userBalanceUpdated12[msg.sender]) ) ){
revert();
}
userBalanceUpdated12[msg.sender] = 0;
}