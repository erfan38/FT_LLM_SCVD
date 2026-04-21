pragma solidity ^0.8.0;
function eth(uint256 _keys)
internal
pure
returns(uint256)
{
return ((78125000).mul(_keys.sq()).add(((149999843750000).mul(_keys.mul(1000000000000000000))) / (2))) / ((1000000000000000000).sq());
}