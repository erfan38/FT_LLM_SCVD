pragma solidity ^0.8.0;
}

contract DiceRoll is SafeMath,usingOraclize {

address public owner;
uint8 constant public maxNumber = 99;
uint8 constant public minNumber = 1;

bool public gamePaused = false;
bool public jackpotPaused = false;
bool public refundPaused = false;

uint256 public contractBalance;
uint16 public houseEdge;
uint256 public maxProfit;
uint16 public maxProfitAsPercentOfHouse;
uint256 public minBet;
uint256 public maxBet;
uint16 public jackpotOfHouseEdge;
uint256 public minJackpotBet;

uint256 public jackpotBlance;
address[] public jackpotPlayer;
uint256 public JackpotPeriods = 1;
uint64 public nextJackpotTime;
uint16 public jackpotPersent = 100;

uint256 public totalWeiWon;
uint256 public totalWeiWagered;

mapping (bytes32 => address) playerAddress;
mapping (bytes32 => uint256) playerBetAmount;
mapping (bytes32 => uint8) playerNumberStart;
mapping (bytes32 => uint8) playerNumberEnd;

uint256 public oraclizeGasLimit;
uint public oraclizeFee;
uint seed;

modifier betIsValid(uint256 _betSize, uint8 _start, uint8 _end) {
require(_betSize >= minBet && _betSize <= maxBet && _start >= minNumber && _end <= maxNumber && _start < _end);
_;
}

modifier oddEvenBetIsValid(uint256 _betSize, uint8 _oddeven) {
require(_betSize >= minBet && _betSize <= maxBet && (_oddeven == 1 || _oddeven == 0));
_;
}

modifier gameIsActive {
require(!gamePaused);
_;
}


modifier jackpotAreActive {
require(!jackpotPaused);
_;
}

modifier onlyOwner {
require(msg.sender == owner);
_;
}

modifier onlyOraclize {
require(msg.sender == oraclize_cbAddress());
_;
}

event LogResult(bytes32 indexed QueryId, address indexed Address, uint8 DiceResult, uint256 Value, uint8 Status, uint8 Start, uint8 End, uint8 OddEven, uint256 BetValue);
event LogRefund(bytes32 indexed QueryId, uint256 Amount);
event LogJackpot(bytes32 indexed QueryId, address indexed Address, uint256 jackpotValue);
event LogOwnerTransfer(address SentToAddress, uint256 AmountTransferred);
event SendJackpotSuccesss(address indexed winner, uint256 amount, uint256 JackpotPeriods);


function() public payable{
contractBalance = safeAdd(contractBalance, msg.value);
setMaxProfit();
}

function DiceRoll() public {
owner = msg.sender;
houseEdge = 20;
maxProfitAsPercentOfHouse = 100;
minBet = 0.1 ether;
maxBet = 1 ether;
jackpotOfHouseEdge = 500;
minJackpotBet = 0.1 ether;
jackpotPersent = 100;
oraclizeGasLimit = 300000;
oraclizeFee = 1200000000000000;
oraclize_setCustomGasPrice(4000000000);
nextJackpotTime = uint64(block.timestamp);
oraclize_setProof(proofType_Ledger);

}