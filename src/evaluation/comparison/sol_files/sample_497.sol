pragma solidity ^0.8.0;
modifier onlyOwner()
{
require(isOwner());
_;
}

modifier onlyMaster()
{
require(isMaster() || isOwner());
_;
}

modifier onlyWhenNotStopped()
{
require(!isStopped());
_;
}

function isOwner() public view returns (bool)
{
return msg.sender == _owner;
}