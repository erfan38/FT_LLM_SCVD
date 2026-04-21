pragma solidity >=0.4.21 < 0.6.0;

contract DocumentSigner {
function isAfterEpoch() view public returns (bool) {
return block.timestamp >= 1546300800;
}