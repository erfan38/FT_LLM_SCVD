pragma solidity ^0.8.0;
Member[] public members;




mapping(address => uint256) public memberId;







event ProposalAdded(uint256 indexed proposal,
address indexed recipient,
uint256 indexed amount,
string description);








event Voted(uint256 indexed proposal,
bool    indexed position,
address indexed voter,
string justification);







event ProposalTallied(uint256 indexed proposal,
uint256 indexed quorum,
bool    indexed active);






event MembershipChanged(address indexed member,
bool    indexed isMember);







event ChangeOfRules(uint256 indexed minimumQuorum,
uint256 indexed debatingPeriodInMinutes,
int256  indexed majorityMargin);

struct Proposal {
address recipient;
uint256 amount;
string  description;
uint256 votingDeadline;
bool    executed;
bool    proposalPassed;
uint256 numberOfVotes;
int256  currentResult;
bytes32 proposalHash;
Vote[]  votes;
mapping(address => bool) voted;
}

struct Member {
address member;
string  name;
uint256 memberSince;
}

struct Vote {
bool    inSupport;
address voter;
string  justification;
}




modifier onlyMembers {
if (memberId[msg.sender] == 0) throw;
_;
}




function Congress(
uint256 minimumQuorumForProposals,
uint256 minutesForDebate,
int256  marginOfVotesForMajority,
address congressLeader
) {
changeVotingRules(minimumQuorumForProposals, minutesForDebate, marginOfVotesForMajority);

addMember(0, '');
if (congressLeader != 0)
addMember(congressLeader, 'The Founder');
}






function addMember(address targetMember, string memberName) onlyOwner {
if (memberId[targetMember] != 0) throw;

memberId[targetMember] = members.length;
members.push(Member({member:      targetMember,
memberSince: now,
name:        memberName}));

MembershipChanged(targetMember, true);
}