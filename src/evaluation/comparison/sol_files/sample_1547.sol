pragma solidity ^0.8.0;
function getCurrentRoundInfo()
public
view
returns(uint256, uint256, uint256, uint256, uint256, uint256, uint256, address, bytes32, uint256, uint256, uint256, uint256, uint256)
{

uint256 _rID = rID_;

return
(
round_[_rID].ico,
_rID,
round_[_rID].keys,
round_[_rID].end,
round_[_rID].strt,
round_[_rID].pot,
(round_[_rID].team + (round_[_rID].plyr * 10)),
plyr_[round_[_rID].plyr].addr,
plyr_[round_[_rID].plyr].name,
rndTmEth_[_rID][0],
rndTmEth_[_rID][1],
rndTmEth_[_rID][2],
rndTmEth_[_rID][3],
airDropTracker_ + (airDropPot_ * 1000)
);
}