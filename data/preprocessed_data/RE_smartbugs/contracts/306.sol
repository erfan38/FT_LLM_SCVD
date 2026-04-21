pragma solidity ^0.5.3;

library SafeMath {
    


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        
        
        
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
        require(b > 0);
        uint256 c = a / b;
        

        return c;
    }

    


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    


    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    



    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

contract SuperOwner is Ownable{
    event Execution(address destination,uint value,bytes data);
    event ExecutionFailure(address destination,uint value);

    



    function executeTransaction(
        address payable destination,
        uint value,
        bytes memory data
    ) public onlyOwner {
        (
            bool executed,
            bytes memory responseData
        ) = destination.call.value(value)(data);
        if (executed) {
            emit Execution(destination,value,responseData);
        } else {
            emit ExecutionFailure(destination,value);
        }
    }
}
