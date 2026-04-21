function release() public {

require(block.timestamp >= releaseTime);

uint256 amount = token.balanceOf(this);
require(amount > 0);

token.safeTransfer(beneficiary, amount);
}
}





pragma solidity ^0.4.21;