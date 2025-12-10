pragma solidity ^0.8.0;
function determinePID(MC2datasets.EventReturns memory _eventData_)
private
returns (MC2datasets.EventReturns)
{
uint256 _pID = pIDxAddr_[msg.sender];

if (_pID == 0)
{

_pID = PlayerBook.getPlayerID(msg.sender);
bytes32 _name = PlayerBook.getPlayerName(_pID);
uint256 _laff = PlayerBook.getPlayerLAff(_pID);


pIDxAddr_[msg.sender] = _pID;
plyr_[_pID].addr = msg.sender;

if (_name != "")
{
pIDxName_[_name] = _pID;
plyr_[_pID].name = _name;
plyrNames_[_pID][_name] = true;
}

if (_laff != 0 && _laff != _pID)
plyr_[_pID].laff = _laff;


_eventData_.compressedData = _eventData_.compressedData + 1;
}
return (_eventData_);
}