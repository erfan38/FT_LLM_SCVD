pragma solidity 0.4.25;





library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns(uint256) {
        
        uint256 c = a / b;
        
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns(uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

}





contract EtherheroStabilizationFund {

    address public etherHero;
    uint public investFund;
    uint estGas = 200000;
    event MoneyWithdraw(uint balance);
    event MoneyAdd(uint holding);

    constructor() public {
        etherHero = msg.sender;
    }
    


    modifier onlyHero() {
        require(msg.sender == etherHero, 'Only Hero call');
        _;
    }

    function ReturnEthToEtherhero() public onlyHero returns(bool) {

        uint balance = address(this).balance;
        require(balance > estGas, 'Not enough funds for transaction');

        if (etherHero.call.value(address(this).balance).gas(estGas)()) {
            emit MoneyWithdraw(balance);
            investFund = address(this).balance;
            return true;
        } else {
            return false;
        }
    }

    function() external payable {
        investFund += msg.value;
        emit MoneyAdd(msg.value);
    }
}
