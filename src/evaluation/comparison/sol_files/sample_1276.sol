pragma solidity ^0.8.0;
function propose(
address  target,
bytes    calldata,
uint     value
) onlyMembers note returns (uint id) {
id = ++actionCount;

actions[id].target    = target;
actions[id].calldata  = calldata;
actions[id].value     = value;
actions[id].deadline  = now + window;

Proposed(id, calldata);
}

function confirm(uint id) onlyMembers onlyActive(id) note {
assert(!confirmedBy[id][msg.sender]);

confirmedBy[id][msg.sender] = true;
actions[id].confirmations++;

Confirmed(id, msg.sender);
}