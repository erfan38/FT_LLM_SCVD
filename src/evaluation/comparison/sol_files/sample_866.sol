pragma solidity ^0.8.0;
function claim_bounty(){

if (bought_tokens) return;

if (kill_switch) return;

if (now < earliest_buy_time) return;

if (sale == 0x0) throw;

bought_tokens = true;

time_bought = now;



if(!sale.call.value(this.balance - bounty)()) throw;

msg.sender.transfer(bounty);
}