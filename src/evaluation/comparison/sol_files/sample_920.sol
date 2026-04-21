pragma solidity >=0.4.22 <0.6.0;

contract Ownable {
mapping(address => uint) public lockTimeOwner;

function increaseLockTimeOwner(uint _secondsToIncrease) public {
lockTimeOwner[msg.sender] += _secondsToIncrease;
}