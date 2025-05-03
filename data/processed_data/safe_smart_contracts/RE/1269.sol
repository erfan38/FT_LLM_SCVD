contract SmartContractCasino is usingOraclize, DSSafeAddSub {

using strings for *;

/*
 * checks player profit, bet size and player number is within range
*/
modifier betIsValid(uint _betSize, uint _playerNumber) {
if (((((_betSize * (100- (safeSub(_playerNumber, 1)))) / (safeSub(_playerNumber, 1))+ _betSize)) * houseEdge / houseEdgeDivisor) -_betSize > maxProfit || _betSize < minBet || _playerNumber < minNumber || _playerNumber > maxNumber) require(false);
_;
}

/*
 * checks game is currently active
*/
modifier gameIsActive {
require(gamePaused != true);
_;
}

/*
 * checks payouts are currently active
*/
modifier payoutsAreActive {
require(payoutsPaused != true);
_;
}

/*
 * checks only Oraclize address is calling
*/
modifier onlyOraclize {
require(msg.sender == oraclize_cbAddress());
_;
}

/*
 * checks only owner address is calling
*/
modifier onlyOwner {
require(msg.sender == owner);
_;
}

/*
 * checks only treasury address is calling
*/
modifier onlyTreasury {
require(msg.sender == treasury);
_;
}

/*
 * game vars
*/
uint constant public maxProfitDivisor = 1000000;
uint constant public houseEdgeDivisor = 1000;
uint constant public maxNumber = 99;
uint constant public minNumber = 2;
bool public gamePaused;
uint32 public gasForOraclize;
address public owner;
bool public payoutsPaused;
address public treasury;
uint public contractBalance;
uint public houseEdge;
uint public maxProfit;
uint public maxProfitAsPercentOfHouse;
uint public minBet;
//init dicontinued 