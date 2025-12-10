pragma solidity ^0.8.0;
contract TemplateCrowdsale is Consts, MainCrowdsale

, BonusableCrowdsale


, CappedCrowdsale


, WhitelistedCrowdsale

{
event Initialized();
event TimesChanged(uint startTime, uint endTime, uint oldStartTime, uint oldEndTime);
bool public initialized = false;

function TemplateCrowdsale(MintableToken _token) public
Crowdsale(START_TIME > now ? START_TIME : now, 1543640400, 1200 * TOKEN_DECIMAL_MULTIPLIER, 0x8BcC12F71e4C0C5f73C0dF9afbB3ed1de66DdD79)
CappedCrowdsale(50000000000000000000000)

{
token = _token;
}