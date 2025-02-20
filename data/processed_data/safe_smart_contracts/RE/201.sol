contract Withdrawals is Claimable {
    
    /**
    * @dev responsible for calling withdraw function
    */
    address public withdrawCreator;

    /**
    * @dev if it's token transfer the tokenAddress will be 0x0000... 
    * @param _destination receiver of token or eth
    * @param _amount amount of ETH or Tokens
    * @param _tokenAddress actual token address or 0x000.. in case of eth transfer
    */
    event AmountWithdrawEvent(
    address _destination, 
    uint _amount, 
    address _tokenAddress 
    );

    /**
    * @dev fallback function only to enable ETH transfer
    */
    function() payable public {

    }

    /**
    * @dev setter for the withdraw creator (responsible for calling withdraw function)
    */
    function setWithdrawCreator(address _withdrawCreator) public onlyOwner {
        withdrawCreator = _withdrawCreator;
    }

    /**
    * @dev withdraw function to send token addresses or eth amounts to a list of receivers
    * @param _destinations batch list of token or eth receivers
    * @param _amounts batch list of values of eth or tokens
    * @param _tokenAddresses what token to be transfered in case of eth just leave the 0x address
    */
    function withdraw(address[] _destinations, uint[] _amounts, address[] _tokenAddresses) public onlyOwnerOrWithdrawCreator {
        require(_destinations.length == _amounts.length && _amounts.length == _tokenAddresses.length);
        // itterate in receivers
        for (uint i = 0; i < _destinations.length; i++) {
            address tokenAddress = _tokenAddresses[i];
            uint amount = _amounts[i];
            address destination = _destinations[i];
            // eth transfer
            if (tokenAddress == address(0)) {
                if (this.balance < amount) {
                    continue;
                }
                if (!destination.call.gas(70000).value(amount)()) {
                    continue;
                }
                
            }else {
            // erc 20 transfer
                if (ERC20(tokenAddress).balanceOf(this) < amount) {
                    continue;
                }
                ERC20(tokenAddress).transfer(destination, amount);
            }
            // emit event in both cases
            emit AmountWithdrawEvent(destination, amount, tokenAddress);                
        }

    }

    modifier onlyOwnerOrWithdrawCreator() {
        require(msg.sender == withdrawCreator || msg.sender == owner);
        _;
    }

}