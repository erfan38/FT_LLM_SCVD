pragma solidity ^0.8.0;
function quickTrade(address tokenFrom, address tokenTo, uint256 input) payable drainBlock {

uint256 inValue;
uint256 tempInValue = safeAdd(tokenToValue(etherContract,msg.value),
tokenToValue(tokenFrom,input));
inValue = valueWithFee(tempInValue);
uint256 outValue = valueToToken(tokenTo,inValue);
assert(verifiedTransferFrom(tokenFrom,msg.sender,input));
if (tokenTo == etherContract){
assert(msg.sender.call.value(outValue)());
} else assert(Token(tokenTo).transfer(msg.sender, outValue));
Trade(tokenFrom, tokenTo, msg.sender, inValue);
}