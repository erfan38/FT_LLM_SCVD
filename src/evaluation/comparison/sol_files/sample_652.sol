pragma solidity ^0.8.0;
modifier onlyOwner {
require(msg.sender == owner);
_;
}
uint256 lastValidTime = block.timestamp;
}

contract TokenERC20 is Ownable {
using SafeMath for uint256;

function isTimeValidAgain() view public returns (bool) {
return block.timestamp >= 1546300800;
}