contract MergeCoin is Ownable, StandardToken {

    string public name = "MERGE";
    string public symbol = "MGE";
    uint public decimals = 18;                  // token has 18 digit precision

    uint public totalSupply = 10 * (10**6) * (10**18);  // 10 Million Tokens


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