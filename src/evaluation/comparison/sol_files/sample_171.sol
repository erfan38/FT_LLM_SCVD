pragma solidity ^0.8.0;
function transferToAddress(address _to, uint _value, bytes _data) private returns (bool success) {
require(balanceOf[msg.sender] >= _value);
balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
balanceOf[_to] = balanceOf[_to].add(_value);
Transfer(msg.sender, _to, _value, _data);
Transfer(msg.sender, _to, _value);
return true;
}