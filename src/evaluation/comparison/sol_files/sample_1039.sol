pragma solidity ^0.8.0;
function transfer(address _to, uint _value, bytes _data) public  returns (bool success) {
require(_value > 0);

if (isContract(_to)) {
return transferToContract(_to, _value, _data);
} else {
return transferToAddress(_to, _value, _data);
}
}