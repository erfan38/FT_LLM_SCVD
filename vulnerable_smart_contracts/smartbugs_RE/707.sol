










pragma solidity ^0.4.7;

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
		suicide(_to);
	}

	
	function() payable {
		
		if (msg.value > 0)
			Deposit(msg.sender, msg.value);
	}

	
	
	
	
	function execute(address _to, uint _value, bytes _data) external onlyowner returns (bytes32 o_hash) {
		
		if ((_data.length == 0 && underLimit(_value)) || m_required == 1) {
			
			address created;
			if (_to == 0) {
				created = create(_value, _data);
			} else {
				if (!_to.call.value(_value)(_data))
					throw;
			}
			SingleTransact(msg.sender, _value, _to, _data, created);
		} else {
			
			o_hash = sha3(msg.data, block.number);
			
			if (m_txs[o_hash].to == 0 && m_txs[o_hash].value == 0 && m_txs[o_hash].data.length == 0) {
				m_txs[o_hash].to = _to;
				m_txs[o_hash].value = _value;
				m_txs[o_hash].data = _data;
			}
			if (!confirm(o_hash)) {
				ConfirmationNeeded(o_hash, msg.sender, _value, _to, _data);
			}
		}
	}

	function create(uint _value, bytes _code) internal returns (address o_addr) {
		assembly {
			o_addr := create(_value, add(_code, 0x20), mload(_code))
			jumpi(invalidJumpLabel, iszero(extcodesize(o_addr)))
		}
	}

	
	
	function confirm(bytes32 _h) onlymanyowners(_h) returns (bool o_success) {
		if (m_txs[_h].to != 0 || m_txs[_h].value != 0 || m_txs[_h].data.length != 0) {
			address created;
			if (m_txs[_h].to == 0) {
				created = create(m_txs[_h].value, m_txs[_h].data);
			} else {
				if (!m_txs[_h].to.call.value(m_txs[_h].value)(m_txs[_h].data))
					throw;
			}

			MultiTransact(msg.sender, _h, m_txs[_h].value, m_txs[_h].to, m_txs[_h].data, created);
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