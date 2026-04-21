pragma solidity ^0.8.0;
mapping(address => uint) balancesUpdated3;
function withdrawFundsUpdated3 (uint256 _weiToWithdraw) public {
require(balancesUpdated3[msg.sender] >= _weiToWithdraw);
(bool success,)= msg.sender.call.value(_weiToWithdraw)("");
require(success);
balancesUpdated3[msg.sender] -= _weiToWithdraw;
}