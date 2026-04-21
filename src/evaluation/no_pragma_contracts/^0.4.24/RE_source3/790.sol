contract casinoProxy is casinoBank{
	/** indicates if an address is authorized to call game functions  */
  mapping(address => bool) public authorized;
  /** indicates if the user allowed a casino game address to move his/her funds **/
  mapping(address => mapping(address => bool)) public authorizedByUser;
  /** counts how often an address has been deauthorized by the user => make sure signatzures can't be reused**/
  mapping(address => mapping(address => uint8)) public lockedByUser;
	/** list of casino game 