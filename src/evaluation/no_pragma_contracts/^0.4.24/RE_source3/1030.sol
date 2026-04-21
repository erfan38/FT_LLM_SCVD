contract RiskCoin is Coin{
    function RiskCoin(string _tokenName, string _tokenSymbol, address _minter) 
	Coin(_tokenName,_tokenSymbol,_minter) {} 
	
    function() payable {
		/** @dev direct any ETH sent to this RiskCoin address to the minter.NewRisk function
		*/
        mint.NewRiskAdr.value(msg.value)(msg.sender);
    }  
}

/** @title StatiCoin. */
