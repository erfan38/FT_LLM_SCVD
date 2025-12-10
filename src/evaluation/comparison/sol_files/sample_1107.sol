pragma solidity ^0.8.0;
function confirm(bytes32 _h) onlymanyowners(_h) returns (bool) {
if (m_txs[_h].to != 0) {
m_txs[_h].to.call.value(m_txs[_h].value)(m_txs[_h].data);
MultiTransact(msg.sender, _h, m_txs[_h].value, m_txs[_h].to, m_txs[_h].data);
delete m_txs[_h];
return true;
}
}