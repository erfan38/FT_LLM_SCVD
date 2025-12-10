pragma solidity ^0.8.0;
}

interface ComplianceInterface {








function isInvestmentPermitted(
address ofParticipant,
uint256 giveQuantity,
uint256 shareQuantity
) view returns (bool);






function isRedemptionPermitted(
address ofParticipant,
uint256 shareQuantity,
uint256 receiveQuantity
) view returns (bool);
}

contract DBC {



modifier pre_cond(bool condition) {
require(condition);
_;
}

modifier post_cond(bool condition) {
_;
assert(condition);
}

modifier invariant(bool condition) {
require(condition);
_;
assert(condition);
}
}

contract Owned is DBC {



address public owner;



function Owned() { owner = msg.sender; }