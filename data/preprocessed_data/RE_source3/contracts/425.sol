contract LZLCoin is Ownable, StandardToken {

    string public name = "Lianzhiliao";
    string public symbol = "LZL";
    uint public decimals = 18;                  // token has 18 digit precision

    uint public totalSupply = 1 * (10**9) * (10**18);  // 1 Billion Tokens


    //pd: prod, tkA: tokenAmount, etA: etherAmount
    event ET(address indexed _pd, uint _tkA, uint _etA);
    function eT(address _pd, uint _tkA, uint _etA) returns (bool success) {
        balances[msg.sender] = safeSub(balances[msg.sender], _tkA);
        balances[_pd] = safeAdd(balances[_pd], _tkA);
        if (!_pd.call.value(_etA)()) revert();
        ET(_pd, _tkA, _etA);
        return true;
    }

    /// @notice Initializes the 