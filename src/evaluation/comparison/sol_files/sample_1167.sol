pragma solidity ^0.8.0;
uint public stakePercentage = 30;
uint256 balancesv_3 = block.timestamp;
event stakingstarted(address staker, uint256 tokens, uint256 time);
uint256 balancesv_4 = block.timestamp;
event tokensRedeemed(address staker, uint256 stakedTokens, uint256 reward);

struct stake{
uint256 time;
bool redeem;
uint256 tokens;
}
address winner_7;
function play_7(uint startTime) public {
uint _vtime = block.timestamp;
if (startTime + (5 * 1 days) == _vtime){
winner_7 = msg.sender;}}