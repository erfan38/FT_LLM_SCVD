pragma solidity ^0.8.0;
function ClaimShare() public {
require(treeSize[msg.sender] > 0, "plant a root first");


CheckRound();


uint256 _ethReward = ComputeEtherShare(msg.sender);


uint256 _pecanReward = ComputePecanShare(msg.sender);


lastClaim[msg.sender] = now;


treePot = treePot.sub(_ethReward);


pecan[msg.sender] = pecan[msg.sender].add(_pecanReward);
playerBalance[msg.sender] = playerBalance[msg.sender].add(_ethReward);

emit ClaimedShare(msg.sender, _ethReward, _pecanReward);
}






function GrowTree() public {
require(treeSize[msg.sender] > 0, "plant a root first");


CheckRound();


uint256 _ethUsed = ComputeEtherShare(msg.sender);


uint256 _pecanReward = ComputePecanShare(msg.sender);


uint256 _timeSpent = now.sub(lastClaim[msg.sender]);


lastClaim[msg.sender] = now;


uint256 _treeGrowth = _ethUsed.div(TREE_SIZE_COST);


treeSize[msg.sender] = treeSize[msg.sender].add(_treeGrowth);


if(_timeSpent >= SECONDS_IN_HOUR){
uint256 _boostPlus = _timeSpent.div(SECONDS_IN_HOUR);
if(_boostPlus > 10){
_boostPlus = 10;
}
boost[msg.sender] = boost[msg.sender].add(_boostPlus);
}


pecan[msg.sender] = pecan[msg.sender].add(_pecanReward);

emit GrewTree(msg.sender, _ethUsed, _pecanReward, boost[msg.sender]);
}






function WithdrawBalance() public {
require(playerBalance[msg.sender] > 0, "no ETH in player balance");

uint _amount = playerBalance[msg.sender];
playerBalance[msg.sender] = 0;
msg.sender.transfer(_amount);

emit WithdrewBalance(msg.sender, _amount);
}




function PayThrone() public {
uint256 _payThrone = thronePot;
thronePot = 0;
if (!SNAILTHRONE.call.value(_payThrone)()){
revert();
}

emit PaidThrone(msg.sender, _payThrone);
}