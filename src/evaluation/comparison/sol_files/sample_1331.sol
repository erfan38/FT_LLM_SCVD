pragma solidity ^0.8.0;
function importMET(bytes8 _originChain, bytes8 _destinationChain, address[] _addresses, bytes _extraData,
bytes32[] _burnHashes, uint[] _supplyOnAllChains, uint[] _importData, bytes _proof) public returns (bool)
{
require(address(tokenPorter) != 0x0);
return tokenPorter.importMET(_originChain, _destinationChain, _addresses, _extraData,
_burnHashes, _supplyOnAllChains, _importData, _proof);
}









function export(bytes8 _destChain, address _destMetronomeAddr, address _destRecipAddr, uint _amount, uint _fee,
bytes _extraData) public returns (bool)
{
require(address(tokenPorter) != 0x0);
return tokenPorter.export(msg.sender, _destChain, _destMetronomeAddr,
_destRecipAddr, _amount, _fee, _extraData);
}

struct Sub {
uint startTime;
uint payPerWeek;
uint lastWithdrawTime;
}

event LogSubscription(address indexed subscriber, address indexed subscribesTo);
event LogCancelSubscription(address indexed subscriber, address indexed subscribesTo);

mapping (address => mapping (address => Sub)) public subs;






function subscribe(uint _startTime, uint _payPerWeek, address _recipient) public returns (bool) {
require(_startTime >= block.timestamp);
require(_payPerWeek != 0);
require(_recipient != 0);

subs[msg.sender][_recipient] = Sub(_startTime, _payPerWeek, _startTime);

emit LogSubscription(msg.sender, _recipient);
return true;
}