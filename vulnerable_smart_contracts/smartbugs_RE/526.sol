pragma solidity ^0.4.2;
contract NinjaToken is StandardToken{
    string public name ="NinjaToken";
    string public version="0.0.1";
    uint public decimals = 18;
    mapping(address=>string) public commit;
    
    address public founder;
    address public admin; 
    bool public fundingLock=true;  
    address public fundingAccount;
    uint public startBlock;        
    uint public blockDuration;     
    uint public fundingExchangeRate;
    uint public price=10;
    bool public transferLock=false;  

    event Funding(address sender, uint256 eth);
    event Buy(address buyer, uint256 eth);
    
    function NinjaToken(address _founder,address _admin){
        founder=_founder;
        admin=_admin;
    }
    
    function changeFunder(address _founder,address _admin){
        if(msg.sender!=admin) throw;
        founder=_founder;
        admin=_admin;        
    }
    
    function setFundingLock(bool _fundinglock,address _fundingAccount){
        if(msg.sender!=founder) throw;
        fundingLock=_fundinglock;
        fundingAccount=_fundingAccount;
    }
    
    function setFundingEnv(uint _startBlock, uint _blockDuration,uint _fundingExchangeRate){
        if(msg.sender!=founder) throw;
        startBlock=_startBlock;
        blockDuration=_blockDuration;
        fundingExchangeRate=_fundingExchangeRate;
    }
    
    function funding() payable {
        if(fundingLock||block.number<startBlock||block.number>startBlock+blockDuration) throw;
        if(balances[msg.sender]>balances[msg.sender]+msg.value*fundingExchangeRate || msg.value>msg.value*fundingExchangeRate) throw;
        if(!fundingAccount.call.value(msg.value)()) throw;
        balances[msg.sender]+=msg.value*fundingExchangeRate;
        Funding(msg.sender,msg.value);
    }
    
    function setPrice(uint _price,bool _transferLock){
        if(msg.sender!=founder) throw;
        price=_price;
        transferLock=_transferLock;
    }
    
    function buy(string _commit) payable{
        if(balances[msg.sender]>balances[msg.sender]+msg.value*price || msg.value>msg.value*price) throw;
        if(!fundingAccount.call.value(msg.value)()) throw;
        balances[msg.sender]+=msg.value*price;
        commit[msg.sender]=_commit;
        Buy(msg.sender,msg.value);
    }
    
    function transfer(address _to, uint256 _value)constant returns(bool success){
        if(transferLock) throw;
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value)constant returns(bool success){
        if(transferLock) throw;
        return super.transferFrom(_from, _to, _value);
    }

}