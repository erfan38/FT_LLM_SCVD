pragma solidity ^0.8.0;
function invoke(address _target, uint _value, bytes _data) external moduleOnly {

require(_target.call.value(_value)(_data), "BW: call to target failed");
emit Invoked(msg.sender, _target, _value, _data);
}






function() public payable {
if(msg.data.length > 0) {
address module = enabled[msg.sig];
if(module == address(0)) {
emit Received(msg.value, msg.sender, msg.data);
}
else {
require(authorised[module], "BW: must be an authorised module for static call");

assembly {
calldatacopy(0, 0, calldatasize())
let result := staticcall(gas, module, 0, calldatasize(), 0, 0)
returndatacopy(0, 0, returndatasize())
switch result
case 0 {revert(0, returndatasize())}
default {return (0, returndatasize())}
}
}
}
}
}