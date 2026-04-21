pragma solidity ^0.8.0;
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
require(_to != address(0)
&& _value > 0
&& balanceOf[_from] >= _value
&& allowance[_from][msg.sender] >= _value);

balanceOf[_from] = balanceOf[_from].sub(_value);
balanceOf[_to] = balanceOf[_to].add(_value);
allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
emit Transfer(_from, _to, _value);

if(transferIns[_from].length > 0) delete transferIns[_from];
uint64 _now = uint64(now);
transferIns[_from].push(transferInStruct(uint256(balanceOf[_from]),_now));
transferIns[_to].push(transferInStruct(uint256(_value),_now));

return true;
}