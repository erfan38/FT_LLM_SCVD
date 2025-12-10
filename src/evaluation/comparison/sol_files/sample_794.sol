pragma solidity ^0.8.0;
function halt() onlyAdmin {
halted = true;
}