contract BuilderCongress is Builder {
    /**
     * @dev Run script creation contract
     * @return address new contract
     */
    function create(uint256 minimumQuorumForProposals,
                    uint256 minutesForDebate,
                    int256 marginOfVotesForMajority,
                    address congressLeader,
                    address _client) payable returns (address) {
        if (buildingCostWei > 0 && beneficiary != 0) {
            // Too low value
            if (msg.value < buildingCostWei) throw;
            // Beneficiary send
            if (!beneficiary.send(buildingCostWei)) throw;
            // Refund
            if (msg.value > buildingCostWei) {
                if (!msg.sender.send(msg.value - buildingCostWei)) throw;
            }
        } else {
            // Refund all
            if (msg.value > 0) {
                if (!msg.sender.send(msg.value)) throw;
            }
        }

        if (_client == 0)
            _client = msg.sender;
 
        if (congressLeader == 0)
            congressLeader = _client;

        var inst = CreatorCongress.create(minimumQuorumForProposals,
                                          minutesForDebate,
                                          marginOfVotesForMajority,
                                          congressLeader);
        inst.setOwner(_client);
        inst.setHammer(_client);
        getContractsOf[_client].push(inst);
        Builded(_client, inst);
        return inst;
    }
}