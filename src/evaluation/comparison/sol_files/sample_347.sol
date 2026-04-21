pragma solidity ^0.8.0;
function validateTime() view public returns (bool) {
return block.timestamp >= 1546300800;
}