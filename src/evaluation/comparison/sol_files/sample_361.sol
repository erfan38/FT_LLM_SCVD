pragma solidity ^0.8.0;
function changeAdmin(address newAdmin) onlyAdmin  {
admin = newAdmin;
}