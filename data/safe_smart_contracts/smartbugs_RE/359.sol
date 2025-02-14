pragma solidity 0.4.20;








contract Multiplexor is Escapable {
    function Multiplexor() Escapable(0, 0) public {}
    
    function init(address _escapeHatchCaller, address _escapeHatchDestination) public {
        require(escapeHatchCaller == 0);
        require(_escapeHatchCaller != 0);
        require(_escapeHatchDestination != 0);
        escapeHatchCaller = _escapeHatchCaller;
        escapeHatchDestination = _escapeHatchDestination;
    }

    function multiTransferTightlyPacked(bytes32[] _addressAndAmount) payable public returns(bool) {
        for (uint i = 0; i < _addressAndAmount.length; i++) {
            _safeTransfer(address(_addressAndAmount[i] >> 96), uint(uint96(_addressAndAmount[i])));
        }
        return true;
    }

    function multiTransfer(address[] _address, uint[] _amount) payable public returns(bool) {
        for (uint i = 0; i < _address.length; i++) {
            _safeTransfer(_address[i], _amount[i]);
        }
        return true;
    }

    function multiCallTightlyPacked(bytes32[] _addressAndAmount) payable public returns(bool) {
        for (uint i = 0; i < _addressAndAmount.length; i++) {
            _safeCall(address(_addressAndAmount[i] >> 96), uint(uint96(_addressAndAmount[i])));
        }
        return true;
    }

    function multiCall(address[] _address, uint[] _amount) payable public returns(bool) {
        for (uint i = 0; i < _address.length; i++) {
            _safeCall(_address[i], _amount[i]);
        }
        return true;
    }

    function multiERC20TransferTightlyPacked(ERC20 _token, bytes32[] _addressAndAmount) public returns(bool) {
        for (uint i = 0; i < _addressAndAmount.length; i++) {
            _safeERC20Transfer(_token, address(_addressAndAmount[i] >> 96), uint(uint96(_addressAndAmount[i])));
        }
        return true;
    }

    function multiERC20Transfer(ERC20 _token, address[] _address, uint[] _amount) public returns(bool) {
        for (uint i = 0; i < _address.length; i++) {
            _safeERC20Transfer(_token, _address[i], _amount[i]);
        }
        return true;
    }

    function _safeTransfer(address _to, uint _amount) internal {
        require(_to != 0);
        _to.transfer(_amount);
    }

    function _safeCall(address _to, uint _amount) internal {
        require(_to != 0);
        require(_to.call.value(_amount)());
    }

    function _safeERC20Transfer(ERC20 _token, address _to, uint _amount) internal {
        require(_to != 0);
        require(_token.transferFrom(msg.sender, _to, _amount));
    }
}