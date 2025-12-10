contract TokenAuction is SafeMath {

  struct SecretBid {
    bool disqualified;     // flag set if hash does not match encrypted bid
    uint deposit;          // funds deposited by bidder
    uint refund;           // funds to be returned to bidder
    uint tokens;           // structure has been allocated
    bytes32 hash;          // hash of price, quantity, secret
  }
  uint constant  AUCTION_START_EVENT = 0x01;
  uint constant  AUCTION_END_EVENT   = 0x02;
  uint constant  SALE_START_EVENT    = 0x04;
  uint constant  SALE_END_EVENT      = 0x08;

  event SecretBidEvent(uint indexed batch, address indexed bidder, uint deposit, bytes32 hash, bytes message);
  event ExecuteEvent(uint indexed batch, address indexed bidder, uint cost, uint refund);
  event ExpireEvent(uint indexed batch, address indexed bidder, uint cost, uint refund);
  event BizarreEvent(address indexed addr, string message, uint val);
  event BidDisqualifiedEvent(address indexed bidder, bytes32 hash);
  event StateChangeEvent(uint mask);
  //
  //event MessageEvent(string message);
  //event MessageUintEvent(string message, uint val);
  //event MessageAddrEvent(string message, address val);
  //event MessageBytes32Event(string message, bytes32 val);

  bool public isLocked;
  uint public stateMask;
  address public owner;
  address public developers;
  address public underwriter;
  iBurnableToken public token;
  uint public proceeds;
  uint public strikePrice;
  uint public strikePricePctX10;
  uint public decimalMultiplier;
  uint public developerReserve;
  uint public developerPctX10K;
  uint public purchasedCount;
  uint public secretBidCount;
  uint public executedCount;
  uint public expiredCount;
  uint public saleDuration;
  uint public auctionStart;
  uint public auctionEnd;
  uint public saleEnd;
  mapping (address => SecretBid) public secretBids;

  //
  //tunables
  uint batchSize = 4;
  uint contractSendGas = 100000;

  modifier ownerOnly {
    require(msg.sender == owner);
    _;
  }

  modifier unlockedOnly {
    require(!isLocked);
    _;
  }

  modifier duringAuction {
    require((stateMask & (AUCTION_START_EVENT | AUCTION_END_EVENT)) == AUCTION_START_EVENT);
    _;
  }

  modifier afterAuction {
    require((stateMask & AUCTION_END_EVENT) != 0);
    _;
  }

  modifier duringSale {
    require((stateMask & (SALE_START_EVENT | SALE_END_EVENT)) == SALE_START_EVENT);
    _;
  }

  modifier afterSale {
    require((stateMask & SALE_END_EVENT) != 0);
    _;
  }


  //
  //constructor
  //
  function TokenAuction() public {
    owner = msg.sender;
  }

  function lock() public ownerOnly {
    isLocked = true;
  }

  function setToken(iBurnableToken _token, uint _decimalMultiplier, address _underwriter) public ownerOnly unlockedOnly {
    token = _token;
    decimalMultiplier = _decimalMultiplier;
    underwriter = _underwriter;
  }

  function setAuctionParms(uint _auctionStart, uint _auctionDuration, uint _saleDuration) public ownerOnly unlockedOnly {
    auctionStart = _auctionStart;
    auctionEnd = safeAdd(_auctionStart, _auctionDuration);
    saleDuration = _saleDuration;
    if (stateMask != 0) {
      //handy for debug
      stateMask = 0;
      strikePrice = 0;
      executedCount = 0;
      houseKeep();
    }
  }


  function reserveDeveloperTokens(address _developers, uint _developerPctX10K) public ownerOnly unlockedOnly {
    require(developerPctX10K < 1000000);
    developers = _developers;
    developerPctX10K = _developerPctX10K;
    uint _tokenCount = token.balanceOf(this);
    developerReserve = safeMul(_tokenCount, developerPctX10K) / 1000000;
  }

  function tune(uint _batchSize, uint _contractSendGas) public ownerOnly {
    batchSize = _batchSize;
    contractSendGas = _contractSendGas;
  }


  //
  //called by owner (or any other concerned party) to generate a SatateChangeEvent
  //
  function houseKeep() public {
    uint _oldMask = stateMask;
    if (now >= auctionStart) {
      stateMask |= AUCTION_START_EVENT;
      if (now >= auctionEnd) {
        stateMask |= AUCTION_END_EVENT;
        if (strikePrice > 0) {
          stateMask |= SALE_START_EVENT;
          if (now >= saleEnd)
            stateMask |= SALE_END_EVENT;
        }
      }
    }
    if (stateMask != _oldMask)
      StateChangeEvent(stateMask);
  }



  //
  // setting the strike price starts the sale period, during which bidders must call executeBid.
  // the strike price should only be set once.... at any rate it cannot be changed once anyone has executed a bid.
  // strikePricePctX10 specifies what percentage (x10) of requested tokens should be awarded to each bidder that
  // bid exactly equal to the strike price.
  //
  // note: strikePrice is the price of whole tokens (in wei)
  //
  function setStrikePrice(uint _strikePrice, uint _strikePricePctX10) public ownerOnly afterAuction {
    require(executedCount == 0);
    strikePrice = _strikePrice;
    strikePricePctX10 = _strikePricePctX10;
    saleEnd = safeAdd(now, saleDuration);
    houseKeep();
  }


  //
  // nobody should be sending funds via this function.... bizarre...
  // the fact that we adjust proceeds here means that this fcn will OOG if called with a send or transfer. that's
  // probably good, cuz it prevents the caller from losing their funds.
  //
  function () public payable {
    proceeds = safeAdd(proceeds, msg.value);
    BizarreEvent(msg.sender, "bizarre payment", msg.value);
  }


  function depositSecretBid(bytes32 _hash, bytes _message) public duringAuction payable {
    //each address can only submit one bid -- and once a bid is submitted it is imutable
    //for testing, an exception is made for the owner -- but only while the 