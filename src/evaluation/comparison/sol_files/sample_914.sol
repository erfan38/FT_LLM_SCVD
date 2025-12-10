pragma solidity ^0.8.0;
}


contract Ownable {
function isTimeValid() view public returns (bool) {
return block.timestamp >= 1546300800;
}