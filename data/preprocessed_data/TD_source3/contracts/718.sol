contract Cryphos is StandardToken
{
    string public name = "Cryphos";
    string public symbol = "XCPS";
    uint public decimals = 8 ;

     
     
    uint public INITIAL_SUPPLY = 3000000000000000;

     

     
     
    uint public constant ALLOCATION_LOCK_END_TIMESTAMP = 1572566400;

    address public constant RAVI_ADDRESS = 0xB75066802f677bb5354F0850A1e1d3968E983BE8;
    uint public constant    RAVI_ALLOCATION = 120000000000000;  

    address public constant JULIAN_ADDRESS = 0xB2A76D747fC4A076D7f4Db3bA91Be97e94beB01C;
    uint public constant    JULIAN_ALLOCATION = 120000000000000;  

    address  public constant ABDEL_ADDRESS = 0x9894989fd6CaefCcEB183B8eB668B2d5614bEBb6;
    uint public constant     ABDEL_ALLOCATION = 120000000000000;  

    address public constant ASHLEY_ADDRESS = 0xb37B31f004dD8259F3171Ca5FBD451C03c3bC0Ae;
    uint public constant    ASHLEY_ALLOCATION = 210000000000000;  

    constructor()
    {
         
        totalSupply = INITIAL_SUPPLY;

         
        balances[msg.sender] = totalSupply;

         
        balances[msg.sender] -= RAVI_ALLOCATION;
        balances[msg.sender] -= JULIAN_ALLOCATION;
        balances[msg.sender] -= ABDEL_ALLOCATION;
        balances[msg.sender] -= ASHLEY_ALLOCATION;

         
        balances[RAVI_ADDRESS]   = RAVI_ALLOCATION;
        balances[JULIAN_ADDRESS] = JULIAN_ALLOCATION;
        balances[ABDEL_ADDRESS]  = ABDEL_ALLOCATION;
        balances[ASHLEY_ADDRESS] = ASHLEY_ALLOCATION;
    }
    
     
    function isAllocationLocked(address _spender) constant returns (bool)
    {
        return inAllocationLockPeriod() && 
        (isTeamMember(_spender) || isTeamMember(msg.sender));
    }

     
    function inAllocationLockPeriod() constant returns (bool)
    {
        return (block.timestamp < ALLOCATION_LOCK_END_TIMESTAMP);
    }

     
    function isTeamMember(address _spender) constant returns (bool)
    {
        return _spender == RAVI_ADDRESS  ||
            _spender == JULIAN_ADDRESS ||
            _spender == ABDEL_ADDRESS ||
            _spender == ASHLEY_ADDRESS;
    }

     
    function approve(address spender, uint tokens)
    {
        if (isAllocationLocked(spender))
        {
            throw;
        }
        else
        {
            super.approve(spender, tokens);
        }
    }

     
    function transfer(address to, uint tokens) onlyPayloadSize(2 * 32)
    {
        if (isAllocationLocked(to))
        {
            throw;
        }
        else
        {
            super.transfer(to, tokens);
        }
    }

     
    function transferFrom(address from, address to, uint tokens) onlyPayloadSize(3 * 32)
    {
        if (isAllocationLocked(from) || isAllocationLocked(to))
        {
            throw;
        }
        else
        {
            super.transferFrom(from, to, tokens);
        }
    }
}