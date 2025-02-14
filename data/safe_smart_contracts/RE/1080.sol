contract RiskCoin is Coin{
    function RiskCoin(string _tokenName, string _tokenSymbol) 
	Coin(_tokenName,_tokenSymbol) {} 
	
    function() payable {
		/** @dev direct any ETH sent to this RiskCoin address to the minter.NewRisk function
		*/
        mint.NewRiskAdr.value(msg.value)(msg.sender);
    }  
}

/** @title StatiCoin. */
