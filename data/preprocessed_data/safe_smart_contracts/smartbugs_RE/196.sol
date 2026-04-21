pragma solidity 0.4.25;




contract PullPaymentCapable {
    uint256 private totalBalance;
    mapping(address => uint256) private payments;

    event LogPaymentReceived(address indexed dest, uint256 amount);

    constructor() public {
        if (0 < address(this).balance) {
            asyncSend(msg.sender, address(this).balance);
        }
    }

    
    function asyncSend(address dest, uint256 amount) internal {
        if (amount > 0) {
            totalBalance += amount;
            payments[dest] += amount;
            emit LogPaymentReceived(dest, amount);
        }
    }

    function getTotalBalance()
        view public
        returns (uint256) {
        return totalBalance;
    }

    function getPaymentOf(address beneficiary) 
        view public
        returns (uint256) {
        return payments[beneficiary];
    }

    
    function withdrawPayments()
        external 
        returns (bool success) {
        uint256 payment = payments[msg.sender];
        payments[msg.sender] = 0;
        totalBalance -= payment;
        require(msg.sender.call.value(payment)());
        success = true;
    }

    function fixBalance()
        public
        returns (bool success);

    function fixBalanceInternal(address dest)
        internal
        returns (bool success) {
        if (totalBalance < address(this).balance) {
            uint256 amount = address(this).balance - totalBalance;
            payments[dest] += amount;
            emit LogPaymentReceived(dest, amount);
        }
        return true;
    }
}

