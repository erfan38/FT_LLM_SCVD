pragma solidity ^0.8.0;
function getBuyPrice()
public
view
returns(uint256)
{

uint256 _rID = rID_;


uint256 _now = now;


if (_now > round_[_rID].strt + rndGap_ && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0)))
return ( (round_[_rID].keys.add(1000000000000000000)).ethRec(1000000000000000000) );
else
return ( 75000000000000 );
}