pragma solidity ^ 0.4.17;



















library SafeMath {
	function mul(uint256 a, uint256 b) internal constant returns(uint256) {
		uint256 c = a * b;
		assert(a == 0 || c / a == b);
		return c;
	}

	function div(uint256 a, uint256 b) internal constant returns(uint256) {
		
		uint256 c = a / b;
		
		return c;
	}

	function sub(uint256 a, uint256 b) internal constant returns(uint256) {
		assert(b <= a);
		return a - b;
	}

	function add(uint256 a, uint256 b) internal constant returns(uint256) {
		uint256 c = a + b;
		assert(c >= a);
		return c;
	}
}



contract TestProcess {
    Noxon main;
    
    function TestProcess() payable {
        main = new Noxon();
    }
   
    function () payable {
        
    }
     
    function init() returns (uint) {
       
        if (!main.NoxonInit.value(12)()) throw;    
        if (!main.call.value(24)()) revert(); 
 
        assert(main.balanceOf(address(this)) == 2); 
        
        if (main.call.value(23)()) revert(); 
        assert(main.balanceOf(address(this)) == 2); 
    }
    
    
    
    function test1() returns (uint) {
        if (!main.call.value(26)()) revert(); 
        assert(main.balanceOf(address(this)) == 3); 
        assert(main.emissionPrice() == 24); 
        return main.balance;
    }
    
    function test2() returns (uint){
        if (!main.call.value(40)()) revert(); 
        assert(main.balanceOf(address(this)) == 4); 
        
        
    } 
    
    function test3() {
        if (!main.transfer(address(main),2)) revert();
        assert(main.burnPrice() == 14);
    } 
    
}