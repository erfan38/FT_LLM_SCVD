contract EtherTreasuryInterface {
    function withdraw(address _to, uint _value) returns(bool);
    function withdrawWithReference(address _to, uint _value, string _reference) returns(bool);
}

contract OpenDollar is Asset, AmbiEnabled {
    uint public txGasPriceLimit = 21000000000;
    uint public refundGas = 40000;
    uint public transferCallGas = 21000;
    uint public transferWithReferenceCallGas = 21000;
    uint public transferFromCallGas = 21000;
    uint public transferFromWithReferenceCallGas = 21000;
    uint public transferToICAPCallGas = 21000;
    uint public transferToICAPWithReferenceCallGas = 21000;
    uint public transferFromToICAPCallGas = 21000;
    uint public transferFromToICAPWithReferenceCallGas = 21000;
    uint public approveCallGas = 21000;
    uint public forwardCallGas = 21000;
    uint public setCosignerCallGas = 21000;
    EtherTreasuryInterface public treasury;
    mapping(uint32 => address) public allowedForwards;

    function updateRefundGas() checkAccess("setup") returns(uint) {
        uint startGas = msg.gas;
        uint refund = (startGas - msg.gas + refundGas) * tx.gasprice;
        if (tx.gasprice > txGasPriceLimit) {
            return 0;
        }
        if (!_refund(1)) {
            return 0;
        }
        refundGas = startGas - msg.gas;
        return refundGas;
    }

    function setOperationsCallGas
        (
            uint _transfer,
            uint _transferFrom,
            uint _transferToICAP,
            uint _transferFromToICAP,
            uint _transferWithReference,
            uint _transferFromWithReference,
            uint _transferToICAPWithReference,
            uint _transferFromToICAPWithReference,
            uint _approve,
            uint _forward,
            uint _setCosigner
        ) checkAccess("setup") returns(bool)
    {
        transferCallGas = _transfer;
        transferFromCallGas = _transferFrom;
        transferToICAPCallGas = _transferToICAP;
        transferFromToICAPCallGas = _transferFromToICAP;
        transferWithReferenceCallGas = _transferWithReference;
        transferFromWithReferenceCallGas = _transferFromWithReference;
        transferToICAPWithReferenceCallGas = _transferToICAPWithReference;
        transferFromToICAPWithReferenceCallGas = _transferFromToICAPWithReference;
        approveCallGas = _approve;
        forwardCallGas = _forward;
        setCosignerCallGas = _setCosigner;
        return true;
    }

    function setupTreasury(address _treasury, uint _txGasPriceLimit) checkAccess("admin") returns(bool) {
        if (_txGasPriceLimit == 0) {
            return false;
        }
        treasury = EtherTreasuryInterface(_treasury);
        txGasPriceLimit = _txGasPriceLimit;
        if (msg.value > 0 && !address(treasury).send(msg.value)) {
            throw;
        }
        return true;
    }

    function setForward(bytes4 _msgSig, address _forward) checkAccess("admin") returns(bool) {
        allowedForwards[uint32(_msgSig)] = _forward;
        return true;
    }

    function _stringGas(string _string) constant internal returns(uint) {
        return bytes(_string).length * 75;
    }

    function _applyRefund(uint _startGas) internal returns(bool) {
        if (tx.gasprice > txGasPriceLimit) {
            return false;
        }
        uint refund = (_startGas - msg.gas + refundGas) * tx.gasprice;
        return _refund(refund);
    }

    function _refund(uint _value) internal returns(bool) {
        return treasury.withdraw(tx.origin, _value);
    }

    function _transfer(address _to, uint _value) internal returns(bool, bool) {
        uint startGas = msg.gas + transferCallGas;
        if (!multiAsset.proxyTransferWithReference(_to, _value, symbol, "")) {
            return (false, false);
        }
        return (true, _applyRefund(startGas));
    }

    function _transferFrom(address _from, address _to, uint _value) internal returns(bool, bool) {
        uint startGas = msg.gas + transferFromCallGas;
        if (!multiAsset.proxyTransferFromWithReference(_from, _to, _value, symbol, "")) {
            return (false, false);
        }
        return (true, _applyRefund(startGas));
    }

    function _transferToICAP(bytes32 _icap, uint _value) internal returns(bool, bool) {
        uint startGas = msg.gas + transferToICAPCallGas;
        if (!multiAsset.proxyTransferToICAPWithReference(_icap, _value, "")) {
            return (false, false);
        }
        return (true, _applyRefund(startGas));
    }

    function _transferFromToICAP(address _from, bytes32 _icap, uint _value) internal returns(bool, bool) {
        uint startGas = msg.gas + transferFromToICAPCallGas;
        if (!multiAsset.proxyTransferFromToICAPWithReference(_from, _icap, _value, "")) {
            return (false, false);
        }
        return (true, _applyRefund(startGas));
    }

    function _transferWithReference(address _to, uint _value, string _reference) internal returns(bool, bool) {
        uint startGas = msg.gas + transferWithReferenceCallGas + _stringGas(_reference);
        if (!multiAsset.proxyTransferWithReference(_to, _value, symbol, _reference)) {
            return (false, false);
        }
        return (true, _applyRefund(startGas));
    }

    function _transferFromWithReference(address _from, address _to, uint _value, string _reference) internal returns(bool, bool) {
        uint startGas = msg.gas + transferFromWithReferenceCallGas + _stringGas(_reference);
        if (!multiAsset.proxyTransferFromWithReference(_from, _to, _value, symbol, _reference)) {
            return (false, false);
        }
        return (true, _applyRefund(startGas));
    }

    function _transferToICAPWithReference(bytes32 _icap, uint _value, string _reference) internal returns(bool, bool) {
        uint startGas = msg.gas + transferToICAPWithReferenceCallGas + _stringGas(_reference);
        if (!multiAsset.proxyTransferToICAPWithReference(_icap, _value, _reference)) {
            return (false, false);
        }
        return (true, _applyRefund(startGas));
    }

    function _transferFromToICAPWithReference(address _from, bytes32 _icap, uint _value, string _reference) internal returns(bool, bool) {
        uint startGas = msg.gas + transferFromToICAPWithReferenceCallGas + _stringGas(_reference);
        if (!multiAsset.proxyTransferFromToICAPWithReference(_from, _icap, _value, _reference)) {
            return (false, false);
        }
        return (true, _applyRefund(startGas));
    }

    function _approve(address _spender, uint _value) internal returns(bool, bool) {
        uint startGas = msg.gas + approveCallGas;
        if (!multiAsset.proxyApprove(_spender, _value, symbol)) {
            return (false, false);
        }
        return (true, _applyRefund(startGas));
    }

    function _setCosignerAddress(address _cosigner) internal returns(bool, bool) {
        uint startGas = msg.gas + setCosignerCallGas;
        if (!multiAsset.proxySetCosignerAddress(_cosigner, symbol)) {
            return (false, false);
        }
        return (true, _applyRefund(startGas));
    }

    function transfer(address _to, uint _value) returns(bool) {
        bool success;
        (success,) = _transfer(_to, _value);
        return success;
    }

    function transferFrom(address _from, address _to, uint _value) returns(bool) {
        bool success;
        (success,) = _transferFrom(_from, _to, _value);
        return success;
    }

    function transferToICAP(bytes32 _icap, uint _value) returns(bool) {
        bool success;
        (success,) = _transferToICAP(_icap, _value);
        return success;
    }

    function transferFromToICAP(address _from, bytes32 _icap, uint _value) returns(bool) {
        bool success;
        (success,) = _transferFromToICAP(_from, _icap, _value);
        return success;
    }

    function transferWithReference(address _to, uint _value, string _reference) returns(bool) {
        bool success;
        (success,) = _transferWithReference(_to, _value, _reference);
        return success;
    }

    function transferFromWithReference(address _from, address _to, uint _value, string _reference) returns(bool) {
        bool success;
        (success,) = _transferFromWithReference(_from, _to, _value, _reference);
        return success;
    }

    function transferToICAPWithReference(bytes32 _icap, uint _value, string _reference) returns(bool) {
        bool success;
        (success,) = _transferToICAPWithReference(_icap, _value, _reference);
        return success;
    }

    function transferFromToICAPWithReference(address _from, bytes32 _icap, uint _value, string _reference) returns(bool) {
        bool success;
        (success,) = _transferFromToICAPWithReference(_from, _icap, _value, _reference);
        return success;
    }

    function approve(address _spender, uint _value) returns(bool) {
        bool success;
        (success,) = _approve(_spender, _value);
        return success;
    }

    function setCosignerAddress(address _cosigner) returns(bool) {
        bool success;
        (success,) = _setCosignerAddress(_cosigner);
        return success;
    }

    function checkTransfer(address _to, uint _value) constant returns(bool, bool) {
        return _transfer(_to, _value);
    }

    function checkTransferFrom(address _from, address _to, uint _value) constant returns(bool, bool) {
        return _transferFrom(_from, _to, _value);
    }

    function checkTransferToICAP(bytes32 _icap, uint _value) constant returns(bool, bool) {
        return _transferToICAP(_icap, _value);
    }

    function checkTransferFromToICAP(address _from, bytes32 _icap, uint _value) constant returns(bool, bool) {
        return _transferFromToICAP(_from, _icap, _value);
    }

    function checkTransferWithReference(address _to, uint _value, string _reference) constant returns(bool, bool) {
        return _transferWithReference(_to, _value, _reference);
    }

    function checkTransferFromWithReference(address _from, address _to, uint _value, string _reference) constant returns(bool, bool) {
        return _transferFromWithReference(_from, _to, _value, _reference);
    }

    function checkTransferToICAPWithReference(bytes32 _icap, uint _value, string _reference) constant returns(bool, bool) {
        return _transferToICAPWithReference(_icap, _value, _reference);
    }

    function checkTransferFromToICAPWithReference(address _from, bytes32 _icap, uint _value, string _reference) constant returns(bool, bool) {
        return _transferFromToICAPWithReference(_from, _icap, _value, _reference);
    }

    function checkApprove(address _spender, uint _value) constant returns(bool, bool) {
        return _approve(_spender, _value);
    }

    function checkSetCosignerAddress(address _cosigner) constant returns(bool, bool) {
        return _setCosignerAddress(_cosigner);
    }

    function _forward(address _to, bytes _data) internal returns(bool) {
        uint startGas = msg.gas + forwardCallGas + (_data.length * 50);
        if (_to == 0x0) {
            return false;
        }
        _to.call.value(msg.value)(_data);
        return _applyRefund(startGas);
    }

    function () returns(bool) {
        return _forward(allowedForwards[uint32(msg.sig)], msg.data);
    }
}