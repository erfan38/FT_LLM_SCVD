




contract FirstBloodToken is StandardToken, SafeMath {

    string public name = "FirstBlood Token";
    string public symbol = "1ST";
    uint public decimals = 18;
    uint public startBlock; 
    uint public endBlock; 

    
    
    
    address public founder = 0x0;

    
    
    address public signer = 0x0;

    uint public etherCap = 465313 * 10**18; 
    uint public transferLockup = 370285; 
    uint public founderLockup = 2252571; 
    uint public bountyAllocation = 2500000 * 10**18; 
    uint public ecosystemAllocation = 5 * 10**16; 
    uint public founderAllocation = 10 * 10**16; 
    bool public bountyAllocated = false; 
    bool public ecosystemAllocated = false; 
    bool public founderAllocated = false; 
    uint public presaleTokenSupply = 0; 
    uint public presaleEtherRaised = 0; 
    bool public halted = false; 
    event Buy(address indexed sender, uint eth, uint fbt);
    event Withdraw(address indexed sender, address to, uint eth);
    event AllocateFounderTokens(address indexed sender);
    event AllocateBountyAndEcosystemTokens(address indexed sender);

    function FirstBloodToken(address founderInput, address signerInput, uint startBlockInput, uint endBlockInput) {
        founder = founderInput;
        signer = signerInput;
        startBlock = startBlockInput;
        endBlock = endBlockInput;
    }

    






    function price() constant returns(uint) {
        if (block.number>=startBlock && block.number<startBlock+250) return 170; 
        if (block.number<startBlock || block.number>endBlock) return 100; 
        return 100 + 4*(endBlock - block.number)/(endBlock - startBlock + 1)*67/4; 
    }

    
    function testPrice(uint blockNumber) constant returns(uint) {
        if (blockNumber>=startBlock && blockNumber<startBlock+250) return 170; 
        if (blockNumber<startBlock || blockNumber>endBlock) return 100; 
        return 100 + 4*(endBlock - blockNumber)/(endBlock - startBlock + 1)*67/4; 
    }

    
    function buy(uint8 v, bytes32 r, bytes32 s) {
        buyRecipient(msg.sender, v, r, s);
    }

    

















    function buyRecipient(address recipient, uint8 v, bytes32 r, bytes32 s) {
        bytes32 hash = sha256(msg.sender);
        if (ecrecover(hash,v,r,s) != signer) throw;
        if (block.number<startBlock || block.number>endBlock || safeAdd(presaleEtherRaised,msg.value)>etherCap || halted) throw;
        uint tokens = safeMul(msg.value, price());
        balances[recipient] = safeAdd(balances[recipient], tokens);
        totalSupply = safeAdd(totalSupply, tokens);
        presaleEtherRaised = safeAdd(presaleEtherRaised, msg.value);

        if (!founder.call.value(msg.value)()) throw; 

        Buy(recipient, msg.value, tokens);
    }

    














    function allocateFounderTokens() {
        if (msg.sender!=founder) throw;
        if (block.number <= endBlock + founderLockup) throw;
        if (founderAllocated) throw;
        if (!bountyAllocated || !ecosystemAllocated) throw;
        balances[founder] = safeAdd(balances[founder], presaleTokenSupply * founderAllocation / (1 ether));
        totalSupply = safeAdd(totalSupply, presaleTokenSupply * founderAllocation / (1 ether));
        founderAllocated = true;
        AllocateFounderTokens(msg.sender);
    }

    















    function allocateBountyAndEcosystemTokens() {
        if (msg.sender!=founder) throw;
        if (block.number <= endBlock) throw;
        if (bountyAllocated || ecosystemAllocated) throw;
        presaleTokenSupply = totalSupply;
        balances[founder] = safeAdd(balances[founder], presaleTokenSupply * ecosystemAllocation / (1 ether));
        totalSupply = safeAdd(totalSupply, presaleTokenSupply * ecosystemAllocation / (1 ether));
        balances[founder] = safeAdd(balances[founder], bountyAllocation);
        totalSupply = safeAdd(totalSupply, bountyAllocation);
        bountyAllocated = true;
        ecosystemAllocated = true;
        AllocateBountyAndEcosystemTokens(msg.sender);
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

    









    function transfer(address _to, uint256 _value) returns (bool success) {
        if (block.number <= endBlock + transferLockup && msg.sender!=founder) throw;
        return super.transfer(_to, _value);
    }
    




    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (block.number <= endBlock + transferLockup && msg.sender!=founder) throw;
        return super.transferFrom(_from, _to, _value);
    }

    










    function() {
        throw;
    }

}