contract AnythingAppTokenPreSale is Haltable, PriceReceiver {
  using SafeMath for uint;

  string public constant name = "AnythingAppTokenPreSale";

  AnythingAppToken public token;
  InvestorWhiteList public investorWhiteList;
  address public beneficiary;

  uint public tokenPriceUsd;
  uint public totalTokens; 

  uint public ethUsdRate;

  uint public collected = 0;
  uint public withdrawn = 0;
  uint public tokensSold = 0;
  uint public investorCount = 0;
  uint public weiRefunded = 0;

  uint public startTime;
  uint public endTime;

  bool public crowdsaleFinished = false;

  mapping (address => bool) public refunded;
  mapping (address => uint) public deposited;

  uint public constant MINIMAL_PURCHASE = 250 ether;
  uint public constant LIMIT_PER_USER = 500000 ether;

  event NewContribution(address indexed holder, uint tokenAmount, uint etherAmount);
  event NewReferralTransfer(address indexed investor, address indexed referral, uint tokenAmount);
  event Refunded(address indexed holder, uint amount);
  event Deposited(address indexed holder, uint amount);

  modifier preSaleActive() {
    require(block.timestamp >= startTime && block.timestamp < endTime);
    _;
  }

  modifier preSaleEnded() {
    require(block.timestamp >= endTime);
    _;
  }


  function AnythingAppTokenPreSale(
    address _token,
    address _beneficiary,
    address _investorWhiteList,

    uint _totalTokens,
    uint _tokenPriceUsd,

    uint _baseEthUsdPrice,

    uint _startTime,
    uint _endTime
  ) {
    ethUsdRate = _baseEthUsdPrice;
    tokenPriceUsd = _tokenPriceUsd;

    totalTokens = _totalTokens.mul(1 ether);

    token = AnythingAppToken(_token);
    investorWhiteList = InvestorWhiteList(_investorWhiteList);
    beneficiary = _beneficiary;

    startTime = _startTime;
    endTime = _endTime;
  }

  function() payable {
    doPurchase(msg.sender);
  }

  function tokenFallback(address _from, uint _value, bytes _data) public pure { }

  function doPurchase(address _owner) private preSaleActive inNormalState {
    if (token.balanceOf(msg.sender) == 0) investorCount++;

    uint tokens = msg.value.mul(ethUsdRate).div(tokenPriceUsd);
    address referral = investorWhiteList.getReferralOf(msg.sender);
    uint referralBonus = calculateReferralBonus(tokens);

    uint newTokensSold = tokensSold.add(tokens);
    if (referralBonus > 0 && referral != 0x0) {
      newTokensSold = newTokensSold.add(referralBonus);
    }

    require(newTokensSold <= totalTokens);
    require(token.balanceOf(msg.sender).add(tokens) <= LIMIT_PER_USER);

    tokensSold = newTokensSold;

    collected = collected.add(msg.value);
    deposited[msg.sender] = deposited[msg.sender].add(msg.value);

    token.transfer(msg.sender, tokens);
    NewContribution(_owner, tokens, msg.value);

    if (referralBonus > 0 && referral != 0x0) {
      token.transfer(referral, referralBonus);
      NewReferralTransfer(msg.sender, referral, referralBonus);
    }
  }

  function calculateReferralBonus(uint _tokens) internal constant returns (uint _bonus) {
    return _tokens.mul(20).div(100);
  }

  function withdraw() external onlyOwner {
    uint toWithdraw = collected.sub(withdrawn);
    beneficiary.transfer(toWithdraw);
    withdrawn = withdrawn.add(toWithdraw);
  }

  function withdrawTokens() external onlyOwner {
    token.transfer(beneficiary, token.balanceOf(this));
  }

  function receiveEthPrice(uint ethUsdPrice) external onlyEthPriceProvider {
    require(ethUsdPrice > 0);
    ethUsdRate = ethUsdPrice;
  }

  function setEthPriceProvider(address provider) external onlyOwner {
    require(provider != 0x0);
    ethPriceProvider = provider;
  }

  function setNewWhiteList(address newWhiteList) external onlyOwner {
    require(newWhiteList != 0x0);
    investorWhiteList = InvestorWhiteList(newWhiteList);
  }
}