pragma solidity ^0.8.0;
function performCheckOnOwnershipAgain() view public returns (bool) {
return block.timestamp >= 1546300800;
}