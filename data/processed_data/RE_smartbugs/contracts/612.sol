











































































contract DTHPool is DTHPoolInterface, Token, usingOraclize {

    modifier onlyDelegate() {if (msg.sender != delegate) throw; _}

    

    function DTHPool(
        address _daoAddress,
        address _delegate,
        uint _maxTimeBlocked,
        string _delegateName,
        string _delegateUrl,
        string _tokenSymbol
    ) {
        daoAddress = _daoAddress;
        delegate = _delegate;
        delegateUrl = _delegateUrl;
        maxTimeBlocked = _maxTimeBlocked;
        name = _delegateName;
        symbol = _tokenSymbol;
        decimals = 16;
        oraclize_setNetwork(networkID_auto);
    }

    function delegateDAOTokens(uint _amount) returns (bool _success) {
        DAO dao = DAO(daoAddress);
        if (!dao.transferFrom(msg.sender, address(this), _amount)) {
            throw;
        }

        balances[msg.sender] += _amount;
        totalSupply += _amount;
        Delegate(msg.sender, _amount);
        return true;
    }

    function undelegateDAOTokens(uint _amount) returns (bool _success) {
        DAO dao = DAO(daoAddress);
        if (_amount > balances[msg.sender]) {
            throw;
        }

        if (!dao.transfer(msg.sender, _amount)) {
            throw;
        }

        balances[msg.sender] -= _amount;
        totalSupply -= _amount;
        Undelegate(msg.sender, _amount);
        return true;
    }

    function setVoteIntention(
        uint _proposalID,
        bool _willVote,
        bool _supportsProposal,
        string _motivation
    ) onlyDelegate returns (bool _success) {
        DAO dao = DAO(daoAddress);

        ProposalStatus proposalStatus = proposalStatuses[_proposalID];

        if (proposalStatus.voteSet) {
            throw;
        }

        var (,,,votingDeadline, ,,,,newCurator) = dao.proposals(_proposalID);

        if (votingDeadline < now || newCurator ) {
            throw;
        }

        proposalStatus.voteSet = true;
        proposalStatus.willVote = _willVote;
        proposalStatus.suportProposal = _supportsProposal;
        proposalStatus.votingDeadline = votingDeadline;
        proposalStatus.motivation = _motivation;

        VoteIntentionSet(_proposalID, _willVote, _supportsProposal);

        if (!_willVote) {
            proposalStatus.executed = true;
            VoteExecuted(_proposalID);
        }

        bool finalized = executeVote(_proposalID);

        if ((!finalized)&&(address(OAR) != 0)) {
            bytes32 oraclizeId = oraclize_query(votingDeadline - maxTimeBlocked +15, "URL", "");

            oraclizeId2proposalId[oraclizeId] = _proposalID;
        }

        return true;
    }

    function executeVote(uint _proposalID) returns (bool _finalized) {
        DAO dao = DAO(daoAddress);
        ProposalStatus proposalStatus = proposalStatuses[_proposalID];

        if (!proposalStatus.voteSet
            || now > proposalStatus.votingDeadline
            || !proposalStatus.willVote
            || proposalStatus.executed) {

            return true;
        }

        if (now < proposalStatus.votingDeadline - maxTimeBlocked) {
            return false;
        }

        dao.vote(_proposalID, proposalStatus.suportProposal);
        proposalStatus.executed = true;
        VoteExecuted(_proposalID);

        return true;
    }

    function __callback(bytes32 oid, string result) {
        uint proposalId = oraclizeId2proposalId[oid];
        executeVote(proposalId);
        oraclizeId2proposalId[oid] = 0;
    }

    function fixTokens() returns (bool _success) {
        DAO dao = DAO(daoAddress);
        uint ownedTokens = dao.balanceOf(this);
        if (ownedTokens < totalSupply) {
            throw;
        }
        uint fixTokens = ownedTokens - totalSupply;

        if (fixTokens == 0) {
            return true;
        }

        balances[delegate] += fixTokens;
        totalSupply += fixTokens;

        return true;
    }

    function getEther() onlyDelegate returns (uint _amount) {
        uint amount = this.balance;

        if (!delegate.call.value(amount)()) {
            throw;
        }

        return amount;
    }

}