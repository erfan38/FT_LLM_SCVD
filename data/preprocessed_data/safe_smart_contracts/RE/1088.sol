contract GameCoin is ERC223, SafeMath {
  TokenStorage _s;
  mapping(address => uint) balances;
  
  string public name;
  string public symbol;
  uint8 public decimals;
  uint256 public totalSupply;
  
    
  // Function to access name of token .
  function name() constant returns (string _name) {
      return name;
  }
  // Function to access symbol of token .
  function symbol() constant returns (string _symbol) {
      return symbol;
  }
  // Function to access decimals of token .
  function decimals() constant returns (uint8 _decimals) {
      return decimals;
  }
  // Function to access total supply of tokens .
  function totalSupply() constant returns (uint256 _totalSupply) {
      return totalSupply;
  }
  
  
  function GameCoin() {
        _s = TokenStorage(0x9ff62629aec4436d03a84665acfb2a3195ca784b);
        name = "GameCoin";
        symbol = "GMC";
        decimals = 2;
        totalSupply = 25907002099;
        
  }
  
  

  // Function that is called when a user or another 