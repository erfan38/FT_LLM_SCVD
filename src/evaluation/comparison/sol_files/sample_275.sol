pragma solidity ^0.8.0;
function setRate(uint _newRate) public onlyOwner {


require(rate / 10 < _newRate && _newRate < 10 * rate);

rate = _newRate;

emit RateChanged(_newRate);
}