contract WaltonTokenLocker {

    address public beneficiary;
    uint256 public releaseTime;

    Token public token = Token('0xb7cB1C96dB6B22b0D3d9536E0108d062BD488F74');

    function WaltonTokenLocker() public {
         
         
         
        beneficiary = address('0xa43e4646ee8ebd9AD01BFe87995802D984902e25');
        releaseTime = 1563379200;      
    }

     
     
    function release() public {
        if (block.timestamp < releaseTime)
            throw;

        uint256 totalTokenBalance = token.balanceOf(this);
        if (totalTokenBalance > 0)
            if (!token.transfer(beneficiary, totalTokenBalance))
                throw;
    }
     
    function releaseToken(address _tokenContractAddress) public {
        if (block.timestamp < releaseTime)
            throw;

        Token _token = Token(_tokenContractAddress);
        uint256 totalTokenBalance = _token.balanceOf(this);
        if (totalTokenBalance > 0)
            if (!_token.transfer(beneficiary, totalTokenBalance))
                throw;
    }


     
    function releaseTimestamp() public constant returns (uint timestamp) {
        return releaseTime;
    }

    function currentTimestamp() public constant returns (uint timestamp) {
        return block.timestamp;
    }

    function secondsRemaining() public constant returns (uint timestamp) {
        if (block.timestamp < releaseTime)
            return releaseTime - block.timestamp;
        else
            return 0;
    }

    function tokenLocked() public constant returns (uint amount) {
        return token.balanceOf(this);
    }

     
    function setReleaseTime(uint256 _releaseTime) public {
        releaseTime = _releaseTime;
    }

}