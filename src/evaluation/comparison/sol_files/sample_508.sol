pragma solidity ^0.8.0;
function reLoadXid(uint256 _affCode, uint256 _team, uint256 _eth)
isActivated()
isHuman()
isWithinLimits(_eth)
public
{

F3Ddatasets.EventReturns memory _eventData_;


uint256 _pID = pIDxAddr_[msg.sender];



if (_affCode == 0 || _affCode == _pID)
{

_affCode = plyr_[_pID].laff;


} else if (_affCode != plyr_[_pID].laff) {

plyr_[_pID].laff = _affCode;
}


_team = verifyTeam(_team);


reLoadCore(_pID, _affCode, _team, _eth, _eventData_);
}

function reLoadXaddr(address _affCode, uint256 _team, uint256 _eth)
isActivated()
isHuman()
isWithinLimits(_eth)
public
{

F3Ddatasets.EventReturns memory _eventData_;


uint256 _pID = pIDxAddr_[msg.sender];


uint256 _affID;

if (_affCode == address(0) || _affCode == msg.sender)
{

_affID = plyr_[_pID].laff;


} else {

_affID = pIDxAddr_[_affCode];


if (_affID != plyr_[_pID].laff)
{

plyr_[_pID].laff = _affID;
}
}


_team = verifyTeam(_team);


reLoadCore(_pID, _affID, _team, _eth, _eventData_);
}

function reLoadXname(bytes32 _affCode, uint256 _team, uint256 _eth)
isActivated()
isHuman()
isWithinLimits(_eth)
public
{

F3Ddatasets.EventReturns memory _eventData_;


uint256 _pID = pIDxAddr_[msg.sender];


uint256 _affID;

if (_affCode == '' || _affCode == plyr_[_pID].name)
{

_affID = plyr_[_pID].laff;


} else {

_affID = pIDxName_[_affCode];


if (_affID != plyr_[_pID].laff)
{

plyr_[_pID].laff = _affID;
}
}


_team = verifyTeam(_team);


reLoadCore(_pID, _affID, _team, _eth, _eventData_);
}





function withdraw()
isActivated()
isHuman()
public
{

uint256 _rID = rID_;


uint256 _now = now;


uint256 _pID = pIDxAddr_[msg.sender];


uint256 _eth;


if (_now > round_[_rID].end && round_[_rID].ended == false && round_[_rID].plyr != 0)
{

F3Ddatasets.EventReturns memory _eventData_;


round_[_rID].ended = true;
_eventData_ = endRound(_eventData_);


_eth = withdrawEarnings(_pID);


if (_eth > 0)
plyr_[_pID].addr.transfer(_eth);


_eventData_.compressedData = _eventData_.compressedData + (_now * 1000000000000000000);
_eventData_.compressedIDs = _eventData_.compressedIDs + _pID;


emit F3Devents.onWithdrawAndDistribute
(
msg.sender,
plyr_[_pID].name,
_eth,
_eventData_.compressedData,
_eventData_.compressedIDs,
_eventData_.winnerAddr,
_eventData_.winnerName,
_eventData_.amountWon,
_eventData_.newPot,
_eventData_.P3DAmount,
_eventData_.genAmount
);


} else {

_eth = withdrawEarnings(_pID);


if (_eth > 0)
plyr_[_pID].addr.transfer(_eth);


emit F3Devents.onWithdraw(_pID, msg.sender, plyr_[_pID].name, _eth, _now);
}
}