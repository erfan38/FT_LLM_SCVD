pragma solidity ^0.8.0;
function withdrawFee(uint256 _amount) onlyOwner public {
require(now >= finishTime.add(30 days));
if (winner == address(0)) {
endGame();
}
feeAmount = feeAmount > _amount ? feeAmount.sub(_amount) : 0;
feeOwner.transfer(_amount);
}

}