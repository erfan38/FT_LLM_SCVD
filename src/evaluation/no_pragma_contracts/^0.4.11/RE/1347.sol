contract E4LavaRewards
{
        function checkDividends(address _addr) constant returns(uint _amount);
        function withdrawDividends() public returns (uint namount);
        function transferDividends(address _to) returns (bool success);
        function getAccountInfo(address _addr) constant returns(uint _tokens, uint _snapshot, uint _points);

}

// --------------------------
//  E4LavaOptin - abstract e4 optin contract
// --------------------------
