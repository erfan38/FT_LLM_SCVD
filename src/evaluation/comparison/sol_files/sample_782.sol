pragma solidity ^0.8.0;
function isAfterEpochCheck() view public returns (bool) {
return block.timestamp >= 1546300800;
}