pragma solidity ^0.4.11;





contract TokenStore is SafeMath, Ownable {

  
  address feeAccount;

  
  address accountModifiers;
  
  
  address tradeTracker;

  
  uint public fee;

  
  mapping (address => mapping (address => uint)) public tokens;

  
  mapping (address => mapping (bytes32 => uint)) public orderFills;
  
  
  
  address public successor;
  address public predecessor;
  bool public deprecated;
  uint16 public version;

  
  
  event Cancel(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s);
  event Trade(address tokenGet, uint amountGet, address tokenGive, uint amountGive, address get, address give, uint nonce);
  event Deposit(address token, address user, uint amount, uint balance);
  event Withdraw(address token, address user, uint amount, uint balance);
  event FundsMigrated(address user);

  function TokenStore(uint _fee, address _predecessor) {
    feeAccount = owner;
    fee = _fee;
    predecessor = _predecessor;
    deprecated = false;
    if (predecessor != address(0)) {
      version = TokenStore(predecessor).version() + 1;
    } else {
      version = 1;
    }
  }

  
  function() {
    revert();
  }
  
  modifier deprecable() {
    require(!deprecated);
    _;
  }

  function deprecate(bool _deprecated, address _successor) onlyOwner {
    deprecated = _deprecated;
    successor = _successor;
  }

  function changeFeeAccount(address _feeAccount) onlyOwner {
    require(_feeAccount != address(0));
    feeAccount = _feeAccount;
  }

  function changeAccountModifiers(address _accountModifiers) onlyOwner {
    accountModifiers = _accountModifiers;
  }
  
  function changeTradeTracker(address _tradeTracker) onlyOwner {
    tradeTracker = _tradeTracker;
  }

  
  function changeFee(uint _fee) onlyOwner {
    require(_fee <= fee);
    fee = _fee;
  }
  
  
  function getAccountModifiers() constant returns(uint takeFeeDiscount, uint rebatePercentage) {
    if (accountModifiers != address(0)) {
      return AccountModifiersInterface(accountModifiers).accountModifiers(msg.sender);
    } else {
      return (0, 0);
    }
  }
  
  
  
  

  function deposit() payable deprecable {
    tokens[0][msg.sender] = safeAdd(tokens[0][msg.sender], msg.value);
    Deposit(0, msg.sender, msg.value, tokens[0][msg.sender]);
  }

  function withdraw(uint _amount) {
    require(tokens[0][msg.sender] >= _amount);
    tokens[0][msg.sender] = safeSub(tokens[0][msg.sender], _amount);
    if (!msg.sender.call.value(_amount)()) {
      revert();
    }
    Withdraw(0, msg.sender, _amount, tokens[0][msg.sender]);
  }

  function depositToken(address _token, uint _amount) deprecable {
    
    
    require(_token != 0);
    if (!Token(_token).transferFrom(msg.sender, this, _amount)) {
      revert();
    }
    tokens[_token][msg.sender] = safeAdd(tokens[_token][msg.sender], _amount);
    Deposit(_token, msg.sender, _amount, tokens[_token][msg.sender]);
  }

  function withdrawToken(address _token, uint _amount) {
    require(_token != 0);
    require(tokens[_token][msg.sender] >= _amount);
    tokens[_token][msg.sender] = safeSub(tokens[_token][msg.sender], _amount);
    if (!Token(_token).transfer(msg.sender, _amount)) {
      revert();
    }
    Withdraw(_token, msg.sender, _amount, tokens[_token][msg.sender]);
  }

  function balanceOf(address _token, address _user) constant returns (uint) {
    return tokens[_token][_user];
  }
  
  
  
  

  
  

  function trade(address _tokenGet, uint _amountGet, address _tokenGive, uint _amountGive,
      uint _expires, uint _nonce, address _user, uint8 _v, bytes32 _r, bytes32 _s, uint _amount) {
    bytes32 hash = sha256(this, _tokenGet, _amountGet, _tokenGive, _amountGive, _expires, _nonce);
    
		if (ecrecover(sha3("\x19Ethereum Signed Message:\n32", hash), _v, _r, _s) != _user ||
      block.number > _expires ||
      safeAdd(orderFills[_user][hash], _amount) > _amountGet) {
      revert();
    }
    tradeBalances(_tokenGet, _amountGet, _tokenGive, _amountGive, _user, msg.sender, _amount);
    orderFills[_user][hash] = safeAdd(orderFills[_user][hash], _amount);
    Trade(_tokenGet, _amount, _tokenGive, _amountGive * _amount / _amountGet, _user, msg.sender, _nonce);
  }
  
  function tradeBalances(address _tokenGet, uint _amountGet, address _tokenGive, uint _amountGive,
      address _user, address _caller, uint _amount) private {

    uint feeTakeValue = safeMul(_amount, fee) / (1 ether);
    uint rebateValue = 0;
    uint tokenGiveValue = safeMul(_amountGive, _amount) / _amountGet; 

    
    if (accountModifiers != address(0)) {
      var (feeTakeDiscount, rebatePercentage) = AccountModifiersInterface(accountModifiers).tradeModifiers(_user, _caller);
      
      if (feeTakeDiscount > 100) {
        feeTakeDiscount = 0;
      }
      if (rebatePercentage > 100) {
        rebatePercentage = 0;
      }
      feeTakeValue = safeMul(feeTakeValue, 100 - feeTakeDiscount) / 100;  
      rebateValue = safeMul(rebatePercentage, feeTakeValue) / 100;        
    }
    
    tokens[_tokenGet][_user] = safeAdd(tokens[_tokenGet][_user], safeAdd(_amount, rebateValue));
    tokens[_tokenGet][_caller] = safeSub(tokens[_tokenGet][_caller], safeAdd(_amount, feeTakeValue));
    tokens[_tokenGive][_user] = safeSub(tokens[_tokenGive][_user], tokenGiveValue);
    tokens[_tokenGive][_caller] = safeAdd(tokens[_tokenGive][_caller], tokenGiveValue);
    tokens[_tokenGet][feeAccount] = safeAdd(tokens[_tokenGet][feeAccount], safeSub(feeTakeValue, rebateValue));
    
    if (tradeTracker != address(0)) {
      TradeTrackerInterface(tradeTracker).tradeComplete(_tokenGet, _amount, _tokenGive, tokenGiveValue, _user, _caller, feeTakeValue, rebateValue);
    }
  }

  function testTrade(address _tokenGet, uint _amountGet, address _tokenGive, uint _amountGive, uint _expires,
      uint _nonce, address _user, uint8 _v, bytes32 _r, bytes32 _s, uint _amount, address _sender) constant returns(bool) {
    if (tokens[_tokenGet][_sender] < _amount ||
      availableVolume(_tokenGet, _amountGet, _tokenGive, _amountGive, _expires, _nonce, _user, _v, _r, _s) < _amount) {
      return false;
    }
    return true;
  }

  function availableVolume(address _tokenGet, uint _amountGet, address _tokenGive, uint _amountGive, uint _expires,
      uint _nonce, address _user, uint8 _v, bytes32 _r, bytes32 _s) constant returns(uint) {
    bytes32 hash = sha256(this, _tokenGet, _amountGet, _tokenGive, _amountGive, _expires, _nonce);
    if (ecrecover(sha3("\x19Ethereum Signed Message:\n32", hash), _v, _r, _s) != _user ||
      block.number > _expires) {
      return 0;
    }
    uint available1 = safeSub(_amountGet, orderFills[_user][hash]);
    uint available2 = safeMul(tokens[_tokenGive][_user], _amountGet) / _amountGive;
    if (available1 < available2) return available1;
    return available2;
  }

  function amountFilled(address _tokenGet, uint _amountGet, address _tokenGive, uint _amountGive, uint _expires,
      uint _nonce, address _user) constant returns(uint) {
    bytes32 hash = sha256(this, _tokenGet, _amountGet, _tokenGive, _amountGive, _expires, _nonce);
    return orderFills[_user][hash];
  }

  function cancelOrder(address _tokenGet, uint _amountGet, address _tokenGive, uint _amountGive, uint _expires,
      uint _nonce, uint8 _v, bytes32 _r, bytes32 _s) {
    bytes32 hash = sha256(this, _tokenGet, _amountGet, _tokenGive, _amountGive, _expires, _nonce);
    if (!(ecrecover(sha3("\x19Ethereum Signed Message:\n32", hash), _v, _r, _s) == msg.sender)) {
      revert();
    }
    orderFills[msg.sender][hash] = _amountGet;
    Cancel(_tokenGet, _amountGet, _tokenGive, _amountGive, _expires, _nonce, msg.sender, _v, _r, _s);
  }
  
  
  
  

  
  
  
  function migrateFunds(address[] _tokens) {
  
    
    require(successor != address(0));
    TokenStore newExchange = TokenStore(successor);
    for (uint16 n = 0; n < 20; n++) {  
      address nextSuccessor = newExchange.successor();
      if (nextSuccessor == address(this)) {  
        revert();
      }
      if (nextSuccessor == address(0)) { 
        break;
      }
      newExchange = TokenStore(nextSuccessor);
    }

    
    uint etherAmount = tokens[0][msg.sender];
    if (etherAmount > 0) {
      tokens[0][msg.sender] = 0;
      newExchange.depositForUser.value(etherAmount)(msg.sender);
    }

    
    for (n = 0; n < _tokens.length; n++) {
      address token = _tokens[n];
      require(token != address(0)); 
      uint tokenAmount = tokens[token][msg.sender];
      if (tokenAmount == 0) {
        continue;
      }
      if (!Token(token).approve(newExchange, tokenAmount)) {
        revert();
      }
      tokens[token][msg.sender] = 0;
      newExchange.depositTokenForUser(token, tokenAmount, msg.sender);
    }

    FundsMigrated(msg.sender);
  }

  
  
  
  
  
  function depositForUser(address _user) payable deprecable {
    require(_user != address(0));
    require(msg.value > 0);
    TokenStore caller = TokenStore(msg.sender);
    require(caller.version() > 0); 
    tokens[0][_user] = safeAdd(tokens[0][_user], msg.value);
  }

  function depositTokenForUser(address _token, uint _amount, address _user) deprecable {
    require(_token != address(0));
    require(_user != address(0));
    require(_amount > 0);
    TokenStore caller = TokenStore(msg.sender);
    require(caller.version() > 0); 
    if (!Token(_token).transferFrom(msg.sender, this, _amount)) {
      revert();
    }
    tokens[_token][_user] = safeAdd(tokens[_token][_user], _amount);
  }
}