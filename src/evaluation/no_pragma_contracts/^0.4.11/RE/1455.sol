contract token {

    /*
    *  @notice exposes the transfer method of the token contract
    *  @param _receiver address receiving tokens
    *  @param _amount number of tokens being transferred       
    */    
    function transfer(address _receiver, uint _amount) returns (bool success) { }

    /*
    *  @notice exposes the priviledgedAddressBurnUnsoldCoins method of the token contract
    *  burns all unsold coins  
    */     
    function priviledgedAddressBurnUnsoldCoins(){ }

}

/*
`* is owned
*/
