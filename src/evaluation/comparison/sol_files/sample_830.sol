pragma solidity ^0.8.0;
contract Fundraiser {
function calculateMatchingFunds(uint _donation, uint _matchingRate) public pure returns (uint) {
uint matchingFunds = _donation * _matchingRate / 100;
return matchingFunds;
}
}