pragma solidity ^0.8.0;
}



contract Auctions is Pricer, Owned {

using SafeMath for uint256;
METToken public token;
Proceeds public proceeds;
address[] public founders;
mapping(address => TokenLocker) public tokenLockers;
uint internal constant DAY_IN_SECONDS = 86400;
uint internal constant DAY_IN_MINUTES = 1440;
uint public genesisTime;
uint public lastPurchaseTick;
uint public lastPurchasePrice;
uint public constant INITIAL_GLOBAL_DAILY_SUPPLY = 2880 * METDECMULT;
uint public INITIAL_FOUNDER_SUPPLY = 1999999 * METDECMULT;
uint public INITIAL_AC_SUPPLY = 1 * METDECMULT;
uint public totalMigratedOut = 0;
uint public totalMigratedIn = 0;
uint public timeScale = 1;
uint public constant INITIAL_SUPPLY = 10000000 * METDECMULT;
uint public mintable = INITIAL_SUPPLY;
uint public initialAuctionDuration = 7 days;
uint public initialAuctionEndTime;
uint public dailyAuctionStartTime;
uint public constant DAILY_PURCHASE_LIMIT = 1000 ether;
mapping (address => uint) internal purchaseInTheAuction;
mapping (address => uint) internal lastPurchaseAuction;
bool public minted;
bool public initialized;
uint public globalSupplyAfterPercentageLogic = 52598080 * METDECMULT;
uint public constant AUCTION_WHEN_PERCENTAGE_LOGIC_STARTS = 14791;
bytes8 public chain = "ETH";
event LogAuctionFundsIn(address indexed sender, uint amount, uint tokens, uint purchasePrice, uint refund);

function Auctions() public {
mintable = INITIAL_SUPPLY - 2000000 * METDECMULT;
}