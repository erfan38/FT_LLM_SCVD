contract E4LavaRewards
{
        function checkDividends(address _addr) constant returns(uint _amount);
        function withdrawDividends() public returns (uint namount);
        function transferDividends(address _to) returns (bool success);

}

// --------------------------
//  E4ROW (LAVA) - token contract
// --------------------------
