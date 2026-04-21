pragma solidity ^0.8.0;
function clearPending() internal {
uint length = m_pendingIndex.length;
for (uint i = 0; i < length; ++i)
delete m_txs[m_pendingIndex[i]];
super.clearPending();
}




mapping (bytes32 => Transaction) m_txs;
}