pragma solidity ^0.4.24;
 
contract MelonBitIndex_Erc223Token is SafeMath, Owned {    
    
    event Transfer(address indexed _from, address indexed _to, uint256 _value, bytes _data);

    mapping(address => uint) balances;
    
    string public name    = "MelonBit Market Index Erc223Token";
    string public symbol  = "MMX";
    uint8 public decimals = 8;
    uint256 public totalSupply;
    
    
    constructor() public
    {
        totalSupply = 10000000000 * 10**uint(decimals);
        balances[owner] = totalSupply;      
        
    }
        
    
    function name() constant returns (string _name) { return name; }
    
    function symbol() constant returns (string _symbol) { return symbol; }
    
    function decimals() constant returns (uint8 _decimals) { return decimals; }
    
    function totalSupply() constant returns (uint256 _totalSupply) { return totalSupply; }
        
    
    function transfer(address _to, uint _value, bytes _data, string _custom_fallback) returns (bool success) {       
        if(isContract(_to)) {
            if (balanceOf(msg.sender) < _value) revert();
            balances[msg.sender] = safeSub(balanceOf(msg.sender), _value);
            balances[_to] = safeAdd(balanceOf(_to), _value);
            assert(_to.call.value(0)(bytes4(sha3(_custom_fallback)), msg.sender, _value, _data));
            Transfer(msg.sender, _to, _value, _data);
            return true;
        }
        else {
            return transferToAddress(_to, _value, _data);
        }
    }
  
    
    function transfer(address _to, uint _value, bytes _data) returns (bool success) {       
        if(isContract(_to)) {
            return transferToContract(_to, _value, _data);
        }
        else {
            return transferToAddress(_to, _value, _data);
        }
    }
  
    
    
    function transfer(address _to, uint _value) returns (bool success) {        
        
        
        bytes memory empty;
        if(isContract(_to)) {
            return transferToContract(_to, _value, empty);
        }
        else {
            return transferToAddress(_to, _value, empty);
        }
    }

    
    function isContract(address _addr) private returns (bool is_contract) {
        uint length;
        assembly {
                
                length := extcodesize(_addr)
        }
        return (length>0);
    }

    
    function transferToAddress(address _to, uint _value, bytes _data) private returns (bool success) {
        if (balanceOf(msg.sender) < _value) revert();
        balances[msg.sender] = safeSub(balanceOf(msg.sender), _value);
        balances[_to] = safeAdd(balanceOf(_to), _value);
        Transfer(msg.sender, _to, _value, _data);
        return true;
    }
    
    
    function transferToContract(address _to, uint _value, bytes _data) private returns (bool success) {
        if (balanceOf(msg.sender) < _value) revert();
        balances[msg.sender] = safeSub(balanceOf(msg.sender), _value);
        balances[_to] = safeAdd(balanceOf(_to), _value);
        ContractReceiver receiver = ContractReceiver(_to);
        receiver.tokenFallback(msg.sender, _value, _data);
        Transfer(msg.sender, _to, _value, _data);
        return true;
    }

    function balanceOf(address _owner) constant returns (uint balance) {
        return balances[_owner];
    }
}