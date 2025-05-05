contract AbstractPaymentEscrow is Ownable {

    address public wallet;

    mapping (uint => uint) public deposits;

    event Payment(address indexed _customer, uint indexed _projectId, uint value);
    event Withdraw(address indexed _wallet, uint value);

    function withdrawFunds() public;

    /**
     * @dev Change the wallet
     * @param _wallet address of the wallet where fees will be transfered when spent
     */
    function changeWallet(address _wallet)
        public
        onlyOwner()
    {
        wallet = _wallet;
    }

    /**
     * @dev Get the amount deposited for the provided project, returns 0 if there's no deposit for that project or the amount in wei
     * @param _projectId The id of the project
     * @return 0 if there's either no deposit for _projectId, otherwise returns the deposited amount in wei
     */
    function getDeposit(uint _projectId)
        public
        constant
        returns (uint)
    {
        return deposits[_projectId];
    }
}

