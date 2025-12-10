contract VotingRecord {
 mapping(address => uint) lastVoteTime;

 function vote(uint proposalId) public {
 require(block.timestamp > lastVoteTime[msg.sender] + 1 days, "Can only vote once per day");
 lastVoteTime[msg.sender] = block.timestamp;
 // voting logic here
 }
}