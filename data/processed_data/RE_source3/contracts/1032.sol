contract StatiCoin is Coin{
    function StatiCoin(string _tokenName, string _tokenSymbol, address _minter) 
	Coin(_tokenName,_tokenSymbol,_minter) {} 

    function() payable {        
		/** @dev direct any ETH sent to this StatiCoin address to the minter.NewStatic function
        */
        mint.NewStaticAdr.value(msg.value)(msg.sender);
    }  
}

/** @title I_coin. */
