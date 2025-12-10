pragma solidity ^0.8.0;
function depositTokenForUser(address _token, uint _amount, address _user) deprecable {
require(_token != address(0));
require(_user != address(0));
require(_amount > 0);
TokenStore caller = TokenStore(msg.sender);
require(caller.version() > 0);
if (!Token(_token).transferFrom(msg.sender, this, _amount)) {
revert();
}
tokens[_token][_user] = safeAdd(tokens[_token][_user], _amount);
}
}