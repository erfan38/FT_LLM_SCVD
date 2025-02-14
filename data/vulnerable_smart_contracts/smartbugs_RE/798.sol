pragma solidity ^0.4.18;







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






contract ERC223Token is ERC223, StandardToken {
	using SafeMath for uint256;

	









	function transfer(address _to, uint256 _value, bytes _data, string _custom_fallback) public returns (bool success) {
		
		if(isContract(_to)) {
			
			require(_to != address(0));
			require(_value <= balances[msg.sender]);

			
			balances[msg.sender] = balances[msg.sender].sub(_value);
			balances[_to] = balances[_to].add(_value);
	
			
			assert(_to.call.value(0)(bytes4(keccak256(_custom_fallback)), msg.sender, _value, _data));
			Transfer(msg.sender, _to, _value, _data);
			return true;
		}
		else {
			
			return transferToAddress(_to, _value, _data);
		}
	}
  

	








	function transfer(address _to, uint256 _value, bytes _data) public returns (bool success) {
		
		if(isContract(_to)) {
			
			return transferToContract(_to, _value, _data);
		}
		else {
			
			return transferToAddress(_to, _value, _data);
		}
	}
  
	






	function transfer(address _to, uint256 _value) public returns (bool success) {
		
		
		bytes memory empty;

		
		if(isContract(_to)) {
			
			return transferToContract(_to, _value, empty);
		}
		else {
			
			return transferToAddress(_to, _value, empty);
		}
	}

	




	function isContract(address _addr) private view returns (bool is_contract) {
		uint256 length;
		assembly {
			
			length := extcodesize(_addr)
		}
		return (length > 0);
	}

	






	function transferToAddress(address _to, uint256 _value, bytes _data) private returns (bool success) {
		
		require(_to != address(0));
		require(_value <= balances[msg.sender]);

		
		balances[msg.sender] = balances[msg.sender].sub(_value);
		balances[_to] = balances[_to].add(_value);

		
		Transfer(msg.sender, _to, _value, _data);
		return true;
	}
  
	






	function transferToContract(address _to, uint256 _value, bytes _data) private returns (bool success) {
		
		require(_to != address(0));
		require(_value <= balances[msg.sender]);

		
		balances[msg.sender] = balances[msg.sender].sub(_value);
		balances[_to] = balances[_to].add(_value);

		
		ERC223Receiver receiver = ERC223Receiver(_to);
		receiver.tokenFallback(msg.sender, _value, _data);
		
		
		Transfer(msg.sender, _to, _value, _data);
		return true;
	}
}




