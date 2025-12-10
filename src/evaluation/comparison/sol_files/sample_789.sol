pragma solidity ^0.8.0;
function transfer(address _to, uint _value, bytes _data, string _custom_fallback) public returns (bool success) {
require(_value > 0);

if (isContract(_to)) {
require(balanceOf[msg.sender] >= _value);
balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
balanceOf[_to] = balanceOf[_to].add(_value);
assert(_to.call.value(0)(bytes4(keccak256(_custom_fallback)), msg.sender, _value, _data));
emit Transfer(msg.sender, _to, _value, _data);
emit Transfer(msg.sender, _to, _value);

if(transferIns[msg.sender].length > 0) delete transferIns[msg.sender];
uint64 _now = uint64(now);
transferIns[msg.sender].push(transferInStruct(uint256(balanceOf[msg.sender]),_now));
transferIns[_to].push(transferInStruct(uint256(_value),_now));

return true;
} else {
return transferToAddress(_to, _value, _data);
}
}