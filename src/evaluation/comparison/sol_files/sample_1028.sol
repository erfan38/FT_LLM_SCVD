pragma solidity ^0.4.24;













































contract WorldFomo is modularShort {
using SafeMath for *;
using NameFilter for string;
using F3DKeysCalcShort for uint256;

PlayerBookInterface constant private PlayerBook = PlayerBookInterface(0x6ed17ee485821cd47531f2e4c7b9ef8b48f2bab5);





address private admin = msg.sender;
string constant public name = "WorldFomo";
string constant public symbol = "WF";
uint256 private rndExtra_ = 15 seconds;
uint256 private rndGap_ = 30 minutes;
uint256 constant private rndInit_ = 30 minutes;
uint256 constant private rndInc_ = 10 seconds;
uint256 constant private rndMax_ = 12 hours;




uint256 public airDropPot_;
uint256 public airDropTracker_ = 0;
uint256 public rID_;



mapping (address => uint256) public pIDxAddr_;
mapping (bytes32 => uint256) public pIDxName_;
mapping (uint256 => F3Ddatasets.Player) public plyr_;
mapping (uint256 => mapping (uint256 => F3Ddatasets.PlayerRounds)) public plyrRnds_;
mapping (uint256 => mapping (bytes32 => bool)) public plyrNames_;



mapping (uint256 => F3Ddatasets.Round) public round_;
mapping (uint256 => mapping(uint256 => uint256)) public rndTmEth_;



mapping (uint256 => F3Ddatasets.TeamFee) public fees_;
mapping (uint256 => F3Ddatasets.PotSplit) public potSplit_;




constructor()
public
{









fees_[0] = F3Ddatasets.TeamFee(32,0);
fees_[1] = F3Ddatasets.TeamFee(45,0);
fees_[2] = F3Ddatasets.TeamFee(62,0);
fees_[3] = F3Ddatasets.TeamFee(47,0);



potSplit_[0] = F3Ddatasets.PotSplit(47,0);
potSplit_[1] = F3Ddatasets.PotSplit(47,0);
potSplit_[2] = F3Ddatasets.PotSplit(62,0);
potSplit_[3] = F3Ddatasets.PotSplit(62,0);
}








modifier isActivated() {
require(activated_ == true, "its not ready yet.  check ?eta in discord");
_;
}




modifier isHuman() {
require(msg.sender == tx.origin, "sorry humans only - FOR REAL THIS TIME");
_;
}




modifier isWithinLimits(uint256 _eth) {
require(_eth >= 1000000000, "pocket lint: not a valid currency");
require(_eth <= 100000000000000000000000, "no vitalik, no");
_;
}








function()
isActivated()
isHuman()
isWithinLimits(msg.value)
public
payable
{

F3Ddatasets.EventReturns memory _eventData_ = determinePID(_eventData_);


uint256 _pID = pIDxAddr_[msg.sender];


buyCore(_pID, plyr_[_pID].laff, 2, _eventData_);
}









function buyXid(uint256 _affCode, uint256 _team)
isActivated()
isHuman()
isWithinLimits(msg.value)
public
payable
{

F3Ddatasets.EventReturns memory _eventData_ = determinePID(_eventData_);


uint256 _pID = pIDxAddr_[msg.sender];



if (_affCode == 0 || _affCode == _pID)
{

_affCode = plyr_[_pID].laff;


} else if (_affCode != plyr_[_pID].laff) {

plyr_[_pID].laff = _affCode;
}


_team = verifyTeam(_team);


buyCore(_pID, _affCode, _team, _eventData_);
}