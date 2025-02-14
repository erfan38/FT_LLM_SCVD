pragma solidity ^0.4.18;





contract AutomobileCyberchainToken is StandardToken, SafeMath {

    string public name = "Automobile Cyberchain Token";
    string public symbol = "AMCC";
    uint public decimals = 18;
    uint preSalePrice  = 32000;
    uint crowSalePrice = 20000;
    uint prePeriod = 256 * 24 * 30;
    uint totalPeriod = 256 * 24 * 95; 
    uint public startBlock = 5455280; 
    uint public endBlock = startBlock + totalPeriod; 


    
    
    
    address public founder = 0xfD16CDC79382F86303E2eE8693C7f50A4d8b937F;
    uint256 public preEtherCap = 15625 * 10**18; 
    uint256 public etherCap =    88125 * 10**18; 
    uint256 public bountyAllocation = 1050000000 * 10**18;
    uint256 public maxToken = 3000000000 * 10**18;
    
    

    uint256 public presaleTokenSupply = 0; 
    uint256 public totalEtherRaised = 0;
    bool public halted = false; 

    event Buy(address indexed sender, uint eth, uint fbt);


    function AutomobileCyberchainToken() {
        balances[founder] = bountyAllocation;
        totalSupply = bountyAllocation;
        Transfer(address(0), founder, bountyAllocation);
    }


    function price() constant returns(uint) {
        if (block.number<startBlock || block.number > endBlock) return 0; 
        else if (block.number>=startBlock && block.number<startBlock+prePeriod) return preSalePrice; 
        else  return crowSalePrice; 
    }

   


    function() public payable  {
        buyToken(msg.sender, msg.value);
    }


    
    function buy(address recipient, uint256 value) public payable {
        if (value> msg.value) throw;

        if (value < msg.value) {
            require(msg.sender.call.value(msg.value - value)()); 
        }
        buyToken(recipient, value);
    }


    function buyToken(address recipient, uint256 value) internal {
        if (block.number<startBlock || block.number>endBlock || safeAdd(totalEtherRaised,value)>etherCap || halted) throw;
        if (block.number>=startBlock && block.number<=startBlock+prePeriod && safeAdd(totalEtherRaised,value) > preEtherCap) throw; 
        uint tokens = safeMul(value, price());
        balances[recipient] = safeAdd(balances[recipient], tokens);
        totalSupply = safeAdd(totalSupply, tokens);
        totalEtherRaised = safeAdd(totalEtherRaised, value);

        if (block.number<=startBlock+prePeriod) {
            presaleTokenSupply = safeAdd(presaleTokenSupply, tokens);
        }
        Transfer(address(0), recipient, tokens); 
        if (!founder.call.value(value)()) throw; 
        Buy(recipient, value, tokens); 

    }


    






    function halt() {
        if (msg.sender!=founder) throw;
        halted = true;
    }

    function unhalt() {
        if (msg.sender!=founder) throw;
        halted = false;
    }

    









    function changeFounder(address newFounder) {
        if (msg.sender!=founder) throw;
        founder = newFounder;
    }

    function withdrawExtraToken(address recipient) public {
      require(msg.sender == founder && block.number > endBlock && totalSupply < maxToken);

      uint256 leftTokens = safeSub(maxToken, totalSupply);
      balances[recipient] = safeAdd(balances[recipient], leftTokens);
      totalSupply = maxToken;
      Transfer(address(0), recipient, leftTokens);
    }


    









    
    
    
    


    




    
    
    
    
}