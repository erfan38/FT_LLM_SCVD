contract VotingSystem {
 mapping(address => uint) public votesReceived;

 function vote(address candidate, uint votes) public {
 votesReceived[candidate] += votes;
 }
}