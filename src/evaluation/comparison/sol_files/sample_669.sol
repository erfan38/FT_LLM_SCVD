pragma solidity ^0.8.0;
function tradeBalances(address tokenGet, uint amountGet, address tokenGive, uint amountGive, address user, uint amount) internal {

uint tradingFeeXfer = calculatePercentage(amount,tradingFee);
tokens[tokenGet][msg.sender] = tokens[tokenGet][msg.sender].sub(amount.add(tradingFeeXfer));
tokens[tokenGet][user] = tokens[tokenGet][user].add(amount.sub(tradingFeeXfer));
tokens[address(0)][feeAccount] = tokens[address(0)][feeAccount].add(tradingFeeXfer);

tokens[tokenGive][user] = tokens[tokenGive][user].sub(amountGive.mul(amount) / amountGet);
tokens[tokenGive][msg.sender] = tokens[tokenGive][msg.sender].add(amountGive.mul(amount) / amountGet);
}