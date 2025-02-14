pragma solidity ^0.4.25;





contract DAO is Dividends {

    
    uint minBalance = 1000000000000; 
    
    uint public minimumQuorum;
    
    uint public debatingPeriodDuration;
    
    uint public requisiteMajority;

    struct _Proposal {
        
        uint endTimeOfVoting;
        
        bool executed;
        
        bool proposalPassed;
        
        uint numberOfVotes;
        
        uint votesSupport;
        
        uint votesAgainst;
        
        
        address recipient;
        
        uint amount;
        
        bytes32 transactionHash;

        
        string desc;
        
        string fullDescHash;
    }

    _Proposal[] public Proposals;

    event ProposalAdded(uint proposalID, address recipient, uint amount, string description, string fullDescHash);
    event Voted(uint proposalID, bool position, address voter, string justification);
    event ProposalTallied(uint proposalID, uint votesSupport, uint votesAgainst, uint quorum, bool active);    
    event ChangeOfRules(uint newMinimumQuorum, uint newdebatingPeriodDuration, uint newRequisiteMajority);
    event Payment(address indexed sender, uint amount);

    
    modifier onlyMembers {
        require(balances[msg.sender] > 0);
        _;
    }

    









    function changeVotingRules(
        uint _minimumQuorum,
        uint _debatingPeriodDuration,
        uint _requisiteMajority
    ) onlyOwner public {
        minimumQuorum = _minimumQuorum;
        debatingPeriodDuration = _debatingPeriodDuration;
        requisiteMajority = _requisiteMajority;

        emit ChangeOfRules(minimumQuorum, debatingPeriodDuration, requisiteMajority);
    }

    










    function addProposal(address _recipient, uint _amount, string _desc, string _fullDescHash, bytes _transactionByteCode, uint _debatingPeriodDuration) onlyMembers public returns (uint) {
        require(balances[msg.sender] > minBalance);

        if (_debatingPeriodDuration == 0) {
            _debatingPeriodDuration = debatingPeriodDuration;
        }

        Proposals.push(_Proposal({      
            endTimeOfVoting: now + _debatingPeriodDuration * 1 minutes,
            executed: false,
            proposalPassed: false,
            numberOfVotes: 0,
            votesSupport: 0,
            votesAgainst: 0,
            recipient: _recipient,
            amount: _amount,
            transactionHash: keccak256(abi.encodePacked(_recipient, _amount, _transactionByteCode)),
            desc: _desc,
            fullDescHash: _fullDescHash
        }));
        
        
        super.addProposal(Proposals.length-1, Proposals[Proposals.length-1].endTimeOfVoting);

        emit ProposalAdded(Proposals.length-1, _recipient, _amount, _desc, _fullDescHash);

        return Proposals.length-1;
    }

    







    function checkProposalCode(uint _proposalID, address _recipient, uint _amount, bytes _transactionByteCode) view public returns (bool) {
        require(Proposals[_proposalID].recipient == _recipient);
        require(Proposals[_proposalID].amount == _amount);
        
        return Proposals[_proposalID].transactionHash == keccak256(abi.encodePacked(_recipient, _amount, _transactionByteCode));
    }

    








    function vote(uint _proposalID, bool _supportsProposal, string _justificationText) onlyMembers public returns (uint) {
        
        _Proposal storage p = Proposals[_proposalID]; 
        require(now <= p.endTimeOfVoting);

        
        uint votes = safeSub(balances[msg.sender], voted[_proposalID][msg.sender]);
        require(votes > 0);

        voted[_proposalID][msg.sender] = safeAdd(voted[_proposalID][msg.sender], votes);

        
        p.numberOfVotes = p.numberOfVotes + votes;
        
        if (_supportsProposal) {
            p.votesSupport = p.votesSupport + votes;
        } else {
            p.votesAgainst = p.votesAgainst + votes;
        }
        
        emit Voted(_proposalID, _supportsProposal, msg.sender, _justificationText);
        return p.numberOfVotes;
    }

    







    function executeProposal(uint _proposalID, bytes _transactionByteCode) public {
        
        _Proposal storage p = Proposals[_proposalID];

        require(now > p.endTimeOfVoting                                                                       
            && !p.executed                                                                                    
            && p.transactionHash == keccak256(abi.encodePacked(p.recipient, p.amount, _transactionByteCode))  
            && p.numberOfVotes >= minimumQuorum);                                                             
        
        if (p.votesSupport > requisiteMajority) {
            
            require(p.recipient.call.value(p.amount)(_transactionByteCode));
            p.proposalPassed = true;
        } else {
            
            p.proposalPassed = false;
        }
        p.executed = true;

        
        super.delProposal(_proposalID);
       
        
        emit ProposalTallied(_proposalID, p.votesSupport, p.votesAgainst, p.numberOfVotes, p.proposalPassed);
    }

    
    function delActiveProposal(uint _proposalID) public onlyOwner {
        
        super.delProposal(_proposalID);   
    }

    



    function transferOwnership(address _contract, address _newOwner) public onlyOwner {
        CommonI(_contract).transferOwnership(_newOwner);
    }

    


    function acceptOwnership(address _contract) public onlyOwner {
        CommonI(_contract).acceptOwnership();        
    }

    function updateAgent(address _contract, address _agent, bool _state) public onlyOwner {
        CommonI(_contract).updateAgent(_agent, _state);        
    }

    


    function setMinBalance(uint _minBalance) public onlyOwner {
        assert(_minBalance > 0);
        minBalance = _minBalance;
    }
}




