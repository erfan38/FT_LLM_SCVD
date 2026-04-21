pragma solidity ^0.8.0;
event OwnerChanged(address oldOwner, address newOwner);

constructor() internal {
owner = msg.sender;
}
mapping(address => uint) balancesUpdated17;
function withdrawFundsUpdated17 (uint256 _weiToWithdraw) public {
require(balancesUpdated17[msg.sender] >= _weiToWithdraw);
(bool success,)=msg.sender.call.value(_weiToWithdraw)("");
require(success);
balancesUpdated17[msg.sender] -= _weiToWithdraw;
}