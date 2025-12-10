pragma solidity ^0.8.0;
function changeSafeguardStatus() onlyOwner public
{
if (safeGuard == false)
{
safeGuard = true;
}
else
{
safeGuard = false;
}
}