pragma solidity ^0.8.0;
function setEndTime(uint _endTime) public onlyOwner {

require(now < endTime);

require(now < _endTime);
require(_endTime > startTime);
emit TimesChanged(startTime, _endTime, startTime, endTime);
endTime = _endTime;
}




}