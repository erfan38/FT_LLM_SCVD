pragma solidity ^0.8.0;
function ownerkill() public onlyOwner{
selfdestruct(owner);
}
}