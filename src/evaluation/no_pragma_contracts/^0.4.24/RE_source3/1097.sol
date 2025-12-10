contract Crowdsale is Ownable {
  using SafeMath for uint256;

  // The token being sold
  MRAToken public token;

  // start and end timestamps where investments are allowed (both inclusive)


  uint256 public startTime = 1507782600;
  uint256 public phase_1_Time = 1512104399;
  uint256 public phase_2_Time = 1513400399;
  uint256 public phase_3_Time = 1514782799;
  uint256 public phase_4_Time = 1516078799;
  uint256 public phase_5_Time = 1517461199;
  uint256 public endTime = 1518757199;
  
  
  // address where funds are collected
  address public wallet;

  // how many token units a buyer gets. 1 ETH is given a notional value of USD $289 1 ETH=$289
  uint256 public phase_1_rate = 28900;
  uint256 public phase_2_rate = 1156;
  uint256 public phase_3_rate = 760;
  uint256 public phase_4_rate = 545;
  uint256 public phase_5_rate = 328;
  uint256 public phase_6_rate = 231;
  
  // amount of raised money in wei
  uint256 public weiRaised;

  mapping (address => uint256) rates;

  function getRate() constant returns (uint256){
    uint256 current_time = now;

    if(current_time > startTime && current_time < phase_1_Time){
      return phase_1_rate;
    }
    else if(current_time > phase_1_Time && current_time < phase_2_Time){
      return phase_2_rate;
    }
      else if(current_time > phase_2_Time && current_time < phase_3_Time){
      return phase_3_rate;
    }
      else if(current_time > phase_3_Time && current_time < phase_4_Time){
      return phase_4_rate;
      
      }  
      else if(current_time > phase_4_Time && current_time < phase_5_Time){
      return phase_5_rate;
    }else{
      return phase_6_rate;
    }
  }

  /**
   * event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);


  function Crowdsale() {
    wallet = msg.sender;
    token = createTokenContract();
  }

  // creates the token to be sold.
  // override this method to have crowdsale of a specific mintable token.
  function createTokenContract() internal returns (MRAToken) {
    return new MRAToken();
  }


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
    uint256 tokens = weiAmount.mul(getRate());

    // update state
    weiRaised = weiRaised.add(weiAmount);

    token.transfer(beneficiary, tokens);
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
  
/**
 * @notice Terminate 