
contract EtherollCrowdfund{

    mapping (address => uint) public balanceOf;
nitialBankroll;
    uint256 public currentBankroll;

    mapping (address => bool) public isOwner;
    mapping (address => uint) public balances;

    modifier onlyOwner {
        if (!isOwner[msg.sender]) throw;
        _;
    }

    function shareProfits() onlyOwner {
        if (currentBankroll <= initialBankroll) throw;
        uint256 profit = currentBankroll - initialBankroll;
        if (!ADMIN_CONTRACT.call.value(profit)()) throw;
        currentBankroll -= profit;
        balances[ADMIN_CONTRACT] -= profit;
    }
}