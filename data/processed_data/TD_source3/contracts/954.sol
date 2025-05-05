contract SimpleDAO {
 mapping(address => uint) public balances;
 uint public proposalExpirationTime;
 bool public proposalPassed;

 constructor(uint _proposalDuration) {
 proposalExpirationTime = block.number + _proposalDuration;
 }

 function vote(bool inFavor) public {
 require(block.number <= proposalExpirationTime, "Voting has ended");
 // Voting logic here
 }

 function executeProposal() public {
 require(block.number > proposalExpirationTime, "Voting is still ongoing");
 require(proposalPassed, "Proposal did not pass");
 // Execute proposal logic here
 }
}