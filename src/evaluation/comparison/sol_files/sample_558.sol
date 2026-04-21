pragma solidity ^0.8.0;
function endRound(FFEIFDatasets.EventReturns memory _eventData_)
private
returns (FFEIFDatasets.EventReturns)
{

uint256 _rID = rID_;


uint256 _winPID = round_[_rID].plyr;
uint256 _winTID = round_[_rID].team;


uint256 _pot = round_[_rID].pot;



uint256 _win = _pot.mul(winnerPercentage) / 100;
uint256 _gen = _pot.mul(potSplit_[_winTID].gen) / 100;
uint256 _PoEIF = _pot.mul(potSplit_[_winTID].poeif) / 100;
uint256 _res = _pot.sub(_win).sub(_gen).sub(_PoEIF);



uint256 _ppt = _gen.mul(1000000000000000000) / round_[_rID].keys;
uint256 _dust = _gen.sub((_ppt.mul(round_[_rID].keys)) / 1000000000000000000);
if (_dust > 0)
{
_gen = _gen.sub(_dust);
_res = _res.add(_dust);
}


plyr_[_winPID].win = _win.add(plyr_[_winPID].win);






address(PoEIFContract).call.value(_PoEIF.sub((_PoEIF / 2)))(bytes4(keccak256("donateDivs()")));
fundEIF = fundEIF.add(_PoEIF / 2);


round_[_rID].mask = _ppt.add(round_[_rID].mask);

uint256 _actualPot = _res;

if (seedRoundEnd==1) {

_actualPot = _res.sub(_res/seedingDivisor);

if (seedingThreshold > rndTmEth_[_rID][0]) {seedingPot = seedingPot.add(_res); _actualPot = 0;} else seedingPot = seedingPot.add(_res/seedingDivisor);
}


_eventData_.compressedData = _eventData_.compressedData + (round_[_rID].end * 1000000);
_eventData_.compressedIDs = _eventData_.compressedIDs + (_winPID * 100000000000000000000000000) + (_winTID * 100000000000000000);
_eventData_.winnerAddr = plyr_[_winPID].addr;
_eventData_.winnerName = plyr_[_winPID].name;
_eventData_.amountWon = _win;
_eventData_.genAmount = _gen;
_eventData_.tokenAmount = _PoEIF;
_eventData_.newPot = _actualPot;
_eventData_.seedAdd = _res - _actualPot;



setStore("endround",0);
rID_++;
_rID++;
round_[_rID].strt = now;
round_[_rID].end = now.add(rndInit_).add(rndGap_);
round_[_rID].pot += _actualPot;

return(_eventData_);
}