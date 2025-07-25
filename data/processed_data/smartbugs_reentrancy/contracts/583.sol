pragma solidity ^0.4.13;

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
    uint256 c = a / b;
    
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract DelegatedShareholderAssociation is TokenRecipient {

    uint public minimumQuorum;
    uint public debatingPeriodInMinutes;
    Proposal[] public proposals;
    uint public numProposals;
    ERC20 public sharesTokenAddress;

    
    mapping (address => address) public delegatesByDelegator;

    
    mapping (address => uint) public lockedDelegatingTokens;

    
    mapping (address => uint) public delegatedAmountsByDelegate;
    
    
    uint public totalLockedTokens;

    
    uint public requiredSharesToBeBoardMember;

    
    TokenLocker public tokenLocker;

    

    event ProposalAdded(uint proposalID, address recipient, uint amount, bytes metadataHash);
    event Voted(uint proposalID, bool position, address voter);
    event ProposalTallied(uint proposalID, uint yea, uint nay, uint quorum, bool active);
    event ChangeOfRules(uint newMinimumQuorum, uint newDebatingPeriodInMinutes, address newSharesTokenAddress);
    event TokensDelegated(address indexed delegator, uint numberOfTokens, address indexed delegate);
    event TokensUndelegated(address indexed delegator, uint numberOfTokens, address indexed delegate);

    struct Proposal {
        address recipient;
        uint amount;
        bytes metadataHash;
        uint timeCreated;
        uint votingDeadline;
        bool finalized;
        bool proposalPassed;
        uint numberOfVotes;
        bytes32 proposalHash;
        Vote[] votes;
        mapping (address => bool) voted;
    }

    struct Vote {
        bool inSupport;
        address voter;
    }

    
    modifier onlyShareholders {
        require(ERC20(sharesTokenAddress).balanceOf(msg.sender) > 0);
        _;
    }

    
    modifier onlySelf {
        require(msg.sender == address(this));
        _;
    }

    
    modifier notSelf {
        require(msg.sender != address(this));
        _;
    }

    
    modifier onlyUndelegated {
        require(delegatesByDelegator[msg.sender] == address(0));
        _;
    }

    
    modifier onlyBoardMembers {
        require(ERC20(sharesTokenAddress).balanceOf(msg.sender) >= requiredSharesToBeBoardMember);
        _;
    }

    
    modifier onlyDelegated {
        require(delegatesByDelegator[msg.sender] != address(0));
        _;
    }

    







    function setDelegateAndLockTokens(uint tokensToLock, address delegate)
        public
        onlyShareholders
        onlyUndelegated
        notSelf
    {
        lockedDelegatingTokens[msg.sender] = tokensToLock;
        delegatedAmountsByDelegate[delegate] = SafeMath.add(delegatedAmountsByDelegate[delegate], tokensToLock);
        totalLockedTokens = SafeMath.add(totalLockedTokens, tokensToLock);
        delegatesByDelegator[msg.sender] = delegate;
        require(sharesTokenAddress.transferFrom(msg.sender, tokenLocker, tokensToLock));
        require(sharesTokenAddress.balanceOf(tokenLocker) == totalLockedTokens);
        TokensDelegated(msg.sender, tokensToLock, delegate);
    }

    






    function clearDelegateAndUnlockTokens()
        public
        onlyDelegated
        notSelf
        returns (uint lockedTokens)
    {
        address delegate = delegatesByDelegator[msg.sender];
        lockedTokens = lockedDelegatingTokens[msg.sender];
        lockedDelegatingTokens[msg.sender] = 0;
        delegatedAmountsByDelegate[delegate] = SafeMath.sub(delegatedAmountsByDelegate[delegate], lockedTokens);
        totalLockedTokens = SafeMath.sub(totalLockedTokens, lockedTokens);
        delete delegatesByDelegator[msg.sender];
        require(tokenLocker.transfer(msg.sender, lockedTokens));
        require(sharesTokenAddress.balanceOf(tokenLocker) == totalLockedTokens);
        TokensUndelegated(msg.sender, lockedTokens, delegate);
        return lockedTokens;
    }

    










    function changeVotingRules(uint minimumSharesToPassAVote, uint minutesForDebate, uint sharesToBeBoardMember)
        public
        onlySelf
    {
        if (minimumSharesToPassAVote == 0 ) {
            minimumSharesToPassAVote = 1;
        }
        minimumQuorum = minimumSharesToPassAVote;
        debatingPeriodInMinutes = minutesForDebate;
        requiredSharesToBeBoardMember = sharesToBeBoardMember;
        ChangeOfRules(minimumQuorum, debatingPeriodInMinutes, sharesTokenAddress);
    }

    










    function newProposal(
        address beneficiary,
        uint weiAmount,
        bytes jobMetadataHash,
        bytes transactionBytecode
    )
        public
        onlyBoardMembers
        notSelf
        returns (uint proposalID)
    {
        
        require(beneficiary != address(tokenLocker));
        proposalID = proposals.length++;
        Proposal storage p = proposals[proposalID];
        p.recipient = beneficiary;
        p.amount = weiAmount;
        p.metadataHash = jobMetadataHash;
        p.proposalHash = keccak256(beneficiary, weiAmount, transactionBytecode);
        p.timeCreated = now;
        p.votingDeadline = now + debatingPeriodInMinutes * 1 minutes;
        p.finalized = false;
        p.proposalPassed = false;
        p.numberOfVotes = 0;
        ProposalAdded(proposalID, beneficiary, weiAmount, jobMetadataHash);
        numProposals = proposalID+1;
        return proposalID;
    }

    







    function checkProposalCode(
        uint proposalNumber,
        address beneficiary,
        uint weiAmount,
        bytes transactionBytecode
    )
        public
        view
        returns (bool codeChecksOut)
    {
        Proposal storage p = proposals[proposalNumber];
        return p.proposalHash == keccak256(beneficiary, weiAmount, transactionBytecode);
    }

    








    function vote(
        uint proposalNumber,
        bool supportsProposal
    )
        public
        onlyShareholders
        notSelf
        returns (uint voteID)
    {
        Proposal storage p = proposals[proposalNumber];
        require(p.voted[msg.sender] != true);
        voteID = p.votes.length++;
        p.votes[voteID] = Vote({inSupport: supportsProposal, voter: msg.sender});
        p.voted[msg.sender] = true;
        p.numberOfVotes = voteID + 1;
        Voted(proposalNumber, supportsProposal, msg.sender);
        return voteID;
    }

    





    function hasVoted(uint proposalNumber, address shareholder) public view returns (bool) {
        Proposal storage p = proposals[proposalNumber];
        return p.voted[shareholder];
    }

    




    function countVotes(uint proposalNumber) public view returns (uint yea, uint nay, uint quorum) {
        Proposal storage p = proposals[proposalNumber];
        yea = 0;
        nay = 0;
        quorum = 0;
        for (uint i = 0; i < p.votes.length; ++i) {
            Vote storage v = p.votes[i];
            uint voteWeight = SafeMath.add(sharesTokenAddress.balanceOf(v.voter), delegatedAmountsByDelegate[v.voter]);
            quorum = SafeMath.add(quorum, voteWeight);
            if (v.inSupport) {
                yea = SafeMath.add(yea, voteWeight);
            } else {
                nay = SafeMath.add(nay, voteWeight);
            }
        }
    }

    







    function executeProposal(uint proposalNumber, bytes transactionBytecode)
        public
        notSelf
    {
        Proposal storage p = proposals[proposalNumber];

        
        require((now >= p.votingDeadline) && !p.finalized && p.proposalHash == keccak256(p.recipient, p.amount, transactionBytecode));

        
        var ( yea, nay, quorum ) = countVotes(proposalNumber);

        
        require(quorum >= minimumQuorum);
        
           
        p.finalized = true;

        if (yea > nay) {
            
            p.proposalPassed = true;

            
            require(p.recipient.call.value(p.amount)(transactionBytecode));

        } else {
            
            p.proposalPassed = false;
        }

        
        ProposalTallied(proposalNumber, yea, nay, quorum, p.proposalPassed);
    }
}
