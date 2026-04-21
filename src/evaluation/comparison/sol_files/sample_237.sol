pragma solidity ^0.4.24;


























































contract H3FoMo3Dlong is modularLong {
using SafeMath for *;
using NameFilter for string;
using F3DKeysCalcLong for uint256;

otherFoMo3D private otherF3D_;
DiviesInterface constant private Divies = DiviesInterface(0x88ac6e1f2ffc98fda7ca2a4236178b8be66b79f4);
JIincForwarderInterface constant private Jekyll_Island_Inc = JIincForwarderInterface(0x6f6a4c6bc3b646be9c33566fe40cdc20c34ee104);
PlayerBookInterface constant private PlayerBook = PlayerBookInterface(0xa988d0b985188818906d206ba0cf98ca0a7433bb);




string constant public name = "FoMo3D Long Official";
string constant public symbol = "F3D";
uint256 private rndExtra_ = 15 minutes;
uint256 private rndGap_ = 15 minutes;
uint256 constant private rndInit_ = 1 hours;
uint256 constant private rndInc_ = 30 seconds;
uint256 constant private rndMax_ = 24 hours;




uint256 public airDropPot_;
uint256 public airDropTracker_ = 0;
uint256 public rID_;



mapping(address => uint256) public pIDxAddr_;
mapping(bytes32 => uint256) public pIDxName_;
mapping(uint256 => F3Ddatasets.Player) public plyr_;
mapping(uint256 => mapping(uint256 => F3Ddatasets.PlayerRounds)) public plyrRnds_;
mapping(uint256 => mapping(bytes32 => bool)) public plyrNames_;



mapping(uint256 => F3Ddatasets.Round) public round_;
mapping(uint256 => mapping(uint256 => uint256)) public rndTmEth_;



mapping(uint256 => F3Ddatasets.TeamFee) public fees_;
mapping(uint256 => F3Ddatasets.PotSplit) public potSplit_;




constructor() public {









fees_[0] = F3Ddatasets.TeamFee(30, 6);
fees_[1] = F3Ddatasets.TeamFee(43, 0);
fees_[2] = F3Ddatasets.TeamFee(56, 10);
fees_[3] = F3Ddatasets.TeamFee(43, 8);



potSplit_[0] = F3Ddatasets.PotSplit(15, 10);
potSplit_[1] = F3Ddatasets.PotSplit(25, 0);
potSplit_[2] = F3Ddatasets.PotSplit(20, 20);
potSplit_[3] = F3Ddatasets.PotSplit(30, 10);
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








function() isActivated() isHuman() isWithinLimits(msg.value) public payable
{

F3Ddatasets.EventReturns memory _eventData_ = determinePID(_eventData_);


uint256 _pID = pIDxAddr_[msg.sender];


buyCore(_pID, plyr_[_pID].laff, 2, _eventData_);
}









function buyXid(uint256 _affCode, uint256 _team) isActivated() isHuman() isWithinLimits(msg.value) public payable {

F3Ddatasets.EventReturns memory _eventData_ = determinePID(_eventData_);


uint256 _pID = pIDxAddr_[msg.sender];



if (_affCode == 0 || _affCode == _pID) {

_affCode = plyr_[_pID].laff;


} else if (_affCode != plyr_[_pID].laff) {

plyr_[_pID].laff = _affCode;
}


_team = verifyTeam(_team);


buyCore(_pID, _affCode, _team, _eventData_);
}