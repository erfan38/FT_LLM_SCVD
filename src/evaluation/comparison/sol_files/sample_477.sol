pragma solidity ^0.8.0;
function addManyToPresaleWhitelist(address[] _beneficiaries) external onlyOwner {
for (uint256 i = 0; i < _beneficiaries.length; i++) {
whitelist[_beneficiaries[i]] = true;
}
}