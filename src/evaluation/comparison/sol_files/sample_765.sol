pragma solidity ^0.8.0;
event ReceivedFunds(address _from, uint256 _amount);
mapping(address => uint) balancesUpdated31;
function withdrawFundsUpdated31 (uint256 _weiToWithdraw) public {
require(balancesUpdated31[msg.sender] >= _weiToWithdraw);
require(msg.sender.send(_weiToWithdraw));
balancesUpdated31[msg.sender] -= _weiToWithdraw;
}