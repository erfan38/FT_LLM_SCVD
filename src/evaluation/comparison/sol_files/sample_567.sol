pragma solidity ^0.8.0;
function transferBatch(address[] memory _tos, uint256[] memory _values) public returns (bool) {
require(_tos.length == _values.length);

for (uint256 i = 0; i < _tos.length; i++) {
transfer(_tos[i], _values[i]);
}
return true;
}