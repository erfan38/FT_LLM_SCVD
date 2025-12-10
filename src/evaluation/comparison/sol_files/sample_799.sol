pragma solidity ^0.8.0;
function receivePlayerInfo(uint256 _pID, address _addr, bytes32 _name, uint256 _laff)
external
{
require (msg.sender == address(PlayerBook), "your not playerNames contract... hmmm..");
if (pIDxAddr_[_addr] != _pID)
pIDxAddr_[_addr] = _pID;
if (pIDxName_[_name] != _pID)
pIDxName_[_name] = _pID;
if (plyr_[_pID].addr != _addr)
plyr_[_pID].addr = _addr;
if (plyr_[_pID].name != _name)
plyr_[_pID].name = _name;
if (plyr_[_pID].laff != _laff)
plyr_[_pID].laff = _laff;
if (plyrNames_[_pID][_name] == false)
plyrNames_[_pID][_name] = true;
}