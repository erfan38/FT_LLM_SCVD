pragma solidity ^0.4.23;



contract MyToken is ERC223 {
    using SafeMath for uint;

    mapping(address => uint) balances; 

    string public name;
    string public symbol;
    uint8 public decimals;
    uint public totalSupply;

 
    constructor(string _name, string _symbol, uint8 _decimals, uint _totalSupply) public {
		name = _name;
		symbol = _symbol;
		decimals = _decimals;
		totalSupply = _totalSupply;
		balances[msg.sender] = _totalSupply;
	}

    function name() public view returns (string) {
		 return name;
    }

    function symbol() public view returns (string) {
		return symbol;
	}

    function decimals() public view returns (uint8) {
    	return decimals;
    }

    function totalSupply() public view returns (uint) {
    	return totalSupply;
    }


	function balanceOf(address owner) public view returns (uint) {
		return balances[owner];
	}

	function transfer(address to, uint value, bytes data) public returns (bool) {
		if(balanceOf(msg.sender) < value) revert();
		
		

		balances[msg.sender] = balances[msg.sender].sub(value);
		balances[to] = balances[to].add(value);
		if(isContract(to)) {
			ERC223ReceivingContract receiver = ERC223ReceivingContract(to);
			receiver.tokenFallback(msg.sender, value, data);
		}
		emit Transfer(msg.sender, to, value, data);
		return true;
	}

	function transfer(address to, uint value) public returns (bool) {
		if(balanceOf(msg.sender) < value) revert();
		bytes memory empty;

		balances[msg.sender] = balances[msg.sender].sub(value);
        balances[to] = balances[to].add(value);
        if(isContract(to)) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(to);
            receiver.tokenFallback(msg.sender, value, empty);
        }
        emit Transfer(msg.sender, to, value, empty);
        return true;
	}

	function transfer(address to, uint value, bytes data, string customFallback) public returns (bool) {
		if(balanceOf(msg.sender) < value) revert();

		balances[msg.sender] = balances[msg.sender].sub(value);
        balances[to] = balances[to].add(value);
		if (isContract(to)) {
            assert(to.call.value(0)(bytes4(keccak256(customFallback)), msg.sender, value, data));
        }
        emit Transfer(msg.sender, to, value, data);
        return true;
	}

	function isContract(address addr) private view returns (bool) {
		uint len;
		assembly {
			len := extcodesize(addr)
		}
		return (len > 0);
	}
}