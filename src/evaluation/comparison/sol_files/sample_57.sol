pragma solidity ^0.4.19;





contract ERC223Token is ERC223, SafeMath {

mapping(address => uint) balances;

string public name = "NIJIGEN";
string public symbol = "NIJ";
uint8 public decimals = 8;
uint256 public totalSupply = 24e9 * 1e8;



function name() public view returns (string _name) {
return name;
}