pragma solidity ^0.8.0;
function changeFounder(address newFounder) {
if (msg.sender!=founder) throw;
founder = newFounder;
}

}