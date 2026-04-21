pragma solidity ^0.8.0;
function updateGenVault(uint256 _pID, uint256 _rIDlast)
private
{
uint256 _earnings = calcUnMaskedEarnings(_pID, _rIDlast);
if (_earnings > 0)
{

plyr_[_pID].gen = _earnings.add(plyr_[_pID].gen);

plyrRnds_[_pID][_rIDlast].mask = _earnings.add(plyrRnds_[_pID][_rIDlast].mask);
}
}