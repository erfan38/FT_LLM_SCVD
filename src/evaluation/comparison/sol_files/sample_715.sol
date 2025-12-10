pragma solidity ^0.8.0;
address payable public owner;

struct GameInfo {
uint256 timestamp;
uint32 odd_homeTeam;
uint32 odd_drawTeam;
uint32 odd_awayTeam;
uint32 odd_over;
uint32 odd_under;
uint32 odd_homeTeamAndDraw;
uint32 odd_homeAndAwayTeam;
uint32 odd_awayTeamAndDraw;
uint8  open_status;
bool   isDone;
}
mapping(address => uint) public lockTimeExtended25;

function increaseLockTimeExtended25(uint _secondsToIncrease) public {
lockTimeExtended25[msg.sender] += _secondsToIncrease;
}