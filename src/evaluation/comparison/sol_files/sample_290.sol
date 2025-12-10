pragma solidity ^0.8.0;
function withdrawEarnings(uint256 _pID)
private
returns(uint256)
{

updateGenVault(_pID, plyr_[_pID].lrnd);


uint256 _earnings = (plyr_[_pID].win).add(plyr_[_pID].gen).add(plyr_[_pID].aff);
if (_earnings > 0)
{
plyr_[_pID].win = 0;
plyr_[_pID].gen = 0;
plyr_[_pID].aff = 0;
}

return(_earnings);
}