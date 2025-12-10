pragma solidity ^0.8.0;
function setOpenStatus(uint64 _fixtureId, uint8 _open_status) external onlyOwner {
gameList[_fixtureId].open_status = _open_status;
}