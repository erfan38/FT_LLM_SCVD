pragma solidity ^0.8.0;
contract AgeVerifier {
function isAdult(uint _birthYear, uint _currentYear) public pure returns (bool) {
uint age = _currentYear - _birthYear;
return age >= 18;
}
}