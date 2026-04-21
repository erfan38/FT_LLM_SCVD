contract ERC23Token is ERC23 {

  mapping(address => uint256) balances;
  mapping (address => mapping (address => uint256)) allowed;

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

  //function that is called when a user or another 