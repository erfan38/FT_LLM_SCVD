pragma solidity ^0.8.0;
function authorize (address addr, uint cap) public onlyOwner {
require (contractStage == 1);
_checkWhitelistContract(addr);
require (!whitelist[addr].authorized);
require ((cap > 0 && cap < contributionCaps.length) || (cap >= contributionMin && cap <= contributionCaps[0]) );
uint size;
assembly { size := extcodesize(addr) }
require (size == 0);
whitelist[addr].cap = cap;
whitelist[addr].authorized = true;
}