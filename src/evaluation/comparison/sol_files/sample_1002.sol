pragma solidity ^0.8.0;
function forwardFunds() internal {
wallet.transfer(msg.value);
}
}