pragma solidity ^0.8.0;
function receivePlayerNameList(uint256 _pID, bytes32 _name)
external
{
require (msg.sender == address(PlayerBook), "your not playerNames contract... hmmm..");
if (plyrNames_[_pID][_name] == false)
plyrNames_[_pID][_name] = true;
}