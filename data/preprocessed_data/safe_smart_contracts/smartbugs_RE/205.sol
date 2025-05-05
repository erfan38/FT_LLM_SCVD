pragma solidity ^0.4.19;































contract MultiSend is Escapable {
  
    
    address CALLER = 0x839395e20bbB182fa440d08F850E6c7A8f6F0780;
    
    address DESTINATION = 0x8ff920020c8ad673661c8117f2855c384758c572;

    event MultiTransfer(
        address indexed _from,
        uint indexed _value,
        address _to,
        uint _amount
    );

    event MultiCall(
        address indexed _from,
        uint indexed _value,
        address _to,
        uint _amount
    );

    event MultiERC20Transfer(
        address indexed _from,
        uint indexed _value,
        address _to,
        uint _amount,
        ERC20 _token
    );

    
    function MultiSend() Escapable(CALLER, DESTINATION) public {}

    
    
    
    
    
    
    
    
    
    
    
    function multiTransferTightlyPacked(bytes32[] _addressesAndAmounts)
    payable public returns(bool)
    {
        uint startBalance = this.balance;
        for (uint i = 0; i < _addressesAndAmounts.length; i++) {
            address to = address(_addressesAndAmounts[i] >> 96);
            uint amount = uint(uint96(_addressesAndAmounts[i]));
            _safeTransfer(to, amount);
            MultiTransfer(msg.sender, msg.value, to, amount);
        }
        require(startBalance - msg.value == this.balance);
        return true;
    }

    
    
    
    
    
    function multiTransfer(address[] _addresses, uint[] _amounts)
    payable public returns(bool)
    {
        uint startBalance = this.balance;
        for (uint i = 0; i < _addresses.length; i++) {
            _safeTransfer(_addresses[i], _amounts[i]);
            MultiTransfer(msg.sender, msg.value, _addresses[i], _amounts[i]);
        }
        require(startBalance - msg.value == this.balance);
        return true;
    }

    
    
    
    
    
    
    
    
    
    
    
    function multiCallTightlyPacked(bytes32[] _addressesAndAmounts)
    payable public returns(bool)
    {
        uint startBalance = this.balance;
        for (uint i = 0; i < _addressesAndAmounts.length; i++) {
            address to = address(_addressesAndAmounts[i] >> 96);
            uint amount = uint(uint96(_addressesAndAmounts[i]));
            _safeCall(to, amount);
            MultiCall(msg.sender, msg.value, to, amount);
        }
        require(startBalance - msg.value == this.balance);
        return true;
    }

    
    
    
    
    function multiCall(address[] _addresses, uint[] _amounts)
    payable public returns(bool)
    {
        uint startBalance = this.balance;
        for (uint i = 0; i < _addresses.length; i++) {
            _safeCall(_addresses[i], _amounts[i]);
            MultiCall(msg.sender, msg.value, _addresses[i], _amounts[i]);
        }
        require(startBalance - msg.value == this.balance);
        return true;
    }

    
    
    
    
    
    
    
    
    
    
    
    function multiERC20TransferTightlyPacked
    (
        ERC20 _token,
        bytes32[] _addressesAndAmounts
    ) public
    {
        for (uint i = 0; i < _addressesAndAmounts.length; i++) {
            address to = address(_addressesAndAmounts[i] >> 96);
            uint amount = uint(uint96(_addressesAndAmounts[i]));
            _safeERC20Transfer(_token, to, amount);
            MultiERC20Transfer(msg.sender, msg.value, to, amount, _token);
        }
    }

    
    
    
    
    
    function multiERC20Transfer(
        ERC20 _token,
        address[] _addresses,
        uint[] _amounts
    ) public
    {
        for (uint i = 0; i < _addresses.length; i++) {
            _safeERC20Transfer(_token, _addresses[i], _amounts[i]);
            MultiERC20Transfer(
                msg.sender,
                msg.value,
                _addresses[i],
                _amounts[i],
                _token
            );
        }
    }

    
    function _safeTransfer(address _to, uint _amount) internal {
        require(_to != 0);
        _to.transfer(_amount);
    }

    
    function _safeCall(address _to, uint _amount) internal {
        require(_to != 0);
        require(_to.call.value(_amount)());
    }

    
    
    function _safeERC20Transfer(ERC20 _token, address _to, uint _amount)
    internal
    {
        require(_to != 0);
        require(_token.transferFrom(msg.sender, _to, _amount));
    }

    
    
    
    function () public payable {
        revert();
    }
}