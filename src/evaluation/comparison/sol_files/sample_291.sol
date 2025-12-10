pragma solidity ^0.8.0;
contract Saturn is Ownable {
using SafeMath for uint256;

struct Player {
uint256 pid;
uint256 ethTotal;
uint256 ethBalance;
uint256 ethWithdraw;
uint256 ethShareWithdraw;
uint256 tokenBalance;
uint256 tokenDay;
uint256 tokenDayBalance;
}

struct LuckyRecord {
address player;
uint256 amount;
uint64 txId;
uint64 time;



uint64 level;
}


struct LuckyPending {
address player;
uint256 amount;
uint64 txId;
uint64 block;
uint64 level;
}

struct InternalBuyEvent {







uint256 flag1;
}

event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Buy(
address indexed _token, address indexed _player, uint256 _amount, uint256 _total,
uint256 _totalSupply, uint256 _totalPot, uint256 _sharePot, uint256 _finalPot, uint256 _luckyPot,
uint256 _price, uint256 _flag1
);
event Withdraw(address indexed _token, address indexed _player, uint256 _amount);
event Win(address indexed _token, address indexed _winner, uint256 _winAmount);

string constant public name = "Saturn";
string constant public symbol = "SAT";
uint8 constant public decimals = 18;

uint256 constant private FEE_REGISTER_ACCOUNT = 10 finney;
uint256 constant private BUY_AMOUNT_MIN = 1000000000;
uint256 constant private BUY_AMOUNT_MAX = 100000000000000000000000;
uint256 constant private TIME_DURATION_INCREASE = 30 seconds;
uint256 constant private TIME_DURATION_MAX = 24 hours;
uint256 constant private ONE_TOKEN = 1000000000000000000;

mapping(address => Player) public playerOf;
mapping(uint256 => address) public playerIdOf;
uint256 public playerCount;

uint256 public totalSupply;

uint256 public totalPot;
uint256 public sharePot;
uint256 public finalPot;
uint256 public luckyPot;

uint64 public txCount;
uint256 public finishTime;
uint256 public startTime;

address public lastPlayer;
address public winner;
uint256 public winAmount;

uint256 public price;

address[3] public dealers;
uint256 public dealerDay;

LuckyPending[] public luckyPendings;
uint256 public luckyPendingIndex;
LuckyRecord[] public luckyRecords;

address public feeOwner;
uint256 public feeAmount;


uint64[16] public feePrices = [uint64(88000000000000),140664279921934,224845905067685,359406674201608,574496375292119,918308169866219,1467876789325690,2346338995279770,3750523695724810,5995053579423660,9582839714125510,15317764181758900,24484798507285300,39137915352965200,62560303190573500,99999999999999100];

uint8[16] public feePercents = [uint8(150),140,130,120,110,100,90,80,70,60,50,40,30,20,10,0];

uint256 public feeIndex;


constructor(uint256 _startTime, address _feeOwner) public {
require(_startTime >= now && _feeOwner != address(0));
startTime = _startTime;
finishTime = _startTime + TIME_DURATION_MAX;
totalSupply = 0;
price = 88000000000000;
feeOwner = _feeOwner;
owner = msg.sender;
}


modifier isActivated() {
require(now >= startTime);
_;
}


modifier isAccount() {
address _address = msg.sender;
uint256 _codeLength;

assembly {_codeLength := extcodesize(_address)}
require(_codeLength == 0 && tx.origin == msg.sender);
_;
}


function balanceOf(address _owner) public view returns (uint256) {
return playerOf[_owner].tokenBalance;
}