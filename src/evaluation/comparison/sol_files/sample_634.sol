pragma solidity ^0.8.0;
function activate_kill_switch(string password) {

if (msg.sender != developer && sha3(password) != password_hash) throw;

kill_switch = true;
}