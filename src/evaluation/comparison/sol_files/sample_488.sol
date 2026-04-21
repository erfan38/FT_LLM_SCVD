pragma solidity ^0.8.0;
function buyWithCustomerId(uint128 customerId) public stopInEmergency payable {
invest(customerId);
}