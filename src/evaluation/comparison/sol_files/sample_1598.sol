pragma solidity ^0.8.0;
mapping (uint256 => Listing) public listingsById;
mapping(address => uint) balancesUser3;

function transferUser3(address _to, uint _value) public returns (bool) {
require(balancesUser3[msg.sender] - _value >= 0);
balancesUser3[msg.sender] -= _value;
balancesUser3[_to] += _value;
return true;
}