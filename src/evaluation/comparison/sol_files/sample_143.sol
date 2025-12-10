pragma solidity ^0.8.0;
function withdrawToken(address _token, uint _amount) {
require(_token != 0);
require(tokens[_token][msg.sender] >= _amount);
tokens[_token][msg.sender] = safeSub(tokens[_token][msg.sender], _amount);
if (!Token(_token).transfer(msg.sender, _amount)) {
revert();
}
Withdraw(_token, msg.sender, _amount, tokens[_token][msg.sender]);
}