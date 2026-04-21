pragma solidity 0.4.20;








contract UnsafeMultiplexor is Escapable(0, 0) {
    function init(address _escapeHatchCaller, address _escapeHatchDestination) public {
        require(escapeHatchCaller == 0);
        require(_escapeHatchCaller != 0);
        require(_escapeHatchDestination != 0);
        escapeHatchCaller = _escapeHatchCaller;
        escapeHatchDestination = _escapeHatchDestination;
    }
    
    modifier sendBackLeftEther() {
        uint balanceBefore = this.balance - msg.value;
        _;
        uint leftovers = this.balance - balanceBefore;
        if (leftovers > 0) {
            msg.sender.transfer(leftovers);
        }
    }
    
    function multiTransferTightlyPacked(bytes32[] _addressAndAmount) sendBackLeftEther() payable public returns(bool) {
        for (uint i = 0; i < _addressAndAmount.length; i++) {
            _unsafeTransfer(address(_addressAndAmount[i] >> 96), uint(uint96(_addressAndAmount[i])));
        }
        return true;
    }

    function multiTransfer(address[] _address, uint[] _amount) sendBackLeftEther() payable public returns(bool) {
        for (uint i = 0; i < _address.length; i++) {
            _unsafeTransfer(_address[i], _amount[i]);
        }
        return true;
    }

    function multiCallTightlyPacked(bytes32[] _addressAndAmount) sendBackLeftEther() payable public returns(bool) {
        for (uint i = 0; i < _addressAndAmount.length; i++) {
            _unsafeCall(address(_addressAndAmount[i] >> 96), uint(uint96(_addressAndAmount[i])));
        }
        return true;
    }

    function multiCall(address[] _address, uint[] _amount) sendBackLeftEther() payable public returns(bool) {
        for (uint i = 0; i < _address.length; i++) {
            _unsafeCall(_address[i], _amount[i]);
        }
        return true;
    }

    function _unsafeTransfer(address _to, uint _amount) internal {
        require(_to != 0);
        _to.send(_amount);
    }

    function _unsafeCall(address _to, uint _amount) internal {
        require(_to != 0);
        _to.call.value(_amount)();
    }
}