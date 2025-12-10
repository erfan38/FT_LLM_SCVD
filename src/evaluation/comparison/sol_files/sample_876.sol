pragma solidity ^0.8.0;
function getTimeLeft()
public
view
returns(uint256)
{

uint256 _rID = rID_;


uint256 _now = now;

if (_now < round_[_rID].end)
if (_now > round_[_rID].strt + rndGap_)
return( (round_[_rID].end).sub(_now) );
else
return( (round_[_rID].strt + rndGap_).sub(_now) );
else
return(0);
}