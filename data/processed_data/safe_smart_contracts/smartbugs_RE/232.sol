pragma solidity ^0.4.13;














contract EnjinBuyer {
  
  
  uint256 public eth_minimum = 3270 ether;

  
  mapping (address => uint256) public balances;
  
  uint256 public buy_bounty;
  
  uint256 public withdraw_bounty;
  
  bool public bought_tokens;
  
  uint256 public contract_eth_value;
  
  bool public kill_switch;
  
  
  bytes32 password_hash = 0x48e4977ec30c7c773515e0fbbfdce3febcd33d11a34651c956d4502def3eac09;
  
  
  uint256 public earliest_buy_time = 1504188000;
  
  uint256 public eth_cap = 5000 ether;
  
  address public developer = 0xA4f8506E30991434204BC43975079aD93C8C5651;
  
  address public sale;
  
  ERC20 public token;
  
  
  function set_sale_address(address _sale) {
    
    require(msg.sender == developer);
    
    require(sale == 0x0);
    
    sale = _sale;
  }

  
  
  
  
  function set_token_address(address _token) {
    
    require(msg.sender == developer);
    
    token = ERC20(_token);
  }
 
  
  
  function activate_kill_switch(string password) {
    
    require(msg.sender == developer || sha3(password) == password_hash);
    
    uint256 claimed_bounty = buy_bounty;
    
    buy_bounty = 0;
    
    kill_switch = true;
    
    msg.sender.transfer(claimed_bounty);
  }
  
  
  function withdraw(address user){
    
    require(bought_tokens || now > earliest_buy_time + 1 hours);
    
    if (balances[user] == 0) return;
    
    if (!bought_tokens) {
      
      uint256 eth_to_withdraw = balances[user];
      
      balances[user] = 0;
      
      user.transfer(eth_to_withdraw);
    }
    
    else {
      
      uint256 contract_token_balance = token.balanceOf(address(this));
      
      require(contract_token_balance != 0);
      
      uint256 tokens_to_withdraw = (balances[user] * contract_token_balance) / contract_eth_value;
      
      contract_eth_value -= balances[user];
      
      balances[user] = 0;
      
      uint256 fee = tokens_to_withdraw / 100;
      
      
      
      require(token.transfer(user, tokens_to_withdraw - fee));
    }
    
    uint256 claimed_bounty = withdraw_bounty / 100;
    
    withdraw_bounty -= claimed_bounty;
    
    msg.sender.transfer(claimed_bounty);
  }
  
  
  function add_to_buy_bounty() payable {
    
    require(msg.sender == developer);
    
    buy_bounty += msg.value;
  }
  
  
  function add_to_withdraw_bounty() payable {
    
    require(msg.sender == developer);
    
    withdraw_bounty += msg.value;
  }
  
  
  function claim_bounty(){
    
    
    if (this.balance < eth_minimum) return;

    
    if (bought_tokens) return;
    
    if (now < earliest_buy_time) return;
    
    if (kill_switch) return;
    
    require(sale != 0x0);
    
    bought_tokens = true;
    
    uint256 claimed_bounty = buy_bounty;
    
    buy_bounty = 0;
    
    contract_eth_value = this.balance - (claimed_bounty + withdraw_bounty);
    
    
    
    require(sale.call.value(contract_eth_value)());
    
    msg.sender.transfer(claimed_bounty);
  }
  
  
  function () payable {
    
    require(!kill_switch);
    
    require(!bought_tokens);
    
    require(this.balance < eth_cap);
    
    balances[msg.sender] += msg.value;
  }
}