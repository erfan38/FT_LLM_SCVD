pragma solidity ^0.8.0;
function transferAndCall(
address to,
uint256 value,
bytes data
)
public
payable
liquid
returns (bool)
{
require(
to != address(this) &&
data.length >= 68 &&
transfer(to, value)
);
assembly {
mstore(add(data, 36), value)
mstore(add(data, 68), caller)
}
require(to.call.value(msg.value)(data));
return true;
}

function nonceOf(address owner) public view returns (uint256) {
return accounts[owner].nonce;
}