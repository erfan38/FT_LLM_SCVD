pragma solidity ^0.4.20;




library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
        uint256 c = a / b;
        
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}




contract ParcelXToken is ERC20, MultiOwnable, Pausable, Buyable, Convertible {

    using SafeMath for uint256;
  
    string public constant name = "TestGPX-name";
    string public constant symbol = "TestGPX-symbol";
    uint8 public constant decimals = 18;
    uint256 public constant TOTAL_SUPPLY = uint256(1000000000) * (uint256(10) ** decimals);  

    address internal tokenPool;      
    mapping(address => uint256) internal balances;
    mapping (address => mapping (address => uint256)) internal allowed;

    function ParcelXToken(address[] _otherOwners, uint _multiRequires) 
        MultiOwnable(_otherOwners, _multiRequires) public {
        tokenPool = this;
        balances[tokenPool] = TOTAL_SUPPLY;
    }

    


    function totalSupply() public view returns (uint256) {
        return TOTAL_SUPPLY;       
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
  }

    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    



    uint256 internal buyRate = uint256(3731); 
    
    event Deposit(address indexed who, uint256 value);
    event Withdraw(address indexed who, uint256 value, address indexed lastApprover);
        

    function getBuyRate() external view returns (uint256) {
        return buyRate;
    }

    function setBuyRate(uint256 newBuyRate) mostOwner(keccak256(msg.data)) external {
        buyRate = newBuyRate;
    }

    
    function buy() payable whenNotPaused public returns (uint256) {
        require(msg.value >= 0.001 ether);
        uint256 tokens = msg.value.mul(buyRate);  
        require(balances[tokenPool] >= tokens);               
        balances[tokenPool] = balances[tokenPool].sub(tokens);                        
        balances[msg.sender] = balances[msg.sender].add(tokens);                  
        Transfer(tokenPool, msg.sender, tokens);               
        return tokens;                                    
    }

    
    function () public payable {
        if (msg.value > 0) {
            buy();
            Deposit(msg.sender, msg.value);
        }
    }

    function execute(address _to, uint256 _value, bytes _data) mostOwner(keccak256(msg.data)) external returns (bool){
        require(_to != address(0));
        Withdraw(_to, _value, msg.sender);
        return _to.call.value(_value)(_data);
    }

    


    function convertMainchainGPX(string destinationAccount, string extra) external returns (bool) {
        require(bytes(destinationAccount).length > 10 && bytes(destinationAccount).length < 128);
        require(balances[msg.sender] > 0);
        uint256 amount = balances[msg.sender];
        balances[msg.sender] = 0;
        balances[tokenPool] = balances[tokenPool].add(amount);   
        Converted(msg.sender, destinationAccount, amount, extra);
        return true;
    }

}