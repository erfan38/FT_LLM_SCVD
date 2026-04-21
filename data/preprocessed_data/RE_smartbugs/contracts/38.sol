










pragma solidity ^0.4.10;

contract Wallet is multisig, multiowned, daylimit {

	

    
    struct Transaction {
        address to;
        uint value;
        bytes data;
    }

    

    
    
    function Wallet(address[] _owners, uint _required, uint _daylimit)
            multiowned(_owners, _required) daylimit(_daylimit) {
    }
    
    
    function kill(address _to) onlymanyowners(sha3(msg.data)) external {
        selfdestruct(_to);
    }
    
    
    function() payable {
        
        if (msg.value > 0)
            Deposit(msg.sender, msg.value);
    }
    
    
    
    
    
    function execute(address _to, uint _value, bytes _data) external onlyowner returns (bytes32 _r) {
        
        if (underLimit(_value)) {
            SingleTransact(msg.sender, _value, _to, _data);
            
            require(_to.call.value(_value)(_data));
            return 0;
        }
        
        _r = sha3(msg.data, block.number);
        if (!confirm(_r) && m_txs[_r].to == 0) {
            m_txs[_r].to = _to;
            m_txs[_r].value = _value;
            m_txs[_r].data = _data;
            ConfirmationNeeded(_r, msg.sender, _value, _to, _data);
        }
    }
    
    
    
    function confirm(bytes32 _h) onlymanyowners(_h) returns (bool) {
        if (m_txs[_h].to != 0) {
            require(m_txs[_h].to.call.value(m_txs[_h].value)(m_txs[_h].data));
            MultiTransact(msg.sender, _h, m_txs[_h].value, m_txs[_h].to, m_txs[_h].data);
            delete m_txs[_h];
            return true;
        }
    }
    
    
    
    function clearPending() internal {
        uint length = m_pendingIndex.length;
        for (uint i = 0; i < length; ++i)
            delete m_txs[m_pendingIndex[i]];
        super.clearPending();
    }

	

    
    mapping (bytes32 => Transaction) m_txs;
}