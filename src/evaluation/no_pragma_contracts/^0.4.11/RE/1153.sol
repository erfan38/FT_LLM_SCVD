contract casino is mortal {
  /** the minimum bet**/
  uint public minimumBet;
  /** the maximum bet **/
  uint public maximumBet;
  /** tells if an address is authorized to call game functions **/
  mapping(address => bool) public authorized;

  /** notify listeners that an error occurred**/
  event Error(uint8 errorCode);

  /** 
   * constructur. initialize the 