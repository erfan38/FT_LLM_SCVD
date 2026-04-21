contract casinoBank is owned, safeMath {
	/** the total balance of all players with 4 virtual decimals **/
	uint public playerBalance;
	/** the balance per player in edgeless tokens with 4 virtual decimals */
	mapping(address => uint) public balanceOf;
	/** in case the user wants/needs to call the withdraw function from his own wallet, he first needs to request a withdrawal */
	mapping(address => uint) public withdrawAfter;
	/** the price per kgas in tokens (4 decimals) */
	uint public gasPrice = 20;
	/** the edgeless token contract */
	token edg;
	/** owner should be able to close the 