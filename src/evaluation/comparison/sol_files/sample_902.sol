pragma solidity ^0.8.0;
function removeAdmin()
public
{
require(msg.sender == admin, "Only admin can remove himself");
admin =  address(0);
}


}





library FFEIFDatasets {

struct EventReturns {
uint256 compressedData;
uint256 compressedIDs;
address winnerAddr;
bytes32 winnerName;
uint256 amountWon;
uint256 newPot;
uint256 tokenAmount;
uint256 genAmount;
uint256 potAmount;
uint256 seedAdd;

}
struct Player {
address addr;
bytes32 name;
uint256 win;
uint256 gen;
uint256 aff;
uint256 lrnd;
uint256 laff;
}
struct PlayerRounds {
uint256 eth;
uint256 keys;
uint256 mask;
uint256 ico;
}
struct Round {
uint256 plyr;
uint256 team;
uint256 end;
bool ended;
uint256 strt;
uint256 keys;
uint256 eth;
uint256 pot;
uint256 mask;
uint256 ico;
uint256 icoGen;
uint256 icoAvg;
}
struct TeamFee {
uint256 gen;
uint256 poeif;
}
struct PotSplit {
uint256 gen;
uint256 poeif;
}
}