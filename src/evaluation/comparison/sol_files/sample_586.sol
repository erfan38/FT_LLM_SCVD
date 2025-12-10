pragma solidity ^0.8.0;
function __callback(bytes32 myid, string result, bytes proof) public
onlyOraclize
payoutsAreActive
{


if (playerAddress[myid]==0x0) throw;


var sl_result = result.toSlice();
sl_result.beyond("[".toSlice()).until("]".toSlice());
uint serialNumberOfResult = parseInt(sl_result.split(', '.toSlice()).toString());


playerRandomResult[myid] = parseInt(sl_result.beyond("[".toSlice()).until("]".toSlice()).toString());




playerDieResult[myid] = uint(sha3(playerRandomResult[myid], proof)) % 100 + 1;


playerTempAddress[myid] = playerAddress[myid];

delete playerAddress[myid];


playerTempReward[myid] = playerProfit[myid];

playerProfit[myid] = 0;


maxPendingPayouts = safeSub(maxPendingPayouts, playerTempReward[myid]);


playerTempBetValue[myid] = playerBetValue[myid];

playerBetValue[myid] = 0;


totalBets += 1;


totalWeiWagered += playerTempBetValue[myid];






if(playerDieResult[myid] == 0 || bytes(result).length == 0 || bytes(proof).length == 0 || playerRandomResult[myid] == 0){

LogResult(serialNumberOfResult, playerBetId[myid], playerTempAddress[myid], playerNumber[myid], playerDieResult[myid], playerTempBetValue[myid], 3, proof, playerRandomResult[myid]);






if(!playerTempAddress[myid].send(playerTempBetValue[myid])){
LogResult(serialNumberOfResult, playerBetId[myid], playerTempAddress[myid], playerNumber[myid], playerDieResult[myid], playerTempBetValue[myid], 4, proof, playerRandomResult[myid]);

playerPendingWithdrawals[playerTempAddress[myid]] = safeAdd(playerPendingWithdrawals[playerTempAddress[myid]], playerTempBetValue[myid]);
}

return;
}







if(playerDieResult[myid] < playerNumber[myid]){


contractBalance = safeSub(contractBalance, playerTempReward[myid]);


totalWeiWon = safeAdd(totalWeiWon, playerTempReward[myid]);


playerTempReward[myid] = safeAdd(playerTempReward[myid], playerTempBetValue[myid]);

LogResult(serialNumberOfResult, playerBetId[myid], playerTempAddress[myid], playerNumber[myid], playerDieResult[myid], playerTempReward[myid], 1, proof, playerRandomResult[myid]);


setMaxProfit();






if(!playerTempAddress[myid].send(playerTempReward[myid])){
LogResult(serialNumberOfResult, playerBetId[myid], playerTempAddress[myid], playerNumber[myid], playerDieResult[myid], playerTempReward[myid], 2, proof, playerRandomResult[myid]);

playerPendingWithdrawals[playerTempAddress[myid]] = safeAdd(playerPendingWithdrawals[playerTempAddress[myid]], playerTempReward[myid]);
}

return;

}






if(playerDieResult[myid] >= playerNumber[myid]){

LogResult(serialNumberOfResult, playerBetId[myid], playerTempAddress[myid], playerNumber[myid], playerDieResult[myid], playerTempBetValue[myid], 0, proof, playerRandomResult[myid]);






contractBalance = safeAdd(contractBalance, (playerTempBetValue[myid]-1));


setMaxProfit();




if(!playerTempAddress[myid].send(1)){

playerPendingWithdrawals[playerTempAddress[myid]] = safeAdd(playerPendingWithdrawals[playerTempAddress[myid]], 1);
}

return;

}

}