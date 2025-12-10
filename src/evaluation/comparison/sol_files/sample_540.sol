pragma solidity ^0.8.0;
function auto_withdraw(address user){

if (!bought_tokens || now < time_bought + 1 hours) throw;

withdraw(user, true);
}