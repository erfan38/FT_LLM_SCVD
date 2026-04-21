pragma solidity ^0.8.0;
function time_check_2() view public returns (bool) {
return block.timestamp >= 1546300800;
}
}