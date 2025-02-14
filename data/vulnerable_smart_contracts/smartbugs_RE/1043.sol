pragma solidity ^0.5.1;



interface ERC223Handler { 
    function tokenFallback(address _from, uint _value, bytes calldata _data) external;
}

contract SaltynessToken{
    using SafeMath for uint256;
    using SafeMath for uint;
    
	modifier onlyOwner {
		require(msg.sender == owner);
		_;
	}
    
    constructor() public{
        owner = msg.sender;
    }
	address owner;
	address newOwner;
    
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping (address => uint256)) allowances;
    
    string constant public name = "Saltyness";
    string constant public symbol = "SALT";
    uint8 constant public decimals = 18;
    uint256 public totalSupply;
    
    
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    event Transfer(address indexed from, address indexed to, uint value);
    event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);
    
    
    
    function setNewOwner(address o) public onlyOwner {
		newOwner = o;
	}

	function acceptNewOwner() public {
		require(msg.sender == newOwner);
		owner = msg.sender;
	}
	
    
	function giveSalt(address _saltee, uint256 _salt) public onlyOwner {
	    totalSupply = totalSupply.add(_salt);
	    balanceOf[_saltee] = balanceOf[_saltee].add(_salt);
        emit Transfer(address(this), _saltee, _salt, "");
        emit Transfer(address(this), _saltee, _salt);
	}
	
    
    
    function transfer(address _to, uint _value, bytes memory _data, string memory _function) public returns(bool ok){
        actualTransfer(msg.sender, _to, _value, _data, _function, true);
        return true;
    }
    
    function transfer(address _to, uint _value, bytes memory _data) public returns(bool ok){
        actualTransfer(msg.sender, _to, _value, _data, "", true);
        return true;
    }
    function transfer(address _to, uint _value) public returns(bool ok){
        actualTransfer(msg.sender, _to, _value, "", "", true);
        return true;
    }
    
    function approve(address _spender, uint _value) public returns (bool success) {
        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    function transferFrom(address _from, address _to, uint _value) public returns (bool success) {
        uint256 _allowance = allowances[_from][msg.sender];
        require(_allowance > 0, "Not approved");
        require(_allowance >= _value, "Over spending limit");
        allowances[_from][msg.sender] = _allowance.sub(_value);
        actualTransfer(_from, _to, _value, "", "", false);
        return true;
    }
    
    
     
    
    
    function allowance(address _sugardaddy, address _spender) public view returns (uint remaining) {
        return allowances[_sugardaddy][_spender];
    }
    
    
    
    
    
    
    
    function actualTransfer(address _from, address _to, uint _value, bytes memory _data, string memory _function, bool _careAboutHumanity) private{
        require(balanceOf[_from] >= _value, "Insufficient balance"); 
        require(_to != address(this), "You can't sell back your tokens");
        
        
        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        
        if(_careAboutHumanity && isContract(_to)) {
            if (bytes(_function).length == 0){
                ERC223Handler receiver = ERC223Handler(_to);
                receiver.tokenFallback(_from, _value, _data);
            }else{
                bool success;
                bytes memory returnData;
                (success, returnData) = _to.call.value(0)(abi.encodeWithSignature(_function, _from, _value, _data));
                assert(success);
            }
        }
        emit Transfer(_from, _to, _value, _data);
        emit Transfer(_from, _to, _value);
    }
    
    function isContract(address _addr) private view returns (bool is_contract) {
        uint length;
        assembly {
            
            
            length := extcodesize(_addr)
        }
        return (length>0);
    }
}





library SafeMath {
    
    


    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0 || b == 0) {
           return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }
    
    


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
        
        
        return a / b;
    }
    
    


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    
    


    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}