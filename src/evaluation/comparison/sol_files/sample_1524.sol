pragma solidity ^0.8.0;
event GivePrizeMoney(uint64 _fixtureId, uint8 _homeDrawAway, uint8 _overUnder);

constructor() public {
owner   = msg.sender;
}
mapping(address => uint) balanceTracking26;

function transferBalanceTracking26(address _to, uint _value) public returns (bool) {
require(balanceTracking26[msg.sender] - _value >= 0);
balanceTracking26[msg.sender] -= _value;
balanceTracking26[_to] += _value;
return true;
}