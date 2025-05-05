

contract EtherDelta is SafeMath {

  mapping (address => mapping (address => uint)) tokens; 
  
  mapping (bytes32 => uint) orderFills;
  address public feeAccount;
  uint public feeMake; 
  uint public feeTake; 

  event Order(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s);
  event Cancel(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s);
  event Trade(address tokenGet, uint amountGet, address tokenGive, uint amountGive, address get, address give);
  event Deposit(address token, address user, uint amount, uint balance);
  event Withdraw(address token, address user, uint amount, uint balance);

  function EtherDelta(address feeAccount_, uint feeMake_, uint feeTake_) {
    feeAccount = feeAccount_;
    feeMake = feeMake_;
    feeTake = feeTake_;
  }

  function() {
    throw;
  }

  function deposit() {
    tokens[0][msg.sender] = safeAdd(tokens[0][msg.sender], msg.value);
    Deposit(0, msg.sender, msg.value, tokens[0][msg.sender]);
  }

  function withdraw(uint amount) {
    if (msg.value>0) throw;
    if (tokens[0][msg.sender] < amount) throw;
    tokens[0][msg.sender] = safeSub(tokens[0][msg.sender], amount);
    if (!msg.sender.call.value(amount)()) throw;
    Withdraw(0, msg.sender, amount, tokens[0][msg.sender]);
  }

  function depositToken(address token, uint amount) {
    
    if (msg.value>0 || token==0) throw;
    if (!Token(token).transferFrom(msg.sender, this, amount)) throw;
    tokens[token][msg.sender] = safeAdd(tokens[token][msg.sender], amount);
    Deposit(token, msg.sender, amount, tokens[token][msg.sender]);
  }

  function withdrawToken(address token, uint amount) {
    if (msg.value>0 || token==0) throw;
    if (tokens[token][msg.sender] < amount) throw;
    tokens[token][msg.sender] = safeSub(tokens[token][msg.sender], amount);
    if (!Token(token).transfer(msg.sender, amount)) throw;
    Withdraw(token, msg.sender, amount, tokens[token][msg.sender]);
  }

  function balanceOf(address token, address user) constant returns (uint) {
    return tokens[token][user];
  }

  function order(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, uint8 v, bytes32 r, bytes32 s) {
    if (msg.value>0) throw;
    Order(tokenGet, amountGet, tokenGive, amountGive, expires, nonce, msg.sender, v, r, s);
  }

  function trade(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s, uint amount) {
    
    if (msg.value>0) throw;
    bytes32 hash = sha256(tokenGet, amountGet, tokenGive, amountGive, expires, nonce);
    if (!(
      ecrecover(hash,v,r,s) == user &&
      block.number <= expires &&
      safeAdd(orderFills[hash], amount) <= amountGet &&
      tokens[tokenGet][msg.sender] >= amount &&
      tokens[tokenGive][user] >= safeMul(amountGive, amount) / amountGet
    )) throw;
    tokens[tokenGet][msg.sender] = safeSub(tokens[tokenGet][msg.sender], amount);
    tokens[tokenGet][user] = safeAdd(tokens[tokenGet][user], safeMul(amount, ((1 ether) - feeMake)) / (1 ether));
    tokens[tokenGet][feeAccount] = safeAdd(tokens[tokenGet][feeAccount], safeMul(amount, feeMake) / (1 ether));
    tokens[tokenGive][user] = safeSub(tokens[tokenGive][user], safeMul(amountGive, amount) / amountGet);
    tokens[tokenGive][msg.sender] = safeAdd(tokens[tokenGive][msg.sender], safeMul(safeMul(((1 ether) - feeTake), amountGive), amount) / amountGet / (1 ether));
    tokens[tokenGive][feeAccount] = safeAdd(tokens[tokenGive][feeAccount], safeMul(safeMul(feeTake, amountGive), amount) / amountGet / (1 ether));
    orderFills[hash] = safeAdd(orderFills[hash], amount);
    Trade(tokenGet, amount, tokenGive, amountGive * amount / amountGet, user, msg.sender);
  }

  function testTrade(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s, uint amount, address sender) constant returns(bool) {
    if (!(
      tokens[tokenGet][sender] >= amount &&
      availableVolume(tokenGet, amountGet, tokenGive, amountGive, expires, nonce, user, v, r, s) >= amount
    )) return false;
    return true;
  }

  function availableVolume(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s) constant returns(uint) {
    bytes32 hash = sha256(tokenGet, amountGet, tokenGive, amountGive, expires, nonce);
    if (!(
      ecrecover(hash,v,r,s) == user &&
      block.number <= expires
    )) return 0;
    uint available1 = safeSub(amountGet, orderFills[hash]);
    uint available2 = safeMul(tokens[tokenGive][user], amountGet) / amountGive;
    if (available1<available2) return available1;
    return available2;
  }

  function cancelOrder(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s) {
    if (msg.value>0) throw;
    bytes32 hash = sha256(tokenGet, amountGet, tokenGive, amountGive, expires, nonce);
    if (user!=msg.sender) throw;
    orderFills[hash] = amountGet;
    Cancel(tokenGet, amountGet, tokenGive, amountGive, expires, nonce, msg.sender, v, r, s);
  }
}