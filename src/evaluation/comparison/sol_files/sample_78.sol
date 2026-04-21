pragma solidity ^0.8.0;
function toggleWhitelist (bool active) public onlyOwner {
whitelistIsActive = active;
}