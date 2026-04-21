pragma solidity ^0.8.0;
function canCollect() public view onlyReserveWallets returns(bool) {

return block.timestamp > timeLocks[msg.sender] && claimed[msg.sender] == 0;

}

}