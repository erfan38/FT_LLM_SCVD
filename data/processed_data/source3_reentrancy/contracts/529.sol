contract HawalaToken is StandardToken {

    function () {
        //if ether is sent to this address, send it back.
        throw;
    }

    string public name;                  
    uint8 public decimals;               
    string public symbol;
    string public version = 'HAT';       


    function HawalaToken(
        ) {
        //Add initial supply to total supply to make  7M. remaining 4.5M lockedd in escrow until pos impl        
        totalSupply+=initialSupply;
        balances[msg.sender] = initialSupply;               
        name = "HawalaToken";                              
        decimals = 12;                            
        symbol = "HAT";                           
    }

   
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
}