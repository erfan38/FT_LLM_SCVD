pragma solidity ^0.8.0;
contract GambioCrowdsale is CappedCrowdsale, OnlyWhiteListedAddresses {
using SafeMath for uint256;

struct TokenPurchaseRecord {
uint256 timestamp;
uint256 weiAmount;
address beneficiary;
}

uint256 transactionId = 1;

mapping(uint256 => TokenPurchaseRecord) pendingTransactions;

mapping(uint256 => bool) completedTransactions;

uint256 public referralPercentage;

uint256 public individualCap;


event TokenPurchaseRequest(
uint256 indexed transactionId,
address beneficiary,
uint256 indexed timestamp,
uint256 indexed weiAmount,
uint256 tokensAmount
);

event ReferralTokensSent(
address indexed beneficiary,
uint256 indexed tokensAmount,
uint256 indexed transactionId
);

event BonusTokensSent(
address indexed beneficiary,
uint256 indexed tokensAmount,
uint256 indexed transactionId
);

constructor(
uint256 _startTime,
uint256 _endTime,
uint256 _icoHardCapWei,
uint256 _referralPercentage,
uint256 _rate,
address _wallet,
uint256 _privateWeiRaised,
uint256 _individualCap,
address _utilityAccount,
uint256 _tokenCap,
uint256[] _vestingData
)
public
OnlyWhiteListedAddresses(_utilityAccount)
CappedCrowdsale(_icoHardCapWei, _vestingData, _wallet)
Crowdsale(_startTime, _endTime, _rate, _wallet, _privateWeiRaised, _tokenCap)
{
referralPercentage = _referralPercentage;
individualCap = _individualCap;
}


function() external payable {
buyTokens(msg.sender);
}


function buyTokens(address beneficiary) public payable {
require(!isFinalized);
require(beneficiary == msg.sender);
require(msg.value != 0);
require(msg.value >= individualCap);

uint256 weiAmount = msg.value;
require(isWhiteListedAddress(beneficiary));
require(validPurchase(weiAmount));


weiRaised = weiRaised.add(weiAmount);

uint256 _transactionId = transactionId;
uint256 tokensAmount = weiAmount.mul(rate);

pendingTransactions[_transactionId] = TokenPurchaseRecord(now, weiAmount, beneficiary);
transactionId += 1;


emit TokenPurchaseRequest(_transactionId, beneficiary, now, weiAmount, tokensAmount);
forwardFunds();
}