pragma solidity ^0.4.24; 







contract AionClient {
    
    address private AionAddress;

    constructor(address addraion) public{
        AionAddress = addraion;
    }

    
    function execfunct(address to, uint256 value, uint256 gaslimit, bytes data) external returns(bool) {
        require(msg.sender == AionAddress);
        return to.call.value(value).gas(gaslimit)(data);

    }
    

    function () payable public {}

}





library SafeMath {
  
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {return 0;}
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }

  
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

  
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        return a - b;
    }

  
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }

}






