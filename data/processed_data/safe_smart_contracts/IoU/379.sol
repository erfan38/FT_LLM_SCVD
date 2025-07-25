contract MAJz is ERC20Token, Ownership {
    using SafeMath for uint256;

    string public symbol;
    string public name;
    uint256 public decimals;
    uint256 public totalSupply;

    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) allowed;
    
    
    constructor() public{
        symbol = "MAZ";
        name = "MAJz";
        decimals = 18;
        totalSupply = 560000000000000000000000000;
        balances[msg.sender] = totalSupply;
        owner = msg.sender;
        emit Transfer(address(0), msg.sender, totalSupply); 
    }


    
    
    function totalSupply() public view returns (uint256) {
        return totalSupply;
    }
    
    function balanceOf(address _targetAddress) public view returns (uint256) {
        return balances[_targetAddress];
    }
    
    
    function transfer(address _targetAddress, uint256 _value) validDestination(_targetAddress) public returns (bool) {
        balances[msg.sender] = SafeMath.sub(balances[msg.sender], _value); 
        balances[_targetAddress] = SafeMath.add(balances[_targetAddress], _value);
        emit Transfer(msg.sender, _targetAddress, _value); 
        return true; 
    }

    
    function allowance(address _originAddress, address _targetAddress) public view returns (uint256){
        return allowed[_originAddress][_targetAddress];
    }

    function approve(address _targetAddress, uint256 _value) public returns (bool) {
        allowed[msg.sender][_targetAddress] = _value;
        emit Approval(msg.sender, _targetAddress, _value);
        return true;
    }

    function transferFrom(address _originAddress, address _targetAddress, uint256 _value) public returns (bool) {
        balances[_originAddress] = SafeMath.sub(balances[_originAddress], _value); 
        allowed[_originAddress][msg.sender] = SafeMath.sub(allowed[_originAddress][msg.sender], _value); 
        balances[_targetAddress] = SafeMath.add(balances[_targetAddress], _value);
        emit Transfer(_originAddress, _targetAddress, _value);
        return true;
    }

    function () public payable {
        revert();
    }

    

    
    function burnTokens(uint256 _value) public onlyOwner returns (bool){
        balances[owner] = SafeMath.sub(balances[owner], _value); 
        totalSupply = SafeMath.sub(totalSupply, _value);
        emit BurnTokens(_value);
        return true;
    }

    
    function emitTokens(uint256 _value) public onlyOwner returns (bool){
        balances[owner] = SafeMath.add(balances[owner], _value); 
        totalSupply = SafeMath.add(totalSupply, _value);
        emit EmitTokens(_value);
        return true;
    }

    
    function revertTransfer(address _targetAddress, uint256 _value) public onlyOwner returns (bool) {
        balances[_targetAddress] = SafeMath.sub(balances[_targetAddress], _value);
        balances[owner] = SafeMath.add(balances[owner], _value);
        emit RevertTransfer(_targetAddress, _value);
        return true;
    }
    
    event RevertTransfer(address _targetAddress, uint256 _value);
    event BurnTokens(uint256 _value);
    event EmitTokens(uint256 _value);
}