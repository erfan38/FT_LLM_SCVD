contract YOPT is SafeMath{
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    address public owner;

    
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    event Burn(address indexed from, uint256 value);
    
    
    function YOPT(
        uint256 initialSupply,
        string tokenName,
        uint8 decimalUnits,
        string tokenSymbol
        ) {
        totalSupply = initialSupply * 10 ** uint256(decimalUnits);  
        balanceOf[msg.sender] = totalSupply;    
        name = tokenName;                       
        symbol = tokenSymbol;                   
        decimals = decimalUnits;                
        owner = msg.sender;
    }

    
    function transfer(address _to, uint256 _value) {
        if (_to == 0x0) throw;                               
        if (_value <= 0) throw; 
        if (balanceOf[msg.sender] < _value) throw;           
        if (balanceOf[_to] + _value < balanceOf[_to]) throw; 
        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value);                     
        balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to], _value);                            
        Transfer(msg.sender, _to, _value);                   
    }

    
    function approve(address _spender, uint256 _value)
        returns (bool success) {
        if (_value <= 0) throw; 
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (_to == 0x0) throw;                                
        if (_value <= 0) throw; 
        if (balanceOf[_from] < _value) throw;                 
        if (balanceOf[_to] + _value < balanceOf[_to]) throw;  
        if (_value > allowance[_from][msg.sender]) throw;     
        balanceOf[_from] = SafeMath.safeSub(balanceOf[_from], _value);                           
        balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to], _value);                             
        allowance[_from][msg.sender] = SafeMath.safeSub(allowance[_from][msg.sender], _value);
        Transfer(_from, _to, _value);
        return true;
    }

    function burn(uint256 _value) returns (bool success) {
        if (balanceOf[msg.sender] < _value) throw;            
        if (_value <= 0) throw; 
        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value);                      
        totalSupply = SafeMath.safeSub(totalSupply,_value);                                
        Burn(msg.sender, _value);
        return true;
    }

}