contract owned {
        address public owner;

        function owned() {
                owner = msg.sender;
        }

        modifier onlyOwner {
                if (msg.sender != owner) throw;
                _
        }

        function transferOwnership(address newOwner) onlyOwner {
                owner = newOwner;
        }
}


contract Congress is owned {

        
        uint public minimumQuorum;
        uint public debatingPeriodInMinutes;
        int public majorityMargin;
        Proposal[] public proposals;
        uint public numProposals;
        mapping(address => uint) public memberId;
        Member[] public members;

        address public unicornAddress;
        uint public priceOfAUnicornInFinney;

        event ProposalAdded(uint proposalID, address recipient, uint amount, string description);
        event Voted(uint proposalID, bool position, address voter, string justification);
        event ProposalTallied(uint proposalID, int result, uint quorum, bool active);
        event MembershipChanged(address member);
        event ChangeOfRules(uint minimumQuorum, uint debatingPeriodInMinutes, int majorityMargin);

        struct Proposal {
                address recipient;
                uint amount;
                string description;
                uint votingDeadline;
                bool executed;
                bool proposalPassed;
                uint numberOfVotes;
                int currentResult;
                bytes32 proposalHash;
                Vote[] votes;
                mapping(address => bool) voted;
        }

        struct Member {
                address member;
                uint voteWeight;
                bool canAddProposals;
                string name;
                uint memberSince;
        }

        struct Vote {
                bool inSupport;
                address voter;
                string justification;
        }


        
        function Congress(uint minimumQuorumForProposals, uint minutesForDebate, int marginOfVotesForMajority, address congressLeader) {
                minimumQuorum = minimumQuorumForProposals;
                debatingPeriodInMinutes = minutesForDebate;
                majorityMargin = marginOfVotesForMajority;
                members.length++;
                members[0] = Member({
                        member: 0,
                        voteWeight: 0,
                        canAddProposals: false,
                        memberSince: now,
                        name: ''
                });
                if (congressLeader != 0) owner = congressLeader;

        }

        
        function changeMembership(address targetMember, uint voteWeight, bool canAddProposals, string memberName) onlyOwner {
                uint id;
                if (memberId[targetMember] == 0) {
                        memberId[targetMember] = members.length;
                        id = members.length++;
                        members[id] = Member({
                                member: targetMember,
                                voteWeight: voteWeight,
                                canAddProposals: canAddProposals,
                                memberSince: now,
                                name: memberName
                        });
                } else {
                        id = memberId[targetMember];
                        Member m = members[id];
                        m.voteWeight = voteWeight;
                        m.canAddProposals = canAddProposals;
                        m.name = memberName;
                }

                MembershipChanged(targetMember);

        }

        
        function changeVotingRules(uint minimumQuorumForProposals, uint minutesForDebate, int marginOfVotesForMajority) onlyOwner {
                minimumQuorum = minimumQuorumForProposals;
                debatingPeriodInMinutes = minutesForDebate;
                majorityMargin = marginOfVotesForMajority;

                ChangeOfRules(minimumQuorum, debatingPeriodInMinutes, majorityMargin);
        }

        
        function changeUnicorn(uint newUnicornPriceInFinney, address newUnicornAddress) onlyOwner {
                unicornAddress = newUnicornAddress;
                priceOfAUnicornInFinney = newUnicornPriceInFinney;
        }

        
        function newProposalInWei(address beneficiary, uint weiAmount, string JobDescription, bytes transactionBytecode) returns(uint proposalID) {
                if (memberId[msg.sender] == 0 || !members[memberId[msg.sender]].canAddProposals) throw;

                proposalID = proposals.length++;
                Proposal p = proposals[proposalID];
                p.recipient = beneficiary;
                p.amount = weiAmount;
                p.description = JobDescription;
                p.proposalHash = sha3(beneficiary, weiAmount, transactionBytecode);
                p.votingDeadline = now + debatingPeriodInMinutes * 1 minutes;
                p.executed = false;
                p.proposalPassed = false;
                p.numberOfVotes = 0;
                ProposalAdded(proposalID, beneficiary, weiAmount, JobDescription);
                numProposals = proposalID + 1;
        }

        
        function newProposalInEther(address beneficiary, uint etherAmount, string JobDescription, bytes transactionBytecode) returns(uint proposalID) {
                if (memberId[msg.sender] == 0 || !members[memberId[msg.sender]].canAddProposals) throw;

                proposalID = proposals.length++;
                Proposal p = proposals[proposalID];
                p.recipient = beneficiary;
                p.amount = etherAmount * 1 ether;
                p.description = JobDescription;
                p.proposalHash = sha3(beneficiary, etherAmount * 1 ether, transactionBytecode);
                p.votingDeadline = now + debatingPeriodInMinutes * 1 minutes;
                p.executed = false;
                p.proposalPassed = false;
                p.numberOfVotes = 0;
                ProposalAdded(proposalID, beneficiary, etherAmount, JobDescription);
                numProposals = proposalID + 1;
        }

        
        function checkProposalCode(uint proposalNumber, address beneficiary, uint amount, bytes transactionBytecode) constant returns(bool codeChecksOut) {
                Proposal p = proposals[proposalNumber];
                return p.proposalHash == sha3(beneficiary, amount, transactionBytecode);
        }

        function vote(uint proposalNumber, bool supportsProposal, string justificationText) returns(uint voteID) {
                if (memberId[msg.sender] == 0) throw;

                uint voteWeight = members[memberId[msg.sender]].voteWeight;

                Proposal p = proposals[proposalNumber]; 
                if (p.voted[msg.sender] == true) throw; 
                p.voted[msg.sender] = true; 
                p.numberOfVotes += voteWeight; 
                if (supportsProposal) { 
                        p.currentResult += int(voteWeight); 
                } else { 
                        p.currentResult -= int(voteWeight); 
                }
                
                Voted(proposalNumber, supportsProposal, msg.sender, justificationText);
        }

        function executeProposal(uint proposalNumber, bytes transactionBytecode) returns(int result) {
                Proposal p = proposals[proposalNumber];
                
                if (now < p.votingDeadline 
                        || p.executed 
                        || p.proposalHash != sha3(p.recipient, p.amount, transactionBytecode) 
                        || p.numberOfVotes < minimumQuorum) 
                        throw;

                
                if (p.currentResult > majorityMargin) {
                        
                        p.recipient.call.value(p.amount)(transactionBytecode);
                        p.executed = true;
                        p.proposalPassed = true;
                } else {
                        p.executed = true;
                        p.proposalPassed = false;
                }
                
                ProposalTallied(proposalNumber, p.currentResult, p.numberOfVotes, p.proposalPassed);
        }

        function() {
                if (msg.value > priceOfAUnicornInFinney) {
                        token unicorn = token(unicornAddress);
                        unicorn.mintToken(msg.sender, msg.value / (priceOfAUnicornInFinney * 1 finney));
                }

        }
}

