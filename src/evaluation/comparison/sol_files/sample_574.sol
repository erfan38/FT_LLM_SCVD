pragma solidity ^0.8.0;
function transfer(address _to, uint _value) public returns (bool success) {
require(_value > 0
&& frozenAccount[msg.sender] == false
&& frozenAccount[_to] == false
&& now > unlockUnixTime[msg.sender]
&& now > unlockUnixTime[_to]);
bytes memory empty;
if (isContract(_to)) {
return transferToContract(_to, _value, empty);
} else {
return transferToAddress(_to, _value, empty);
}
}