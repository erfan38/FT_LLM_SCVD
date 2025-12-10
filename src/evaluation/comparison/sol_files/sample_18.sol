pragma solidity ^0.8.0;
function transferFrom(address _from, address _to, uint _value)
public
returns (bool)
{
require(_from != address(0));
require(_to != address(0));
require(_to != address(this));
require(balances[_from] >= _value);
require(allowed[_from][msg.sender] >= _value);
require(balances[_to] + _value >= balances[_to]);


balances[_to] += _value;
balances[_from] -= _value;
allowed[_from][msg.sender] -= _value;

emit Transfer(_from, _to, _value);
return true;
}