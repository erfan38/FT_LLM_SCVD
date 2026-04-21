pragma solidity ^0.8.0;
function PlantRoot() public payable {
require(tx.origin == msg.sender, "no contracts allowed");
require(msg.value >= 0.001 ether, "at least 1 finney to plant a root");


CheckRound();


PotSplit(msg.value);


pecanToWin = ComputePecanToWin();


uint256 _newPecan = ComputePlantPecan(msg.value);


lastRootPlant = now;
lastClaim[msg.sender] = now;


uint256 _treePlant = msg.value.div(TREE_SIZE_COST);


treeSize[msg.sender] = treeSize[msg.sender].add(_treePlant);


pecan[msg.sender] = pecan[msg.sender].add(_newPecan);

emit PlantedRoot(msg.sender, msg.value, _newPecan, treeSize[msg.sender]);
}