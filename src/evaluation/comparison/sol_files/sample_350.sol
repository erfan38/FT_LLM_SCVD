pragma solidity ^0.8.0;
mapping (address => uint256) balances;
mapping (address => mapping (address => uint256)) allowed;
}



contract MoldCoin is StandardToken, SafeMath {

string public name = "MOLD";
string public symbol = "MLD";
uint public decimals = 18;

uint public startDatetime;
uint public firstStageDatetime;
uint public secondStageDatetime;
uint public endDatetime;



address public founder;


address public admin;

uint public coinAllocation = 20 * 10**8 * 10**decimals;
uint public angelAllocation = 2 * 10**8 * 10**decimals;
uint public founderAllocation = 3 * 10**8 * 10**decimals;

bool public founderAllocated = false;

uint public saleTokenSupply = 0;
uint public salesVolume = 0;

uint public angelTokenSupply = 0;

bool public halted = false;

event Buy(address indexed sender, uint eth, uint tokens);
event AllocateFounderTokens(address indexed sender, uint tokens);
event AllocateAngelTokens(address indexed sender, address to, uint tokens);
event AllocateUnsoldTokens(address indexed sender, address holder, uint tokens);

modifier onlyAdmin {
require(msg.sender == admin);
_;
}

modifier duringCrowdSale {
require(block.timestamp >= startDatetime && block.timestamp <= endDatetime);
_;
}


function MoldCoin(uint startDatetimeInSeconds, address founderWallet) {

admin = msg.sender;
founder = founderWallet;
startDatetime = startDatetimeInSeconds;
firstStageDatetime = startDatetime + 120 * 1 hours;
secondStageDatetime = firstStageDatetime + 240 * 1 hours;
endDatetime = secondStageDatetime + 2040 * 1 hours;

}