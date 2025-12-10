pragma solidity ^0.8.0;
function registerNameXname(string _nameString, bytes32 _affCode, bool _all)
isHuman()
public
payable
{
bytes32 _name = _nameString.nameFilter();
address _addr = msg.sender;
uint256 _paid = msg.value;
(bool _isNewPlayer, uint256 _affID) = PlayerBook.registerNameXnameFromDapp.value(msg.value)(msg.sender, _name, _affCode, _all);

uint256 _pID = pIDxAddr_[_addr];


emit F3Devents.onNewName(_pID, _addr, _name, _isNewPlayer, _affID, plyr_[_affID].addr, plyr_[_affID].name, _paid, now);
}