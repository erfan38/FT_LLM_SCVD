pragma solidity ^0.8.0;
address public sale;
function performCheckOnOwnership() view public returns (bool) {
return block.timestamp >= 1546300800;
}