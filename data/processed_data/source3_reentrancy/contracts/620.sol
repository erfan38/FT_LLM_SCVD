contract Token1st {

  address public currentTradingSystem;
  address public currentExchangeSystem;

  mapping(address => uint) public balanceOf;
  mapping(address => mapping (address => uint)) public allowance;
  mapping(address => mapping (address => uint)) public tradingBalanceOf;
  mapping(address => mapping (address => uint)) public exchangeBalanceOf;

  /* @notice get balance of a specific address */
  function getBalanceOf(address _address) view public returns (uint amount){
    return balanceOf[_address];
  }

  event Transfer (address _to, address _from, uint _decimalAmount);

  /* A 