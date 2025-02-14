contract ERC223ContractInterface {
    function erc223Fallback(address _from, uint256 _value, bytes _data){
        // to avoid warnings during compilation
        _from = _from;
        _value = _value;
        _data = _data;
        // Incoming transaction code here
        throw;
    }
}


/* https://github.com/LykkeCity/EthereumApiDotNetCore/blob/master/src/ContractBuilder/contracts/token/SafeMath.sol */
