contract Token {
    // function balanceOf(address /*tokenOwner*/) public view returns (uint /*balance*/);
    // function transfer(address /*to*/, uint /*tokens*/) public returns (bool /*success*/);
    // function allowance(address _owner, address _spender) constant returns (uint /*remaining*/)
    function balanceOf(address tokenOwner) public view returns (uint /*balance*/);
    function transfer(address toAddress, uint tokens) public returns (bool /*success*/);
    function allowance(address _owner, address _spender) constant returns (uint /*remaining*/);
}


