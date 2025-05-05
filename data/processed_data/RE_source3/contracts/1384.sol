contract DAS is ERC223ContractInterface {

    /* Contract Variables */

    string name = "Decentralized Autonomous State";
    // Source of democracy
    DASToken public dasToken;
    ABCToken public abcToken;
    // Democracy rules
    uint256 public congressMemberThreshold; // User must have more than this amount of tokens to be included into congress
    uint256 public minimumQuorum;           // The minimum number of tokens that must participate in a vote to achieve a quorum
    uint256 public debatingPeriod;          // Min time to vote for an proposal [sec]
    uint256 public marginForMajority;       // Min superiority of votes "for" to pass the proposal [number of tokens]
    // Proposals
    Proposal[] public proposals;
    uint256 public proposalsNumber = 0;
    mapping (address => uint32) tokensLocks;         // congress member => number of locks (recursive mutex)

    /* Contract Events */
    event ProposalAddedEvent(uint256 proposalID, address beneficiary, uint256 etherAmount, string description);
    event VotedEvent(uint256 proposalID, address voter, bool inSupport, uint256 voterTokens, string justificationText);
    event ProposalTalliedEvent(uint256 proposalID, bool quorum, bool result);
    event ProposalExecutedEvent(uint256 proposalID);
    event RulesChangedEvent(uint256 congressMemberThreshold,
                            uint256 minimumQuorum,
                            uint256 debatingPeriod,
                            uint256 marginForMajority);

    /* Contract Structures */
    enum ProposalState {Proposed, NoQuorum, Rejected, Passed, Executed}

    struct Proposal {
        /* Proposal content */
        address beneficiary;
        uint256 etherAmount;
        string description;
        bytes32 proposalHash;

        /* Proposal state */
        ProposalState state;

        /* Voting state */
        uint256 votingDeadline;
        Vote[] votes;
        uint256 votesNumber;
        mapping (address => bool) voted;
    }

    struct Vote {
        address voter;
        bool inSupport;
        uint256 voterTokens;
        string justificationText;
    }

    /* modifier that allows only congress members to vote and create new proposals */
    modifier onlyCongressMembers {
        if (dasToken.balanceOf(msg.sender) < congressMemberThreshold) throw;
        _;
    }

    /* Constructor */
    function DAS(
        uint256 _congressMemberThreshold,
        uint256 _minimumQuorum,
        uint256 _debatingPeriod,
        uint256 _marginForMajority,
        address _congressLeader
    ) payable {
        // create a source of democracy
        dasToken = new DASToken('DA$', 'DA$', 18, 1000000000 * (10 ** 18), _congressLeader);
        abcToken = new ABCToken('Alphabit', 'ABC', 18, 210000000 * (10 ** 18), _congressLeader);

        // setup rules
        congressMemberThreshold = _congressMemberThreshold;
        minimumQuorum = _minimumQuorum;
        debatingPeriod = _debatingPeriod;
        marginForMajority = _marginForMajority;

        RulesChangedEvent(congressMemberThreshold, minimumQuorum, debatingPeriod, marginForMajority);
    }

    // blank fallback functions to receive ETH and tokens
    function() payable { }

    function erc223Fallback(address _from, uint256 _value, bytes _data){
        // to avoid warnings during compilation
        _from = _from;
        _value = _value;
        _data = _data;
    }


    /* Proposal-related functions */

    // calculate hash of an proposal
    function getProposalHash(
        address _beneficiary,
        uint256 _etherAmount,
        bytes _transactionBytecode
    )
        constant
        returns (bytes32)
    {
        return sha3(_beneficiary, _etherAmount, _transactionBytecode);
    }

    // block tokens of an voter
    function blockTokens(address _voter) internal {
        if (tokensLocks[_voter] + 1 < tokensLocks[_voter]) throw;

        tokensLocks[_voter] += 1;
        if (tokensLocks[_voter] == 1) {
            dasToken.blockAccount(_voter);
        }
    }

    // unblock tokens of an voter
    function unblockTokens(address _voter) internal {
        if (tokensLocks[_voter] <= 0) throw;

        tokensLocks[_voter] -= 1;
        if (tokensLocks[_voter] == 0) {
            dasToken.unblockAccount(_voter);
        }
    }

    // create new proposal
    function createProposal(
        address _beneficiary,
        uint256 _etherAmount,
        string _description,
        bytes _transactionBytecode
    )
        onlyCongressMembers
        returns (uint256 _proposalID)
    {
        _proposalID = proposals.length;
        proposals.length += 1;
        proposalsNumber = _proposalID + 1;

        proposals[_proposalID].beneficiary = _beneficiary;
        proposals[_proposalID].etherAmount = _etherAmount;
        proposals[_proposalID].description = _description;
        proposals[_proposalID].proposalHash = getProposalHash(_beneficiary, _etherAmount, _transactionBytecode);
        proposals[_proposalID].state = ProposalState.Proposed;
        proposals[_proposalID].votingDeadline = now + debatingPeriod * 1 seconds;
        proposals[_proposalID].votesNumber = 0;

        ProposalAddedEvent(_proposalID, _beneficiary, _etherAmount, _description);

        return _proposalID;
    }

    // vote for an proposal
    function vote(
        uint256 _proposalID,
        bool _inSupport,
        string _justificationText
    )
        onlyCongressMembers
    {
        Proposal p = proposals[_proposalID];

        if (p.state != ProposalState.Proposed) throw;
        if (p.voted[msg.sender] == true) throw;

        var voterTokens = dasToken.balanceOf(msg.sender);
        blockTokens(msg.sender);

        p.voted[msg.sender] = true;
        p.votes.push(Vote(msg.sender, _inSupport, voterTokens, _justificationText));
        p.votesNumber += 1;

        VotedEvent(_proposalID, msg.sender, _inSupport, voterTokens, _justificationText);
    }

    // finish voting on an proposal
    function finishProposalVoting(uint256 _proposalID) onlyCongressMembers {
        Proposal p = proposals[_proposalID];

        if (now < p.votingDeadline) throw;
        if (p.state != ProposalState.Proposed) throw;

        var _votesNumber = p.votes.length;
        uint256 tokensFor = 0;
        uint256 tokensAgainst = 0;
        for (uint256 i = 0; i < _votesNumber; i++) {
            if (p.votes[i].inSupport) {
                tokensFor += p.votes[i].voterTokens;
            }
            else {
                tokensAgainst += p.votes[i].voterTokens;
            }

            unblockTokens(p.votes[i].voter);
        }

        if ((tokensFor + tokensAgainst) < minimumQuorum) {
            p.state = ProposalState.NoQuorum;
            ProposalTalliedEvent(_proposalID, false, false);
            return;
        }
        if ((tokensFor - tokensAgainst) < marginForMajority) {
            p.state = ProposalState.Rejected;
            ProposalTalliedEvent(_proposalID, true, false);
            return;
        }
        p.state = ProposalState.Passed;
        ProposalTalliedEvent(_proposalID, true, true);
        return;
    }

    // execute passed proposal
    function executeProposal(uint256 _proposalID, bytes _transactionBytecode) onlyCongressMembers {
        Proposal p = proposals[_proposalID];

        if (p.state != ProposalState.Passed) throw;

        p.state = ProposalState.Executed;
        if (!p.beneficiary.call.value(p.etherAmount * 1 ether)(_transactionBytecode)) {
            throw;
        }

        ProposalExecutedEvent(_proposalID);
    }
}