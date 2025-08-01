contract Crowdsale {
  using SafeMath for uint256;
  // The token being sold
//  MintableToken public token;
  address public tokenAddr;
  TestTokenA public testTokenA;
  // start and end timestamps where investments are allowed (both inclusive)
  uint256 public startTime;
  uint256 public endTime;
  // address where funds are collected
  address public wallet;
  // how many token units a buyer gets per wei
  uint256 public rate;
  // amount of raised money in wei
  uint256 public weiRaised;
  /**
   * event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
  function Crowdsale(address _tokenAddress, uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet) {
    require(_startTime >= now);
    require(_endTime >= _startTime);
    require(_rate > 0);
    require(_wallet != 0x0);
    require(_tokenAddress != 0x0);
//    createTokenContract(_tokenAddress);
//    createTokenContract();
    tokenAddr = _tokenAddress;
    startTime = _startTime;
    endTime = _endTime;
    rate = _rate;
    wallet = _wallet;
  }
  // creates the token to be sold.
  // override this method to have crowdsale of a specific mintable token.
//  function createTokenContract() internal returns (MintableToken) {
//      return new TestTokenA();
////    return MintableToken(_tokenAddress);
//  }
  // fallback function can be used to buy tokens
  function () payable {
    buyTokens(msg.sender);
  }
  // low level token purchase function
  function buyTokens(address beneficiary) public payable {
    require(beneficiary != 0x0);
    require(validPurchase());
    uint256 weiAmount = msg.value;
    // calculate token amount to be created
    uint256 tokens = weiAmount.mul(rate);
    // update state
    weiRaised = weiRaised.add(weiAmount);
//    token.mint(beneficiary, tokens);
//    bytes4 methodId = bytes4(keccak256("mint(address,uint256)"));
//    tokenAddr.call(methodId, beneficiary, tokens);
    testTokenA = TestTokenA(tokenAddr);
    testTokenA.mint(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
    forwardFunds();
  }
  // send ether to the fund collection wallet
  // override to create custom fund forwarding mechanisms
  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }
  // @return true if the transaction can buy tokens
  function validPurchase() internal constant returns (bool) {
    bool withinPeriod = now >= startTime && now <= endTime;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }
  // @return true if crowdsale event has ended
  function hasEnded() public constant returns (bool) {
    return now > endTime;
  }
}
/**
 * @title CappedCrowdsale
 * @dev Extension of Crowdsale with a max amount of funds raised
 */
