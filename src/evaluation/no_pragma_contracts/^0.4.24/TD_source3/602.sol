contract StakeDiceGame
{
     
    function () payable external
    {
        revert();
    }
    
     
     
    
    StakeDice public stakeDice;
    
     
     
     
     
    uint256 public winningChance;
    
     
     
     
     
    function multiplierOnWin() public view returns (uint256)
    {
        uint256 beforeHouseEdge = 10000;
        uint256 afterHouseEdge = beforeHouseEdge - stakeDice.houseEdge();
        return afterHouseEdge * 10000 / winningChance;
    }
    
    function maximumBet() public view returns (uint256)
    {
        uint256 availableTokens = stakeDice.stakeTokenContract().balanceOf(address(stakeDice));
        return availableTokens * 10000 / multiplierOnWin() / 5;
    }
    

    
     
     
    
     
     
    constructor(StakeDice _stakeDice, uint256 _winningChance) public
    {
         
        require(_winningChance > 0);
        require(_winningChance < 10000);
        require(_stakeDice != address(0x0));
        require(msg.sender == address(_stakeDice));
        
        stakeDice = _stakeDice;
        winningChance = _winningChance;
    }
    
     
    function setWinningChance(uint256 _newWinningChance) external
    {
        require(msg.sender == stakeDice.owner());
        require(_newWinningChance > 0);
        require(_newWinningChance < 10000);
        winningChance = _newWinningChance;
    }
    
     
     
    function withdrawStakeTokens(uint256 _amount, address _to) external
    {
        require(msg.sender == stakeDice.owner());
        require(_to != address(0x0));
        stakeDice.stakeTokenContract().transfer(_to, _amount);
    }
}


