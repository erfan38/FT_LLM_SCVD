pragma solidity ^0.8.0;
function subWithdrawFor(address _from, address _to) internal returns (bool) {
Sub storage sub = subs[_from][_to];

if (sub.startTime > 0 && sub.startTime < block.timestamp && sub.payPerWeek > 0) {
uint weekElapsed = (now.sub(sub.lastWithdrawTime)).div(7 days);
uint amount = weekElapsed.mul(sub.payPerWeek);
if (weekElapsed > 0 && _balanceOf[_from] >= amount) {
subs[_from][_to].lastWithdrawTime = block.timestamp;
_balanceOf[_from] = _balanceOf[_from].sub(amount);
_balanceOf[_to] = _balanceOf[_to].add(amount);
emit Transfer(_from, _to, amount);
return true;
}
}
return false;
}