}


pragma solidity ^0.5.2;


contract ERC20Burnable is ERC20 {
function burn(uint256 value) public {
_burn(msg.sender, value);
}