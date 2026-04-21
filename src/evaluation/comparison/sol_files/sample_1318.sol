pragma solidity ^0.8.0;
function playerRollDice() public
payable
gameIsActive
betIsValid(msg.value, underNumber)
{
totalBets += 1;

uint randReuslt = GetRandomNumber();







if(randReuslt < underNumber){

uint playerProfit = ((((msg.value * (maxNumber-(safeSub(underNumber,1)))) / (safeSub(underNumber,1))+msg.value))*houseEdge/houseEdgeDivisor)-msg.value;


contractBalance = safeSub(contractBalance, playerProfit);


uint reward = safeAdd(playerProfit, msg.value);

totalUserProfit = totalUserProfit + playerProfit;

LogResult(totalBets, msg.sender, underNumber, randReuslt, reward, 1, msg.value,underNumber);


setMaxProfit();






if(!msg.sender.send(reward)){
LogResult(totalBets, msg.sender, underNumber, randReuslt, reward, 2, msg.value,underNumber);


playerPendingWithdrawals[msg.sender] = safeAdd(playerPendingWithdrawals[msg.sender], reward);
}

return;
}






if(randReuslt >= underNumber){

LogResult(totalBets, msg.sender, underNumber, randReuslt, msg.value, 0, msg.value,underNumber);






contractBalance = safeAdd(contractBalance, msg.value-1);


setMaxProfit();




if(!msg.sender.send(1)){

playerPendingWithdrawals[msg.sender] = safeAdd(playerPendingWithdrawals[msg.sender], 1);
}

return;

}
}