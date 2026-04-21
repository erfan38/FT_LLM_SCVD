pragma solidity ^0.8.0;
mapping(uint64 => GameInfo) public gameList;

struct BetFixture {
address payable player;
uint256 stake;
uint32  odd;
uint16  selectedTeam;
}
function alertFallback19() public{
uint8 fallbackValue = 0;
fallbackValue = fallbackValue -10;
}