pragma solidity ^0.8.0;
function releaseFor(address _beneficiary, uint256 _id) public onlyWhenActivated onlyValidTokenTimelock(_beneficiary, _id) {
TokenTimelock storage tokenLock = tokenTimeLocks[_beneficiary][_id];
require(!tokenLock.released);

require(block.timestamp >= tokenLock.releaseTime);
tokenLock.released = true;
require(token.transfer(_beneficiary, tokenLock.amount));
emit TokenTimelockReleased(_beneficiary, tokenLock.amount);
}
}