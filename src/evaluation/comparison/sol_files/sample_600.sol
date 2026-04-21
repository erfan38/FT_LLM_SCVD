pragma solidity ^0.8.0;
function makeBet(uint256 betPrice, address ref) public payable {
require(now >= betStart && now <= betFinish);

uint256 value = (msg.value / betStep) * betStep;
uint256 extra = msg.value - value;

require(value > 0);
jackpotBalance += extra;

uint8 welcomeFee = bossFee + yjpFee + ntsFee;
uint256 refBonus = 0;
if (ref != 0x0) {
welcomeFee += refFee;
refBonus = value * refFee / 100;

refPayStation.put.value(refBonus)(ref, msg.sender);
emit OnSendRef(ref, refBonus, now, msg.sender, address(refPayStation));
}

uint256 taxedValue = value - value * welcomeFee / 100;
prizeBalance += taxedValue;

bossBalance += value * bossFee / 100;
jackpotBalance += value * yjpFee / 100;
ntsBalance += value * ntsFee / 100;

emit OnBet(msg.sender, ref, block.timestamp, value, betPrice, extra, refBonus, value / betStep);
}