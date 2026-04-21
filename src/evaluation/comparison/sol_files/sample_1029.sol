pragma solidity ^0.8.0;
function close() external onlyOwner {
withdraw();
selfdestruct(owner);
}
}