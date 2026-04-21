pragma solidity ^0.8.0;
function getPlayerVaults(uint256 _pID)
public
view
returns(uint256 ,uint256, uint256)
{

uint256 _rID = rID_;


if (now > round_[_rID].end && round_[_rID].ended == false && round_[_rID].plyr != 0)
{

if (round_[_rID].plyr == _pID)
{
return
(
(plyr_[_pID].win).add( ((round_[_rID].pot).mul(48)) / 100 ),
(plyr_[_pID].gen).add(  getPlayerVaultsHelper(_pID, _rID).sub(plyrRnds_[_pID][_rID].mask)   ),
plyr_[_pID].aff
);

} else {
return
(
plyr_[_pID].win,
(plyr_[_pID].gen).add(  getPlayerVaultsHelper(_pID, _rID).sub(plyrRnds_[_pID][_rID].mask)  ),
plyr_[_pID].aff
);
}


} else {
return
(
plyr_[_pID].win,
(plyr_[_pID].gen).add(calcUnMaskedEarnings(_pID, plyr_[_pID].lrnd)),
plyr_[_pID].aff
);
}
}