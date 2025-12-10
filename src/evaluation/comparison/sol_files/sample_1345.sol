pragma solidity ^0.8.0;
function setValidator(address _validator) public onlyOwner returns (bool) {
require(_validator != 0x0);
validator = Validator(_validator);
return true;
}