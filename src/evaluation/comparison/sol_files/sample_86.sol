pragma solidity ^0.8.0;
contract VreoTokenSale is PostKYCCrowdsale, FinalizableCrowdsale, MintedCrowdsale {


uint public constant TOTAL_TOKEN_CAP_OF_SALE = 450000000e18;


uint public constant TOKEN_SHARE_OF_TEAM     =  85000000e18;
uint public constant TOKEN_SHARE_OF_ADVISORS =  58000000e18;
uint public constant TOKEN_SHARE_OF_LEGALS   =  57000000e18;
uint public constant TOKEN_SHARE_OF_BOUNTY   =  50000000e18;


uint public constant BONUS_PCT_IN_ICONIQ_SALE       = 30;
uint public constant BONUS_PCT_IN_VREO_SALE_PHASE_1 = 20;
uint public constant BONUS_PCT_IN_VREO_SALE_PHASE_2 = 10;


uint public constant ICONIQ_SALE_OPENING_TIME   = 1531123200;
uint public constant ICONIQ_SALE_CLOSING_TIME   = 1532376000;
uint public constant VREO_SALE_OPENING_TIME     = 1533369600;
uint public constant VREO_SALE_PHASE_1_END_TIME = 1533672000;
uint public constant VREO_SALE_PHASE_2_END_TIME = 1534276800;
uint public constant VREO_SALE_CLOSING_TIME     = 1535832000;
uint public constant KYC_VERIFICATION_END_TIME  = 1537041600;


uint public constant ICONIQ_TOKENS_NEEDED_PER_INVESTED_WEI = 450;


ERC20Basic public iconiqToken;


address public teamAddress;
address public advisorsAddress;
address public legalsAddress;
address public bountyAddress;


uint public remainingTokensForSale;



event RateChanged(uint newRate);










constructor(
VreoToken _token,
uint _rate,
ERC20Basic _iconiqToken,
address _teamAddress,
address _advisorsAddress,
address _legalsAddress,
address _bountyAddress,
address _wallet
)
public
Crowdsale(_rate, _wallet, _token)
TimedCrowdsale(ICONIQ_SALE_OPENING_TIME, VREO_SALE_CLOSING_TIME)
{

require(_token.cap() >= TOTAL_TOKEN_CAP_OF_SALE
+ TOKEN_SHARE_OF_TEAM
+ TOKEN_SHARE_OF_ADVISORS
+ TOKEN_SHARE_OF_LEGALS
+ TOKEN_SHARE_OF_BOUNTY);


require(address(_iconiqToken) != address(0)
&& _teamAddress != address(0)
&& _advisorsAddress != address(0)
&& _legalsAddress != address(0)
&& _bountyAddress != address(0));

iconiqToken = _iconiqToken;
teamAddress = _teamAddress;
advisorsAddress = _advisorsAddress;
legalsAddress = _legalsAddress;
bountyAddress = _bountyAddress;

remainingTokensForSale = TOTAL_TOKEN_CAP_OF_SALE;
}




function distributePresale(address[] _investors, uint[] _amounts) public onlyOwner {
require(!hasClosed());
require(_investors.length == _amounts.length);

uint totalAmount = 0;

for (uint i = 0; i < _investors.length; ++i) {
VreoToken(token).mint(_investors[i], _amounts[i]);
totalAmount = totalAmount.add(_amounts[i]);
}

require(remainingTokensForSale >= totalAmount);
remainingTokensForSale = remainingTokensForSale.sub(totalAmount);
}