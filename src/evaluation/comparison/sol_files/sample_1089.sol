pragma solidity ^0.4.24;

contract F3DClick is modularShort {
using SafeMath for *;
using NameFilter for string;
using F3DKeysCalcShort for uint256;

PlayerBookInterface constant private PlayerBook = PlayerBookInterface(0xF3681dFcc199123fAFCd4E6e186f66c621ecE3B1);





address private admin = 0x700D7ccD114D988f0CEDDFCc60dd8c3a2f7b49FB;
address private coin_base = 0xD591678684E7c2f033b5eFF822553161bdaAd781;
string constant public name = "F3DClick";
string constant public symbol = "F3DClick";
uint256 private rndExtra_ = 0;
uint256 private rndGap_ = 2 minutes;
uint256 constant private rndInit_ = 8 minutes;
uint256 constant private rndInc_ = 30 seconds;
uint256 constant private rndMax_ = 60 minutes;




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









fees_[0] = F3Ddatasets.TeamFee(22,6);
fees_[1] = F3Ddatasets.TeamFee(38,0);
fees_[2] = F3Ddatasets.TeamFee(52,10);
fees_[3] = F3Ddatasets.TeamFee(68,8);



potSplit_[0] = F3Ddatasets.PotSplit(15,10);
potSplit_[1] = F3Ddatasets.PotSplit(25,0);
potSplit_[2] = F3Ddatasets.PotSplit(20,20);
potSplit_[3] = F3Ddatasets.PotSplit(30,10);
}








modifier isActivated() {
require(activated_ == true, "its not ready yet.  check ?eta in discord");
_;
}




modifier isHuman() {
address _addr = msg.sender;
uint256 _codeLength;

assembly {_codeLength := extcodesize(_addr)}
require(_codeLength == 0, "sorry humans only");
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