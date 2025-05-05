contract casinoProxy is casinoBank {
	/** indicates if an address is authorized to call game functions  */
	mapping(address => bool) public authorized;
	/** list of casino game 