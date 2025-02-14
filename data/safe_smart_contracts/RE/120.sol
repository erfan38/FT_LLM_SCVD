contract C2L is ERC223, Owned {
  //constants
  uint internal constant INITIAL_COIN_BALANCE = 21000000; //starting balance of 21 million coins

  //variables
  string public name = "C2L"; //name of currency
  string public symbol = "C2L";
  uint8 public decimals = 0;
  mapping(address => bool) beingEdited; //mapping to prevent multiple edits of the same account occuring at the same time (reentrancy)

  uint public totalCoinSupply = INITIAL_COIN_BALANCE; //number of this coin in active existence
  mapping(address => uint) internal balances; //balances of users with this coin
  mapping(address => mapping(address => uint)) internal allowed; //map holding how much each user is allowed to transfer out of other addresses
  address[] addressLUT;

  //C2L 