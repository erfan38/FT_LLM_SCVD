pragma solidity ^0.8.0;
function setTokenPorter(address _tokenPorter) public onlyOwner returns (bool) {
require(_tokenPorter != 0x0);
tokenPorter = _tokenPorter;
return true;
}