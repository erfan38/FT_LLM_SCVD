pragma solidity ^0.8.0;
function removeMember(address targetMember) onlyOwner {
if (memberId[targetMember] == 0) throw;

uint256 targetId = memberId[targetMember];
uint256 lastId   = members.length - 1;


Member memory moved    = members[lastId];
members[targetId]      = moved;
memberId[moved.member] = targetId;


memberId[targetMember] = 0;
delete members[lastId];
--members.length;

MembershipChanged(targetMember, false);
}







function changeVotingRules(
uint256 minimumQuorumForProposals,
uint256 minutesForDebate,
int256  marginOfVotesForMajority
)
onlyOwner
{
minimumQuorum           = minimumQuorumForProposals;
debatingPeriodInMinutes = minutesForDebate;
majorityMargin          = marginOfVotesForMajority;

ChangeOfRules(minimumQuorum, debatingPeriodInMinutes, majorityMargin);
}








function newProposal(
address beneficiary,
uint256 amount,
string  jobDescription,
bytes   transactionBytecode
)
onlyMembers
returns (uint256 id)
{
id               = proposals.length++;
Proposal p       = proposals[id];
p.recipient      = beneficiary;
p.amount         = amount;
p.description    = jobDescription;
p.proposalHash   = sha3(beneficiary, amount, transactionBytecode);
p.votingDeadline = now + debatingPeriodInMinutes * 1 minutes;
p.executed       = false;
p.proposalPassed = false;
p.numberOfVotes  = 0;
ProposalAdded(id, beneficiary, amount, jobDescription);
}








function checkProposalCode(
uint256 id,
address beneficiary,
uint256 amount,
bytes   transactionBytecode
)
constant
returns (bool codeChecksOut)
{
return proposals[id].proposalHash
== sha3(beneficiary, amount, transactionBytecode);
}







function vote(
uint256 id,
bool    supportsProposal,
string  justificationText
)
onlyMembers
returns (uint256 vote)
{
Proposal p = proposals[id];
if (p.voted[msg.sender] == true) throw;
p.voted[msg.sender] = true;
p.numberOfVotes++;
if (supportsProposal) {
p.currentResult++;
} else {
p.currentResult--;
}

Voted(id,  supportsProposal, msg.sender, justificationText);
}






function executeProposal(
uint256 id,
bytes   transactionBytecode
)
onlyMembers
{
Proposal p = proposals[id];







if (now < p.votingDeadline
|| p.executed
|| p.proposalHash != sha3(p.recipient, p.amount, transactionBytecode)
|| p.numberOfVotes < minimumQuorum)
throw;



if (p.currentResult > majorityMargin) {


p.executed = true;
if (!p.recipient.call.value(p.amount)(transactionBytecode))
throw;

p.proposalPassed = true;
} else {
p.proposalPassed = false;
}

ProposalTallied(id, p.numberOfVotes, p.proposalPassed);
}
}