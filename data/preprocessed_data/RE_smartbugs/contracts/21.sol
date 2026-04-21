pragma solidity ^0.4.11;

contract MoldCoin is StandardToken, SafeMath {

    string public name = "MOLD";
    string public symbol = "MLD";
    uint public decimals = 18;

    uint public startDatetime; 
    uint public firstStageDatetime; 
    uint public secondStageDatetime; 
    uint public endDatetime; 

    
    
    address public founder;

    
    address public admin;

    uint public coinAllocation = 20 * 10**8 * 10**decimals; 
    uint public angelAllocation = 2 * 10**8 * 10**decimals; 
    uint public founderAllocation = 3 * 10**8 * 10**decimals; 

    bool public founderAllocated = false; 

    uint public saleTokenSupply = 0; 
    uint public salesVolume = 0; 

    uint public angelTokenSupply = 0; 

    bool public halted = false; 

    event Buy(address indexed sender, uint eth, uint tokens);
    event AllocateFounderTokens(address indexed sender, uint tokens);
    event AllocateAngelTokens(address indexed sender, address to, uint tokens);
    event AllocateUnsoldTokens(address indexed sender, address holder, uint tokens);

    modifier onlyAdmin {
        require(msg.sender == admin);
        _;
    }

    modifier duringCrowdSale {
        require(block.timestamp >= startDatetime && block.timestamp <= endDatetime);
        _;
    }

    



    function MoldCoin(uint startDatetimeInSeconds, address founderWallet) {

        admin = msg.sender;
        founder = founderWallet;
        startDatetime = startDatetimeInSeconds;
        firstStageDatetime = startDatetime + 120 * 1 hours;
        secondStageDatetime = firstStageDatetime + 240 * 1 hours;
        endDatetime = secondStageDatetime + 2040 * 1 hours;

    }

    


    function price(uint timeInSeconds) constant returns(uint) {
        if (timeInSeconds < startDatetime) return 0;
        if (timeInSeconds <= firstStageDatetime) return 15000; 
        if (timeInSeconds <= secondStageDatetime) return 12000; 
        if (timeInSeconds <= endDatetime) return 10000; 
        return 0;
    }

    


    function buy() payable {
        buyRecipient(msg.sender);
    }

    function() payable {
        buyRecipient(msg.sender);
    }

    



    function buyRecipient(address recipient) duringCrowdSale payable {
        require(!halted);

        uint tokens = safeMul(msg.value, price(block.timestamp));
        require(safeAdd(saleTokenSupply,tokens)<=coinAllocation );

        balances[recipient] = safeAdd(balances[recipient], tokens);

        totalSupply = safeAdd(totalSupply, tokens);
        saleTokenSupply = safeAdd(saleTokenSupply, tokens);
        salesVolume = safeAdd(salesVolume, msg.value);

        if (!founder.call.value(msg.value)()) revert(); 

        Buy(recipient, msg.value, tokens);
    }

    


    function allocateFounderTokens() onlyAdmin {
        require( block.timestamp > endDatetime );
        require(!founderAllocated);

        balances[founder] = safeAdd(balances[founder], founderAllocation);
        totalSupply = safeAdd(totalSupply, founderAllocation);
        founderAllocated = true;

        AllocateFounderTokens(msg.sender, founderAllocation);
    }

    


    function allocateAngelTokens(address angel, uint tokens) onlyAdmin {

        require(safeAdd(angelTokenSupply,tokens) <= angelAllocation );

        balances[angel] = safeAdd(balances[angel], tokens);
        angelTokenSupply = safeAdd(angelTokenSupply, tokens);
        totalSupply = safeAdd(totalSupply, tokens);

        AllocateAngelTokens(msg.sender, angel, tokens);
    }

    


    function halt() onlyAdmin {
        halted = true;
    }

    function unhalt() onlyAdmin {
        halted = false;
    }

    


    function changeAdmin(address newAdmin) onlyAdmin  {
        admin = newAdmin;
    }

    


    function arrangeUnsoldTokens(address holder, uint256 tokens) onlyAdmin {
        require( block.timestamp > endDatetime );
        require( safeAdd(saleTokenSupply,tokens) <= coinAllocation );
        require( balances[holder] >0 );

        balances[holder] = safeAdd(balances[holder], tokens);
        saleTokenSupply = safeAdd(saleTokenSupply, tokens);
        totalSupply = safeAdd(totalSupply, tokens);

        AllocateUnsoldTokens(msg.sender, holder, tokens);

    }

}

