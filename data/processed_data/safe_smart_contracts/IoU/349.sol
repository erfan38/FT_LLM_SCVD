contract Token is Pausable, ERC20 {
    using SafeMath for uint;
    event Burn(address indexed burner, uint256 value);

    mapping(address => uint) balances;
    mapping (address => mapping (address => uint)) internal allowed;
    mapping(address => uint) public balanceOfLocked;
    mapping(address => bool) public addressLocked;

    constructor() ERC20("OCP", "OCP", 18) public {
        totalSupply = 10000000000 * 10 ** uint(decimals);
        balances[msg.sender] = totalSupply;
    }

    modifier lockCheck(address from, uint value) { 
        require(addressLocked[from] == false);
        require(balances[from] >= balanceOfLocked[from]);
        require(value <= balances[from] - balanceOfLocked[from]);
        _;
    }

    function burn(uint _value) onlyOwner public {
        balances[owner] = balances[owner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        emit Burn(msg.sender, _value);
    }

    function lockAddressValue(address _addr, uint _value) onlyOwner public {
        balanceOfLocked[_addr] = _value;
    }

    function lockAddress(address addr) onlyOwner public {
        addressLocked[addr] = true;
    }

    function unlockAddress(address addr) onlyOwner public {
        addressLocked[addr] = false;
    }

    function transfer(address _to, uint _value) lockCheck(msg.sender, _value) whenNotPaused public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint balance) {
        return balances[_owner];
    }

    function transferFrom(address _from, address _to, uint _value) public lockCheck(_from, _value) whenNotPaused returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint _value) public whenNotPaused returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint) {
        return allowed[_owner][_spender];
    }

    function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
}